<?php

namespace App\Nova;

use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Boolean;
use Laravel\Nova\Http\Requests\NovaRequest;

class PromoBanner extends Resource
{
    public static $model = \App\Models\PromoBanner::class;
    public static $title = 'id';

    public static function label()
    {
        return __('Акційні промо');
    }

    public static function singularLabel()
    {
        return __('Акційні промо');
    }

    public function fields(NovaRequest $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Текст', 'content')
                ->translatable([
                    'uk' => 'Українська',
                    'en' => 'English',
                    'ru' => 'Русский',
                ])
                ->rules('required'),

            Text::make('Ссылка', 'link'),

            Boolean::make('Активен', 'is_active'),
        ];
    }
}
