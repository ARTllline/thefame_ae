<?php

namespace App\Nova;


use Illuminate\Http\Request;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Naif\ToggleSwitchField\ToggleSwitchField;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
use Ebess\AdvancedNovaMediaLibrary\Fields\Media;

use App\Nova\Filters\RegionFilter;

class Banner extends Resource
{
    public static $model = \App\Models\Banner::class;
    public static $title = 'title';
    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Баннеры');
    }

    public static function singularLabel()
    {
        return __('Баннер');
    }

    public function filters(Request $request)
    {
        return [
            new RegionFilter,
        ];
    }


    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Название', 'title')
                ->translatable(),

            Media::make('Видео Dubai', 'dubai_desktop') // media handles videos
            ->conversionOnIndexView('thumb')
                ->singleMediaRules('max:100000'),
            Media::make('Видео Dubai (моб)', 'dubai_mobile')
                ->conversionOnIndexView('thumb')
                ->singleMediaRules('max:100000'),
            Media::make('Видео Київ', 'kyiv_desktop')
                ->conversionOnIndexView('thumb')
                ->singleMediaRules('max:100000'),
            Media::make('Видео Київ (моб)', 'kyiv_mobile')
                ->conversionOnIndexView('thumb')
                ->singleMediaRules('max:100000'),

            ToggleSwitchField::make('Текущий', 'is_show')
                ->color('#3AB95A'),
        ];
    }
}
//50000
