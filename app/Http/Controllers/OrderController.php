<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class OrderController extends Controller
{
    // GET /api/v1/orders
    public function index(Request $request)
    {
        // простой список, с пагинацией
        $perPage = (int) $request->query('per_page', 20);
        $q = Order::query()->orderBy('created_at', 'desc');

        // фильтры (email, status)
        if ($request->has('email')) $q->where('email', $request->query('email'));
        if ($request->has('status')) $q->where('status', $request->query('status'));

        return response()->json($q->paginate($perPage));
    }

    // GET /api/v1/orders/{order}
    public function show(Order $order)
    {
        $order->load('items.product');
        return response()->json($order);
    }

    // POST /api/v1/orders
    public function store(Request $request)
    {
        // Валидация входящего payload
        $validated = $request->validate([
            'billing' => 'required|array',
            'billing.email' => 'nullable|email',
            'billing.fname' => 'required|string',
            'billing.lname' => 'nullable|string',
            'billing.phone' => 'nullable|string',
            'cart' => 'required|array',
            // items может быть cart.items или cart.items[] — допускаем вариант
            'cart.items' => 'required|array|min:1',
            'cart.items.*.id' => 'nullable|integer',
            'cart.items.*.title' => 'required|string',
            'cart.items.*.price' => 'required|numeric',
            'cart.items.*.qty' => 'sometimes|integer|min:1',
        ]);

        $billing = $request->input('billing', []);
        $cart = $request->input('cart', []);
        $items = $cart['items'] ?? $cart; // если фронт отправляет просто cart = items array

        // Создаём заказ в транзакции, считаем суммы в копейках (integer)
        DB::beginTransaction();
        try {
            // Генерируем уникальный номер заказа
            $orderNumber = 'ORD-' . Carbon::now()->format('YmdHis') . '-' . strtoupper(Str::random(4));

            $productsTotalCents = 0;
            $totalItems = 0;

            // Создаём пустой order сначала
            $order = Order::create([
                'order_number' => $orderNumber,
                'status' => 'pending',
                'fname' => $billing['fname'] ?? null,
                'lname' => $billing['lname'] ?? null,
                'phone' => $billing['phone'] ?? null,
                'email' => $billing['email'] ?? null,
                'products_total' => 0,
                'total' => 0,
                'total_items' => 0,
                'currency' => $cart['currency'] ?? 'UAH',
            ]);

            foreach ($items as $i) {
                // разные именования: qty или quantity
                $qty = isset($i['qty']) ? (int)$i['qty'] : (isset($i['quantity']) ? (int)$i['quantity'] : 1);
                $price = (float) ($i['price'] ?? 0.0); // decimal like 2695.00
                // аккуратное вычисление копеек
                $priceCents = (int) round($price * 100); // digit-by-digit: превращаем в целые копейки
                $lineTotalCents = $priceCents * $qty;

                // создаём позицию (price в decimal в таблице order_items)
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $i['id'] ?? null,
                    'title' => $i['title'] ?? null,
                    'quantity' => $qty,
                    'price' => number_format($price, 2, '.', ''), // сохранение в decimal(8,2)
                ]);

                $productsTotalCents += $lineTotalCents;
                $totalItems += $qty;
            }

            // можно добавить доставка/налоги: если у тебя есть в cart.totals
            $shippingCents = 0;
            if (!empty($cart['totals']['shipping'])) {
                $shippingCents = (int) round(((float)$cart['totals']['shipping']) * 100);
            }
            $taxesCents = 0;
            if (!empty($cart['totals']['taxes'])) {
                $taxesCents = (int) round(((float)$cart['totals']['taxes']) * 100);
            }
            $discountCents = 0;
            if (!empty($cart['totals']['discount'])) {
                $discountCents = (int) round(((float)$cart['totals']['discount']) * 100);
            }

            $totalCents = $productsTotalCents + $shippingCents + $taxesCents - $discountCents;
            if ($totalCents < 0) $totalCents = 0;

            // Обновляем order totals
            $order->products_total = number_format($productsTotalCents / 100, 2, '.', '');
            $order->total = number_format($totalCents / 100, 2, '.', '');
            $order->total_items = $totalItems;
            $order->save();

            DB::commit();

            // Возвращаем упрощённый ответ
            return response()->json([
                'success' => true,
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'total' => $order->total,
                'message' => 'Order created'
            ], 201);

        } catch (\Throwable $e) {
            DB::rollBack();
            Log::error('Order store error: '.$e->getMessage(), ['payload' => $request->all()]);
            return response()->json(['success' => false, 'message' => 'Не удалось сохранить заказ'], 500);
        }
    }

    // PUT /api/v1/orders/{order}
    public function update(Request $request, Order $order)
    {
        // позволяем обновить биллинг/статус и т.д. (по необходимости расшири)
        $data = $request->validate([
            'fname' => 'nullable|string',
            'lname' => 'nullable|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
        ]);

        $order->update($data);
        return response()->json(['success' => true, 'order' => $order]);
    }

    // POST /api/v1/orders/{order}/status
    public function updateStatus(Request $request, Order $order)
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['pending','paid','cancelled','refunded','processing'])],
        ]);

        $order->status = $data['status'];
        $order->save();

        return response()->json(['success' => true, 'order' => $order]);
    }

    // DELETE /api/v1/orders/{order}
    public function destroy(Order $order)
    {
        $order->delete();
        return response()->json(['success' => true]);
    }
}
