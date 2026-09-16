<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductListRequest;
use App\Http\Resources\ProductResource;
use App\Models\Ingredient;
use App\Models\Order;
use App\Models\Product;
use App\Models\Variant;
use App\Models\ProductBrand;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Session;
use Illuminate\Http\JsonResponse;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class CartController extends Controller
{

    public function showCartPage(Request $request)
    {
        $breadcrumbs = [
            ['title' => __('HOME'), 'url' => route('home')],
            ['title' => __('CART'), 'url' => route('cart')],
        ];

        $pageTitle = __('CART');
        $pageSubtitle = '';

        $catalogueData = [
            'breadcrumbs' => $breadcrumbs,
            'pageTitle' => $pageTitle,
            'pageSubtitle' => $pageSubtitle,
        ];

        return view('cart', ['catalogueData' => $catalogueData]);

    }

    public function showOrderResult(Request $request)
    {
        $orderId = $request->query('order_id');
        $orderNumber = $request->query('order_number');

        if (!$orderId && !$orderNumber) {
            // если нет параметров — редиректим на главную или корзину
            return redirect()->route('cart');
        }

        $query = Order::with(['items']); // lazy load items (OrderItem model)
        if ($orderId) {
            $query->where('id', (int)$orderId);
        } else {
            $query->where('order_number', $orderNumber);
        }

        $order = $query->first();

        if (!$order) {
            abort(404, 'Order not found');
        }

        // Очистим корзину в сессии — чтобы у пользователя не осталось старой корзины
        try {
            Session::forget('cart');
        } catch (\Throwable $e) {
            // не фейлим страницу из-за сессии
            \Log::warning('Failed to clear cart session on success page: '.$e->getMessage());
        }

        // подготовка data для шаблона (breadcrumbs и т.д., как в showCartPage)
        $breadcrumbs = [
            ['title' => __('HOME'), 'url' => route('home')],
            ['title' => __('CHECKOUT'), 'url' => null],
        ];
        $pageTitle = 'Checkout';
        $catalogueData = [
            'breadcrumbs' => $breadcrumbs,
            'pageTitle' => $pageTitle,
            'pageSubtitle' => '',
        ];

        return view('cart-complete', [
            'catalogueData' => $catalogueData,
            'order' => $order,
        ]);
    }


    public function showCartResultPage(Request $request)
    {
        $breadcrumbs = [
            ['title' => 'Home', 'url' => route('home')],
            ['title' => 'Checkout', 'url' => null],
        ];

        $pageTitle = 'Checkout';

        $catalogueData = [
            'breadcrumbs' => $breadcrumbs,
            'pageTitle' => $pageTitle,
            'pageSubtitle' => '',
        ];

        return view('cart-complete', ['catalogueData' => $catalogueData]);
    }

    /**
     * Get full cart contents + totals
     */
    public function get(Request $request): JsonResponse
    {
        try {
            $cart = Session::get('cart', []);
            // Нормализуем все элементы (берём из сессии и подгружаем данные из моделей)
            $items = array_values(array_map([$this, 'normalizeCartItemForResponse'], $cart));

            // Рассчитываем totals на основании нормализованных элементов, чтобы price/qty совпадали с фронтом
            $productsSum = array_reduce($items, function ($acc, $it) {
                return $acc + ((float)($it['price'] ?? 0) * (int)($it['qty'] ?? 0));
            }, 0.0);
            $totalItems = array_reduce($items, function ($acc, $it) {
                return $acc + (int)($it['qty'] ?? 0);
            }, 0);

            $totals = [
                'products' => round($productsSum, 2),
                'total_items' => $totalItems,
                'total' => round($productsSum, 2),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'items' => $items,
                    'totals' => $totals,
                ],
            ]);
        } catch (\Throwable $e) {
            Log::error('Cart get error: '.$e->getMessage(), ['exception' => $e]);
            return response()->json(['success' => false, 'message' => 'Failed to load cart'], 500);
        }
    }

    /**
     * Add product to cart (or increment quantity)
     * body: { product_id: int, quantity: int }
     */
    public function add(Request $request): JsonResponse
    {
        $data = $request->validate([
            'product_id' => 'required|integer|exists:products,id',
            'quantity' => 'sometimes|integer|min:1',
        ]);

        try {
            $product = Product::findOrFail($data['product_id']);
            $qty = isset($data['quantity']) ? (int)$data['quantity'] : 1;

            $cart = Session::get('cart', []);

            if (isset($cart[$product->id])) {
                $cart[$product->id]['quantity'] = (int)$cart[$product->id]['quantity'] + $qty;
            } else {
                $cart[$product->id] = [
                    'id' => (int)$product->id,
                    'price' => (float) ($product->price ?? 0),
                    'quantity' => $qty,
                    'sku' => $product->sku ?? null,
                    'meta' => null,
                ];
            }

            Session::put('cart', $cart);

            // Нормализуем все элементы для ответа (и используем их для расчёта totals)
            $items = array_values(array_map([$this, 'normalizeCartItemForResponse'], $cart));

            // Рассчитываем totals по нормализованным элементам чтобы price/qty совпадали с фронтом
            $productsSum = array_reduce($items, function ($acc, $it) {
                return $acc + (float)($it['price'] ?? 0) * (int)($it['qty'] ?? 0);
            }, 0.0);
            $totalItems = array_reduce($items, function ($acc, $it) {
                return $acc + (int)($it['qty'] ?? 0);
            }, 0);
            $totals = [
                'products' => round($productsSum, 2),
                'total_items' => $totalItems,
                'total' => round($productsSum, 2),
            ];

            // Включаем последний добавленный/обновлённый item для удобства (backwards compatibility)
            $lastItem = $this->normalizeCartItemForResponse($cart[$product->id]);

            return response()->json([
                'success' => true,
                'message' => 'Product added to cart',
                'data' => [
                    // Главное — всегда отдаем items (массив)
                    'items' => $items,
                    'item' => $lastItem,
                    'totals' => $totals,
                ],
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            throw $ve; // Laravel обработает и вернёт 422
        } catch (\Throwable $e) {
            Log::error('Cart add error: '.$e->getMessage(), ['exception' => $e]);
            return response()->json(['success' => false, 'message' => 'Failed to add product to cart'], 500);
        }
    }

    /**
     * Update quantity for a product in cart
     * body: { product_id: int, quantity: int }
     */
    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'product_id' => 'required|integer',
            'quantity' => 'required|integer|min:0',
        ]);

        try {
            $cart = Session::get('cart', []);
            $productId = (int) $data['product_id'];

            if (!isset($cart[$productId])) {
                return response()->json(['success' => false, 'message' => 'Product not in cart'], 404);
            }

            $qty = (int) $data['quantity'];

            if ($qty === 0) {
                unset($cart[$productId]);
                Session::put('cart', $cart);

                $items = array_values(array_map([$this, 'normalizeCartItemForResponse'], $cart));
                $productsSum = array_reduce($items, function ($acc, $it) {
                    return $acc + (float)($it['price'] ?? 0) * (int)($it['qty'] ?? 0);
                }, 0.0);
                $totalItems = array_reduce($items, function ($acc, $it) {
                    return $acc + (int)($it['qty'] ?? 0);
                }, 0);
                $totals = [
                    'products' => round($productsSum, 2),
                    'total_items' => $totalItems,
                    'total' => round($productsSum, 2),
                ];

                return response()->json([
                    'success' => true,
                    'message' => 'Product removed from cart',
                    'data' => [
                        'items' => $items,
                        'totals' => $totals,
                    ],
                ]);
            }

            // обновляем количество
            $cart[$productId]['quantity'] = $qty;
            Session::put('cart', $cart);

            // Нормализуем все элементы и пересчитываем totals на их основе
            $items = array_values(array_map([$this, 'normalizeCartItemForResponse'], $cart));
            $productsSum = array_reduce($items, function ($acc, $it) {
                return $acc + (float)($it['price'] ?? 0) * (int)($it['qty'] ?? 0);
            }, 0.0);
            $totalItems = array_reduce($items, function ($acc, $it) {
                return $acc + (int)($it['qty'] ?? 0);
            }, 0);
            $totals = [
                'products' => round($productsSum, 2),
                'total_items' => $totalItems,
                'total' => round($productsSum, 2),
            ];

            // Также возвращаем конкретный обновлённый элемент (для удобства)
            $item = $this->normalizeCartItemForResponse($cart[$productId]);

            return response()->json([
                'success' => true,
                'message' => 'Cart updated',
                'data' => [
                    'items' => $items,
                    'item' => $item,
                    'totals' => $totals,
                ],
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            throw $ve;
        } catch (\Throwable $e) {
            Log::error('Cart update error: '.$e->getMessage(), ['exception' => $e]);
            return response()->json(['success' => false, 'message' => 'Failed to update cart'], 500);
        }
    }

    /**
     * Remove a product from cart by id (route param)
     */
    public function remove(Request $request, $productId): JsonResponse
    {
        try {
            $cart = Session::get('cart', []);
            $productId = (int) $productId;

            if (!isset($cart[$productId])) {
                return response()->json(['success' => false, 'message' => 'Product not in cart'], 404);
            }

            // Сохраняем нормализованный элемент до удаления (удобно вернуть клиенту)
            $removedItem = $this->normalizeCartItemForResponse($cart[$productId]);

            // Удаляем и сохраняем сессию
            unset($cart[$productId]);
            Session::put('cart', $cart);

            // Нормализуем оставшиеся элементы и пересчитываем totals на их основе
            $items = array_values(array_map([$this, 'normalizeCartItemForResponse'], $cart));
            $productsSum = array_reduce($items, function ($acc, $it) {
                return $acc + ((float)($it['price'] ?? 0) * (int)($it['qty'] ?? 0));
            }, 0.0);
            $totalItems = array_reduce($items, function ($acc, $it) {
                return $acc + (int)($it['qty'] ?? 0);
            }, 0);
            $totals = [
                'products' => round($productsSum, 2),
                'total_items' => $totalItems,
                'total' => round($productsSum, 2),
            ];

            return response()->json([
                'success' => true,
                'message' => 'Product removed from cart',
                'data' => [
                    // возвращаем удалённый элемент для удобства (backwards compat с item)
                    'item' => $removedItem,
                    'items' => $items,
                    'totals' => $totals,
                ],
            ]);
        } catch (\Throwable $e) {
            Log::error('Cart remove error: '.$e->getMessage(), ['exception' => $e]);
            return response()->json(['success' => false, 'message' => 'Failed to remove product'], 500);
        }
    }

    /**
     * Clear the whole cart
     */
    public function clear(Request $request): JsonResponse
    {
        try {
            Session::forget('cart');

            return response()->json(['success' => true, 'message' => 'Cart cleared', 'data' => ['items' => [], 'totals' => $this->calculateTotals([])]]);
        } catch (\Throwable $e) {
            Log::error('Cart clear error: '.$e->getMessage(), ['exception' => $e]);
            return response()->json(['success' => false, 'message' => 'Failed to clear cart'], 500);
        }
    }

    /**
     * Helper that calculates totals
     */
    protected function calculateTotals(array $cart): array
    {
        $subtotal = 0.0;
        $totalItems = 0;

        foreach ($cart as $item) {
            $price = (float) ($item['price'] ?? 0);
            $qty = (int) ($item['quantity'] ?? 0);
            $line = $price * $qty;
            $subtotal += $line;
            $totalItems += $qty;
        }

        $grandTotal = $subtotal;

        return [
            'products' => round($subtotal, 2),
            'total_items' => $totalItems,
            'total' => round($grandTotal, 2),
        ];
    }

    /**
     * Нормализуем отдельный элемент корзины к формату, удобному фронту.
     * Вход: элемент, как он хранится в сессии.
     * Выход: { id, title, price, qty, image, sku, line_total, meta }
     */
    protected function normalizeCartItemForResponse(array $item): array
    {
        $id = isset($item['id']) ? (int)$item['id'] : null;
        $price = isset($item['price']) ? (float)$item['price'] : 0.0;
        $qty = isset($item['quantity']) ? (int)$item['quantity'] : 0;
        $lineTotal = $price * $qty;

        // По умолчанию берем данные из сессии (на случай отсутствия модели)
        $title = $item['title'] ?? $item['name'] ?? ($item['product_name'] ?? '');
        $image = $item['image'] ?? null;
        $sku = $item['sku'] ?? null;

        // Если есть id — пытаемся подгрузить актуальную информацию из модели Product
        if ($id !== null) {
            try {
                $product = Product::find($id);
                if ($product) {
                    // локаль — используем текущую или приложение
                    $locale = app()->getLocale();

                    // Название из модели (если есть getName) или fallback на обычное поле
                    if (method_exists($product, 'getName')) {
                        $title = $product->getName($locale) ?? $title;
                    } else {
                        $title = $product->name ?? $title;
                    }

                    // sku & price — обновляем из модели если есть
                    $sku = $product->sku ?? $sku;
                    $price = (float) ($product->price_ua ?? $price);
                    $lineTotal = $price * $qty;

                    // image — берем из media (Spatie) если доступно
                    if (method_exists($product, 'getMedia')) {
                        $media = $product->getMedia('images');
                        $first = $media->first();
                        if ($first) {
                            // используем webp если настроено, иначе оригинал
                            if (method_exists($first, 'getUrl')) {
                                // если у вас есть конверсия 'webp'
                                try {
                                    $image = $first->getUrl('webp') ?: $first->getUrl();
                                } catch (\Throwable $e) {
                                    // если conversion не найден — берём оригинал
                                    $image = $first->getUrl();
                                }
                            }
                        }
                    }

                    // также можно добавить небольшую мини-ресурсу структуру images
                    // $images = $product->getMedia('images')->map(fn($img)=>['url'=>$img->getUrl('webp')??$img->getUrl(),'url_original'=>$img->getUrl()]);
                }
            } catch (\Throwable $e) {
                // не фэйлим — логируем и используем данные из сессии
                Log::warning("Failed to load product $id for cart normalization: ".$e->getMessage());
            }
        }

        return [
            'id' => $id,
            'title' => $title,
            'price' => round($price, 2),
            'qty' => $qty,
            'image' => $image ? (string)$image : null,
            'sku' => $sku,
            'line_total' => round($lineTotal, 2),
            // raw meta left for advanced usage
            'meta' => $item['meta'] ?? null,
        ];
    }

}
