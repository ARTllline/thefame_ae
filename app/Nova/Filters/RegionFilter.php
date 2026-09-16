<?php

namespace App\Nova\Filters;

use Illuminate\Http\Request;
use Laravel\Nova\Filters\Filter;
use App\Models\Region;

class RegionFilter extends Filter
{
    /**
     * Компонент фильтра.
     *
     * @var string
     */
    public $component = 'select-filter';

    /**
     * Применяет фильтр к запросу.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @param mixed $value
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function apply(Request $request, $query, $value)
    {
        return $query->where('region_id', $value);
    }

    /**
     * Возвращает список доступных опций фильтра.
     *
     * Здесь мы получаем все регионы из базы и возвращаем массив,
     * где ключ – это название региона для отображения, а значение – идентификатор региона.
     *
     * @param \Illuminate\Http\Request $request
     * @return array
     */
    public function options(Request $request)
    {
        // Пример: если в модели Region есть поля 'id' и 'name'
        return Region::all()->pluck('id', 'name')->toArray();
    }
}
