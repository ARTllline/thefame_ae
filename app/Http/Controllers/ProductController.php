<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductListRequest;
use App\Http\Resources\ProductResource;
use App\Models\Ingredient;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\Variant;
use App\Models\ProductBrand;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Arr;
use Illuminate\Support\Str;
class ProductController extends Controller
{

    public function resolve(Request $request, $path = null)
    {
        // нормализуем путь и разбиваем на сегменты
        $fullPath = trim($request->path(), '/');
        $segments = $this->pathToSegments($fullPath);

        // Первый сегмент должен быть 'catalogue'
        $first = $segments[0] ?? null;
        if ($first !== 'catalogue') {
            abort(404);
        }

        // субсегменты после /catalogue
        $subSegments = array_slice($segments, 1);

        // Инициализация
        $breadcrumbs = [
            ['title' => __('HOME'), 'url' => route('home')],
            ['title' => __('CATALOGUE'), 'url' => route('catalogue.resolve', ['path' => ''])]
        ];
        $pageTitle = '';
        $pageSubtitle = '';
        $seoText = '';
        $query = Product::query()->with(['brand', 'category'])->active()->ordered();
        $context = [
            'type' => 'catalogue', // 'brand', 'discovery', 'category', 'root'
            'object' => null,      // например бренд или категория
        ];
        $currentFilter = null;

        $filters = [
            'brands' => [
                'for' => 'product_brand_id',
                'type' => 'checkbox',
                'label' => 'Бренд',
            ],
            'ingredients' => [
                'for' => 'ingredients',
                'type' => 'checkbox',
                'label' => 'Актив / Ингредиент',
            ],
            'volumes' => [
                'for' => 'volume',
                'type' => 'checkbox',
                'label' => 'Объём',
            ],
            'price' => [
                'for' => 'price_eu',
                'type' => 'range',
                'label' => 'Цена',
            ],

        ];



        // Если нет подуровней — просто список всех продуктов (с фильтрами query)
        if (count($subSegments) === 0) {
            // оставляем $query как есть
            $pageTitle = __('CATALOGUE');
            $pageSubtitle = __('ALL PRODUCTS');

        } else {
            $firstSub = $subSegments[0];

            // Обработка префикса brand: /catalogue/brand/{brand-slug}
            if ($firstSub === 'brand') {
                $brandSlug = $subSegments[1] ?? null;
                if (!$brandSlug) abort(404);

                $brand = ProductBrand::where('slug', $brandSlug)->where('is_active', true)->first();
                if (!$brand) abort(404);

                $context['type'] = 'brand';
                $context['object'] = $brand;
                $pageTitle = $brand->name;
                $seoText = $brand->seo_text;
                $currentFilter = ['for' => 'brand', 'value' => $brand->id];

                // хлебные крошки
                $breadcrumbs[] = ['title' => __('BRANDS'), 'url' => null];
                $breadcrumbs[] = ['title' => $brand->name, 'url' => route('catalogue.resolve', ['path' => "brand/{$brand->slug}"])];

                unset($filters['brands']);

                // фильтруем товары по бренду
                $query->where('product_brand_id', $brand->id);
            }
            elseif ($firstSub === 'ingredient') {
                $ingredientSlug = $subSegments[1] ?? null;
                if (!$ingredientSlug) abort(404);

                $ingredient = Ingredient::where('slug', $ingredientSlug)->where('is_active', true)->first();
                if (!$ingredient) abort(404);

                $context['type'] = 'ingredient';
                $context['object'] = $ingredient;
                $pageTitle = $ingredient->name;
                $seoText = $ingredient->seo_text;
                $currentFilter = ['for' => 'ingredient', 'value' => $ingredient->id];
                // хлебные крошки
                $breadcrumbs[] = ['title' => __('INGREDIENT'), 'url' => null];
                $breadcrumbs[] = ['title' => $ingredient->name, 'url' => route('catalogue.resolve', ['path' => "ingredient/{$ingredient->slug}"])];

                unset($filters['ingredients']);

                // фильтруем товары по ингредиенту
                $query->whereHas('ingredients', function ($q) use ($ingredient) {
                    $q->where('ingredients.id', $ingredient->id);
                });

            }
            elseif ($firstSub === 'category') {
                $categorySlug = $subSegments[1] ?? null;
                if (!$categorySlug) abort(404);

                $category = ProductCategory::where('slug', $categorySlug)->where('is_active', true)->first();
                if (!$category) abort(404);

                $context['type'] = 'category';
                $context['object'] = $category;
                $pageTitle = $category->name;
                $seoText = $category->seo_text;
                $currentFilter = ['for' => 'category', 'value' => $category->id];
                // хлебные крошки
                $breadcrumbs[] = ['title' => __('CATEGORY'), 'url' => null];
                $breadcrumbs[] = ['title' => $category->name, 'url' => route('catalogue.resolve', ['path' => "category/{$category->slug}"])];

                unset($filters['categories']);

                // фильтруем товары по категории
                $query->where('product_category_id', $category->id);
            }
            elseif ($firstSub === 'discovery') {
                $variantSlug = $subSegments[1] ?? null;
                if (!$variantSlug) abort(404);

                $variant = Variant::where('slug', $variantSlug)->where('is_active', true)->first();
                if (!$variant) abort(404);

                $context['type'] = 'variant';
                $context['object'] = $variant;
                $pageTitle = $variant->name;
                $seoText = $variant->seo_text;
                $currentFilter = ['for' => 'variant', 'value' => $variant->id];

                $breadcrumbs[] = ['title' => $variant->name, 'url' => route('catalogue.resolve', ['path' => "discovery/{$variant->slug}"])];

                $query->whereHas('variants', function ($q) use ($variant) {
                    $q->where('variants.id', $variant->id);
                });

            }
            else {
                abort(404);
            }
        }

        // установка фильтров
        $filters = $this->setFilters($filters);

        // пагинация
        $perPage = (int)$request->query('per_page', 20);
        $products = $query->take($perPage)->get();
        $productsResource = ProductResource::collection($products)->toArray($request);

        $catalogueData = [
            'products' => $productsResource,
            'breadcrumbs' => $breadcrumbs,
            'pageTitle' => $pageTitle,
            'pageSubtitle' => $pageSubtitle,
            'context' => $context,
            'filters' => $filters,
            'seoText' => $seoText,
            'currentFilter' => $currentFilter,
            'meta' => [
                'total' => $query->count(),
                'take' => $perPage,
                'skip' => $perPage,
                'taken' => count($products),
            ]
        ];

        return view('catalogue', ['catalogueData' => $catalogueData]);
    }

    /**
     * Разбивает путь в массив сегментов (без пустых элементов)
     */
    private function pathToSegments(string $path): array
    {
        if ($path === '') return [];
        return array_values(array_filter(explode('/', $path), fn($s) => $s !== ''));
    }

    /**
     * Установка фильтров
     */
    private function setFilters($filters): array
    {
        $productQuery = Product::query()->active();
        $productIds = $productQuery->pluck('id')->toArray();
        $availableBrands = $productQuery->select('product_brand_id')
            ->distinct()
            ->with('brand')
            ->whereNotNull('product_brand_id')
            ->get()
            ->map(function ($p) {
                return $p->brand;
            })
            ->filter()
            ->unique('id')
            ->values()->map(function ($b) {
                return ['id' => $b->id, 'slug' => $b->slug ?? null, 'title' => $b->name];
            });
        $availableIngredients = Ingredient::whereHas('products', function ($q) use ($productIds) {
            $q->whereIn('products.id', $productIds);
        })->get()->map(function ($ing) {
            return ['id' => $ing->id, 'slug' => $ing->slug ?? null, 'title' => $ing->name];
        });
        $availableVolumes = $productQuery->select('volume')->distinct()->pluck('volume')->filter()->values()->map(function ($v) {
            return ['value' => $v, 'title' => $v];
        });
        $priceMin = $productQuery->min('price_eu') ?: 0;
        $priceMax = $productQuery->max('price_eu') ?: 0;

        foreach ($filters as $key => &$filter) {
            if ($key === 'brands') {
                $filter['options'] = $availableBrands;
            } elseif ($key === 'ingredients') {
                $filter['options'] = $availableIngredients;
            } elseif ($key === 'volumes') {
                $filter['options'] = $availableVolumes;
            } elseif ($key === 'price') {
                $filter['min'] = $priceMin;
                $filter['max'] = $priceMax;
            }
        }
        unset($filter);

        return $filters;
    }

    /////////////////////////
    public function showProduct(Request $request, string $slug)
    {
        $product = Product::with(['brand', 'category', 'ingredients'])->where('slug', $slug)->first();
        if (!$product) {
            abort(404);
        }

        $breadcrumbs = [
            ['title' => __('HOME'), 'url' => url('/')],
            ['title' => __('CATALOGUE'), 'url' => url('/catalogue')],
            ['title' => $product->name, 'url' => url('/product/' . $product->slug)],
        ];

        $productArray = (new \App\Http\Resources\ProductResource($product))->toArray($request);
        $productData = [
            'product' => $productArray,
            'breadcrumbs' => $breadcrumbs
        ];

        return view('catalogue-card', ['productData' => $productData]);
    }

    public function showCatalogue(Request $request)
    {
        $path = trim($request->path(), '/'); // e.g. "catalog/cleansers/milk" or "brand/hydromax"
        $segments = $path === '' ? [] : explode('/', $path);

        // Defaults
        $pageType = 'catalogue';
        $contextModel = null;
        $context = [];
        $breadcrumbs = [
            ['title' => 'Home', 'url' => url('/')],
        ];

        $productQuery = Product::query()->active();
        $productIds = $productQuery->pluck('id')->toArray();

        ////////////НАСТРОЙКА СОРТИРОВКИ
        $sortOptions = [
            ['key' => 'popular', 'title' => 'По популярности'],
            ['key' => 'new', 'title' => 'Новинки'],
            ['key' => 'price_asc', 'title' => 'Цена: по возрастанию'],
            ['key' => 'price_desc', 'title' => 'Цена: по убыванию'],
            ['key' => 'rating', 'title' => 'Рейтинг'],
        ];
        ////////////

        ////////////НАСТРОЙКА ФИЛЬТРОВ
        $availableBrands = $productQuery->select('product_brand_id')
            ->distinct()
            ->with('brand')
            ->whereNotNull('product_brand_id')
            ->get()
            ->map(function ($p) {
                return $p->brand;
            })
            ->filter()
            ->unique('id')
            ->values()->map(function ($b) {
                return ['id' => $b->id, 'slug' => $b->slug ?? null, 'title' => $b->name];
            });
        $availableIngredients = Ingredient::whereHas('products', function ($q) use ($productIds) {
            $q->whereIn('products.id', $productIds);
        })->get()->map(function ($ing) {
            return ['id' => $ing->id, 'slug' => $ing->slug ?? null, 'title' => $ing->name];
        });
        $availableVolumes = $productQuery->select('volume')->distinct()->pluck('volume')->filter()->values();
        $priceMin = $productQuery->min('price_eu') ?: 0;
        $priceMax = $productQuery->max('price_eu') ?: 0;

        $filters = [
            'brands' => [
                'type' => 'checkbox',
                'label' => 'Бренд',
                'options' => $availableBrands,
                'applied' => null,
            ],
            'ingredients' => [
                'type' => 'checkbox',
                'label' => 'Актив / Ингредиент',
                'options' => $availableIngredients,
                'applied' => null,
            ],
            'price' => [
                'type' => 'range',
                'label' => 'Цена (EUR)',
                'min' => (float)$priceMin,
                'max' => (float)$priceMax,
                'applied_min' => $request->input('price_min'),
                'applied_max' => $request->input('price_max'),
            ],
            'volumes' => [
                'type' => 'checkbox',
                'label' => 'Объём',
                'options' => $availableVolumes->map(function ($v) {
                    return ['value' => $v, 'title' => (string)$v];
                })->values(),
                'applied' => null,
            ],
            'per_page' => [
                'type' => 'select',
                'label' => 'На странице',
                'options' => [
                    ['key' => 12, 'title' => '12'],
                    ['key' => 24, 'title' => '24'],
                    ['key' => 48, 'title' => '48'],
                ],
                'applied' => $request->input('per_page', 24),
            ],
        ];
        ////////////

        ////////////НАСТРОЙКА СТАТИКИ И СЕО
        $title = $context['title'] ?? 'Каталог';
        $subtitle = null;
        $seoText = null;

        if ($contextModel) {
            if (isset($context['type']) && $context['type'] === 'product' && method_exists($contextModel, 'getSubtitle')) {
                $subtitle = $contextModel->getSubtitle();
            } else {
                // try common fields
                $subtitle = $contextModel->seo_subtitle ?? $contextModel->subtitle ?? null;
            }
            $seoText = $contextModel->seo_text ?? $contextModel->description ?? null;
        } else {
            $title = 'Каталог продукции';
            $subtitle = 'Широкий выбор косметики и средств ухода';
            $seoText = 'В каталоге представлены средства по уходу для всех типов кожи. Удобные фильтры помогут найти идеальный продукт.';
        }
        $productCount = $productQuery->count();
        ////////////////////////////////////


        // Response structure
        $response = [
            'meta' => [
                'page_type' => $pageType,
                'context' => $context,
                'product_count' => $productCount,
            ],

            'filters' => $filters,
            'sort' => $sortOptions,

            'breadcrumbs' => $breadcrumbs,
            'title' => $title,
            'subtitle' => $subtitle,
            'seo_text' => $seoText,
        ];

        return view('catalogue', ['catalogueData' => $response]);
    }



    public function getProducts(ProductListRequest $request)
    {
        $data = $request->validated();

        $take = (int)($data['take'] ?? 16);
        $skip = (int)($data['skip'] ?? 0);
        $locale = $data['locale'] ?? app()->getLocale();

        // базовый запрос
        $query = Product::query();



        $aliasMap = [
            // brand
            'brand' => 'product_brand_id', 'brand_id' => 'product_brand_id', 'product_brand_id' => 'product_brand_id',
            // category
            'category' => 'product_category_id', 'category_id' => 'product_category_id', 'product_category_id' => 'product_category_id',
            // ingredients
            'ingredient' => 'ingredients', 'ingredient_id' => 'ingredients', 'ingredients' => 'ingredients',
            // variants
            'variant' => 'variants', 'variant_id' => 'variants', 'variants' => 'variants',
            // volume
            'volume' => 'volume',
            // search
            'q' => 'q', 'search' => 'q',
            // is_active
            'is_active' => 'is_active',
            // price range
            'price_min' => 'price_min', 'price_max' => 'price_max',
            // explicit price field if needed (price_ua / price_eu)
            'price_field' => 'price_field',
        ];

        // --- Собираем только те параметры, которые мы поддерживаем и нормализуем значения ---
        $rawFilters = [];

        foreach ($request->all() as $key => $val) {
            // приводим ключ в простую форму
            $k = trim((string)$key);
            if ($k === '') continue;

            if (!array_key_exists($k, $aliasMap)) continue; // игнорим лишние параметры
            $canon = $aliasMap[$k];

            // нормализуем значение в массив (поддерживаем CSV | массив | одиночное)
            if (is_array($val)) {
                $items = $val;
            } elseif (is_string($val)) {
                $valTrim = trim($val);
                if ($valTrim === '') {
                    continue;
                }
                if (strpos($valTrim, ',') !== false) {
                    $parts = array_filter(array_map('trim', explode(',', $valTrim)), function ($v) {
                        return $v !== '';
                    });
                    $items = array_values($parts);
                } else {
                    $items = [$valTrim];
                }
            } elseif (is_null($val)) {
                continue;
            } else {
                // number, bool, etc.
                $items = [$val];
            }

            $rawFilters[$canon] = $items;
        }

        // --- Применяем фильтры ---

        // product_brand_id
        if (!empty($rawFilters['product_brand_id'])) {
            $ids = array_values(array_filter(array_map(function ($v) {
                return is_numeric($v) ? (int)$v : null;
            }, $rawFilters['product_brand_id'])));
            if (!empty($ids)) $query->whereIn('product_brand_id', $ids);
        }

        // product_category_id
        if (!empty($rawFilters['product_category_id'])) {
            $ids = array_values(array_filter(array_map(function ($v) {
                return is_numeric($v) ? (int)$v : null;
            }, $rawFilters['product_category_id'])));
            if (!empty($ids)) $query->whereIn('product_category_id', $ids);
        }

        // ingredients: поддерживаем OR (по умолчанию) и AND (если ingredients_mode=and)
        if (!empty($rawFilters['ingredients'])) {
            $ingredientIds = array_values(array_filter(array_map(function ($v) {
                return is_numeric($v) ? (int)$v : null;
            }, $rawFilters['ingredients'])));
            if (!empty($ingredientIds)) {
                $mode = strtolower($request->input('ingredients_mode', 'or'));
                if ($mode === 'and') {
                    // каждое указанное ingredient должно присутствовать (AND)
                    foreach ($ingredientIds as $ingId) {
                        $query->whereHas('ingredients', function ($q) use ($ingId) {
                            $q->where('ingredients.id', $ingId);
                        });
                    }
                } else {
                    // хотя бы один из ингредиентов (OR)
                    $query->whereHas('ingredients', function ($q) use ($ingredientIds) {
                        $q->whereIn('ingredients.id', $ingredientIds);
                    });
                }
            }
        }

        // variants
        if (!empty($rawFilters['variants'])) {
            $variants = array_values(array_filter(array_map(function ($v) {
                return is_numeric($v) ? (int)$v : null;
            }, $rawFilters['variants'])));
            if (!empty($variants)) {
                $query->whereHas('variants', function ($q) use ($variants) {
                    $q->whereIn('variants.id', $variants);
                });
            }
        }

        // volume (строковые значения, например "30 ml")
        if (!empty($rawFilters['volume'])) {
            $vols = array_values(array_filter(array_map('trim', $rawFilters['volume'])));
            if (!empty($vols)) {
                $query->whereIn('volume', $vols);
            }
        }

        // price range: используем price_field (price_eu|price_ua) по-умолчанию price_eu
        $priceField = in_array($request->input('price_field', ''), ['price_ua', 'price_eu'], true)
            ? $request->input('price_field') : 'price_eu';

        if (!empty($rawFilters['price_min'])) {
            $min = $rawFilters['price_min'][0];
            if (is_numeric($min)) {
                $query->where($priceField, '>=', (float)$min);
            }
        }
        if (!empty($rawFilters['price_max'])) {
            $max = $rawFilters['price_max'][0];
            if (is_numeric($max)) {
                $query->where($priceField, '<=', (float)$max);
            }
        }

        // q — текстовый поиск (если несколько частей — объединяем через пробел)
        if (!empty($rawFilters['q'])) {
            $qParts = array_filter(array_map('trim', $rawFilters['q']));
            if (!empty($qParts)) {
                $search = implode(' ', $qParts);
                $query->where(function ($qq) use ($search, $locale) {
                    // простая реализация: article, code, name (для json-полей можно улучшить)
                    $qq->where('article', 'like', "%{$search}%")
                        ->orWhere('code', 'like', "%{$search}%")
                        ->orWhere('name', 'like', "%{$search}%"); // если name — json, можно заменить на ->> локаль
                });
            }
        }

        // is_active
        if (!empty($rawFilters['is_active'])) {
            $val = (string)($rawFilters['is_active'][0] ?? '');
            if ($val !== '') {
                if ($val === '0' || strtolower($val) === 'false') {
                    $query->where('is_active', false);
                } else {
                    $query->where('is_active', true);
                }
            }
        }

        // --- Сортировка ---
        $allowedSorts = ['order', 'id', 'price_ua', 'price_eu', 'created_at', 'name'];
        if ($sort = $request->input('sort')) {
            [$field, $dir] = array_pad(explode(':', $sort, 2), 2, null);
            $dir = $dir && strtolower($dir) === 'desc' ? 'desc' : 'asc';
            if (in_array($field, $allowedSorts, true)) {
                if ($field === 'name') {
                    $locale = $request->input('locale', app()->getLocale());
                    $locale = preg_replace('/[^a-zA-Z0-9_\-]/', '', $locale);
                    $driver = \DB::getDriverName();
                    if ($driver === 'mysql') {
                        $jsonExpr = "JSON_UNQUOTE(JSON_EXTRACT(`name`, '$.\"{$locale}\"'))";
                        $query->orderByRaw("{$jsonExpr} {$dir}");
                    } elseif ($driver === 'pgsql' || $driver === 'postgres') {
                        $query->orderByRaw("name ->> '{$locale}' {$dir}");
                    } else {
                        $query->orderBy('name', $dir);
                    }
                } else {
                    $query->orderBy($field, $dir);
                }
            } else {
                $query->ordered();
            }
        } else {
            $query->ordered();
        }

        // --- total before limiting ---
        $total = (clone $query)->toBase()->getCountForPagination();

        // columns
        $select = [
            'id', 'article', 'code', 'slug', 'name', 'subtitle', 'price_ua', 'price_eu', 'volume', 'position',
            'is_active', 'product_brand_id', 'product_category_id',
            'order', 'created_at'
        ];
        $query->select($select);

        // eager load (with)
        $withRaw = array_filter(array_map('trim', explode(',', $request->input('with', ''))));
        $allowedWith = ['brand', 'category', 'variants', 'ingredients'];
        $with = [];
        foreach ($withRaw as $r) {
            if (!in_array($r, $allowedWith, true)) continue;
            if ($r === 'brand') {
                $with['brand'] = function ($q) {
                    $q->select('id', 'name');
                };
            } elseif ($r === 'category') {
                $with['category'] = function ($q) {
                    $q->select('id', 'name');
                };
            } elseif ($r === 'variants') {
                $with['variants'] = function ($q) {
                    $q->select('variants.id', 'variants.name');
                };
            } elseif ($r === 'ingredients') {
                $with['ingredients'] = function ($q) {
                    $q->select('ingredients.id', 'ingredients.name');
                };
            }
        }
        if (!empty($with)) $query->with($with);

        // пагинация
        $items = $query->skip($skip)->take($take)->get();

        return ProductResource::collection($items)
            ->additional([
                'meta' => [
                    'total' => (int)$total,
                    'count' => $items->count(),
                    'take' => (int)$take,
                    'skip' => (int)$skip,
                ],
                'status' => 'OK',
            ]);
    }


}
