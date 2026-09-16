<?php

namespace App\Nova\Metrics;

use Laravel\Nova\Metrics\Trend;
use Illuminate\Http\Request;
use App\Models\Service;

class NewServicesTrend extends Trend
{
    /**
     * Вычисление тренда.
     *
     * @param Request $request
     * @return mixed
     */
    public function calculate(Request $request)
    {
        return $this->countByDays($request, Service::class);
    }

    /**
     * Название карточки.
     *
     * @return string
     */
    public function name()
    {
        return __('Новые услуги по дням');
    }
}
