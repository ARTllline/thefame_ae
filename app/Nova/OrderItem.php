<?php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Number;
use Laravel\Nova\Http\Requests\NovaRequest;

class OrderItem extends Resource
{
    public static $model = \App\Models\OrderItem::class;
    public static $title = 'title';
    public static $search = [
        'id', 'title'
    ];

    public static function label()
    {
        return __('Позиции заказов');
    }

    public static function singularLabel()
    {
        return __('Позиция заказа');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            BelongsTo::make('Заказ', 'order', Order::class)->sortable(),

            // если есть ресурс Product — свяжет
            BelongsTo::make('Товар', 'product', Product::class)
                ->nullable()
                ->searchable(),

            Text::make('Название', 'title')->sortable()->rules('nullable', 'string', 'max:255'),

            Number::make('Кол-во', 'quantity')
                ->min(1)
                ->step(1)
                ->sortable()
                ->rules('required', 'integer', 'min:1'),

            // price хранится как decimal(8,2) — показываем и в формах редактирования как обычную decimal
            Number::make('Цена, грн', 'price')
                ->step(0.01)
                ->rules('required', 'numeric')
                ->sortable(),

            // computed line_total (price * quantity), не сохраняется в БД
            Number::make('Сумма, грн', function () {
                if ($this->price === null || $this->quantity === null) return null;
                return round($this->price * $this->quantity, 2);
            })->onlyOnIndex()->sortable(),
        ];
    }
}
