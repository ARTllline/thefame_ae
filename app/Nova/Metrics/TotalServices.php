<?php

namespace App\Nova\Metrics;

use Laravel\Nova\Metrics\Value;
use Illuminate\Http\Request;
use App\Models\Service;

class TotalServices extends Value
{
    /**
     * Вычисление значения карточки.
     *
     * @param Request $request
     * @return mixed
     */
    public function calculate(Request $request)
    {
        return $this->result(Service::count());
    }

    /**
     * Название карточки.
     *
     * @return string
     */
    public function name()
    {
        return __('Всего услуг');
    }
}
