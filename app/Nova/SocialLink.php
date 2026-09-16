<?php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Datomatic\NovaIconField\NovaIconField;

class SocialLink extends Resource
{
    public static $model = \App\Models\SocialLink::class;
    public static $title = 'platform';
    public static $search = [
        'id', 'platform', 'url'
    ];

    public static function label()
    {
        return __('Социальные ссылки');
    }

    public static function singularLabel()
    {
        return __('Социальная ссылка');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make(__('Платформа'), 'platform')
                ->sortable()
                ->rules('required', 'max:255'),

            Text::make(__('URL'), 'url')
                ->sortable()
                ->rules('required', 'max:255'),

            NovaIconField::make('Иконка', 'icon')
                ->addButtonText('[ + ]'),

            BelongsTo::make('Регион', 'region', Region::class)
                ->sortable()->nullable(),
        ];
    }
}
