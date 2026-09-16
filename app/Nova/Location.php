<?php

namespace App\Nova;


use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\HasMany;
use Laravel\Nova\Fields\Textarea;


use App\Nova\Filters\RegionFilter;
class Location extends Resource
{

    public static $model = \App\Models\Location::class;
    public static $title = 'title';
    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Локации');
    }

    public static function singularLabel()
    {
        return __('Локацию');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Адрес', 'title')
                ->translatable(),

            Text::make('Район', 'subtitle')
                ->translatable(),

            Text::make('Телефон', 'phone'),
            Text::make('Почта', 'email'),
            Text::make('Ссылка на карту', 'map')->hideFromIndex(),


        ];
    }
}
