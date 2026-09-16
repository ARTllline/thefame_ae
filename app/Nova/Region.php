<?php
// app/Nova/Region.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Resource;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\HasMany;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;

class Region extends Resource
{
    public static $model  = \App\Models\Region::class;
    public static $title  = 'name';
    public static $search = [
        'id', 'code', 'name'
    ];

    public static function label()
    {
        return __('Регионы');
    }

    public static function singularLabel()
    {
        return __('Регион');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Images::make('Изображение', 'main')
                ->conversionOnIndexView('webp')
                ->fullSize(),


            Text::make('Код', 'code')
                ->sortable()
                ->rules('required', 'max:50'),

            Text::make('Название', 'name')
                ->sortable()
                ->rules('required', 'max:255'),

            Text::make('Валюта', 'currency_code')
                ->sortable()
                ->rules('max:6'),

            HasMany::make('Услуги', 'services', Service::class),
        ];
    }


}
