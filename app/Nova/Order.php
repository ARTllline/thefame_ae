<?php

namespace App\Nova;

use App\Nova\Actions\ChangeOrderStatus;
use App\Nova\Actions\MarkCancelledOrder;
use App\Nova\Actions\MarkPaidOrder;
use App\Nova\Actions\RefundOrder;
use Illuminate\Http\Request;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Number;
use Laravel\Nova\Fields\Select;
use Laravel\Nova\Fields\DateTime;
use Laravel\Nova\Fields\HasMany;
use Laravel\Nova\Fields\Badge;
use Laravel\Nova\Http\Requests\NovaRequest;
use App\Nova\Filters\OrderStatusFilter;

class Order extends Resource
{
    public static $model = \App\Models\Order::class;
    public static $title = 'order_number';
    public static $search = [
        'id', 'order_number', 'email', 'phone', 'fname', 'lname'
    ];

    public static function label()
    {
        return __('Заказы');
    }

    public static function singularLabel()
    {
        return __('Заказ');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Order #', 'order_number')->sortable()->onlyOnIndex(),

            // Цветной статус через Badge
            Badge::make('Статус', 'status')
                ->map([
                    'pending'    => 'warning',    // желтый
                    'processing' => 'info',       // синий
                    'paid'       => 'success',    // зелёный
                    'cancelled'  => 'danger',     // красный
                    'refunded'   => 'danger',     // красный
                ])
                ->labels([
                    'pending'    => 'В ожидании',
                    'processing' => 'В обработке',
                    'paid'       => 'Оплачен',
                    'cancelled'  => 'Отменён',
                    'refunded'   => 'Возвращён',
                ])
                ->sortable(),

            // Для редактирования/способов смены статуса оставим Select (в формах)
            Select::make('Статус (редактирование)', 'status')
                ->options([
                    'pending'    => 'В ожидании',
                    'processing' => 'В обработке',
                    'paid'       => 'Оплачен',
                    'cancelled'  => 'Отменён',
                    'refunded'   => 'Возвращён',
                ])
                ->hideFromIndex()
                ->onlyOnForms()
                ->rules('required'),

            // Billing
            Text::make('Имя', 'fname')->sortable()->rules('nullable', 'string', 'max:255'),
            Text::make('Фамилия', 'lname')->sortable()->rules('nullable', 'string', 'max:255'),
            Text::make('Телефон', 'phone')->sortable()->rules('nullable', 'string', 'max:255'),
            Text::make('Email', 'email')->sortable()->rules('nullable', 'email', 'max:255'),

            // Totals (stored в копейках) — показываем в гривнах (делим на 100)
            Number::make('Сумма товаров, грн', 'products_total')
                ->resolveUsing(function ($value) {
                    if ($value === null) return null;
                    $formatted = number_format($value / 100, 2, '.', ' ');
                    return $formatted;
                })
                ->onlyOnIndex()
                ->sortable()
                ->exceptOnForms(),

            Number::make('Итого, грн', 'total')
                ->resolveUsing(function ($value) {
                    if ($value === null) return null;
                    $formatted = number_format($value / 100, 2, '.', ' ');
                    return $formatted;
                })
                ->onlyOnIndex()
                ->sortable()
                ->exceptOnForms(),

            Number::make('Items', 'total_items')->sortable()->onlyOnIndex(),

            DateTime::make('Создан', 'created_at')->sortable(),

            // Ссылка на позиции заказа
            HasMany::make('Позиции', 'items', OrderItem::class),
        ];
    }

    /**
     * Добавляем фильтры — регистрируем наш фильтр статусов
     */
    public function filters(Request $request)
    {
        return [
            new OrderStatusFilter(),
        ];
    }

    public function actions(Request $request)
    {
        return [
            new MarkPaidOrder(),
            new MarkCancelledOrder(),
            new RefundOrder(),
            new ChangeOrderStatus(),
        ];
    }

    // ... остальные методы (cards, lenses, actions) оставляем без изменений
}
