<?php

namespace App\Nova\Metrics;

use App\Models\Product;
use Laravel\Nova\Metrics\Value;
use Illuminate\Http\Request;
use App\Models\Service;

class TotalProducts extends Value
{
    /**
     * Вычисление значения карточки.
     *
     * @param Request $request
     * @return mixed
     */
    public function calculate(Request $request)
    {
        return $this->result(Product::count());
    }

    /**
     * Название карточки.
     *
     * @return string
     */
    public function name()
    {
        return __('Всего товаров');
    }
}
