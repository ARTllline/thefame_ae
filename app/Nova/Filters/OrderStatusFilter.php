<?php

namespace App\Nova\Filters;

use Illuminate\Http\Request;
use Laravel\Nova\Filters\Filter;

class OrderStatusFilter extends Filter
{
    /**
     * The filter's component.
     *
     * @var string
     */
    public $component = 'select-filter';

    public function name()
    {
        return 'Статус заказа';
    }

    /**
     * Apply the filter to the given query.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  mixed  $value
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function apply(Request $request, $query, $value)
    {
        if ($value === 'all' || $value === null) {
            return $query;
        }
        return $query->where('status', $value);
    }

    /**
     * The options for the filter (label => value).
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function options(Request $request)
    {
        return [
            'Все'        => 'all',
            'В ожидании' => 'pending',
            'В обработке' => 'processing',
            'Оплачен'    => 'paid',
            'Отменён'    => 'cancelled',
            'Возвращён'  => 'refunded',
        ];
    }
}
