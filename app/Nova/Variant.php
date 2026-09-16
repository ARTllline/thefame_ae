<?php
// app/Nova/ServiceCategory.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsToMany;
use Laravel\Nova\Fields\Boolean;
use Laravel\Nova\Fields\Slug;
use Laravel\Nova\Resource;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Fields\HasMany;
use Naif\ToggleSwitchField\ToggleSwitchField;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;

class Variant extends Resource
{
    use HasSortableRows;

    public static $model  = \App\Models\Variant::class;
    public static $title  = 'name';
    public static $search = [
        'name'
    ];

    public static function label()
    {
        return __('Промо вариации');
    }

    public static function singularLabel()
    {
        return __('Промо вариация');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),
            ToggleSwitchField::make('Активен','is_active')
                ->color('#3AB95A'),
            ToggleSwitchField::make('Отображать в навигации','is_show_nav')
                ->color('#3AB95A'),


            Text::make('Название','name')->translatable()->nullable(),
            Textarea::make('Краткое описание','short_description')->translatable()->nullable(),
            Textarea::make('Описание','description')->translatable()->nullable(),

            Slug::make('Ключ','slug')->rules('unique:variants,slug,{{resourceId}}'),
            Textarea::make('SEO текст', 'seo_text')->translatable()->nullable(),

            Text::make('Ссылка на каталог', function () {
                return '<a href="' . route('catalogue.resolve','discovery/' . $this->slug) . '" target="_blank">' . route('catalogue.resolve', 'discovery/'. $this->slug) . '</a>';
            })->asHtml(),

            BelongsToMany::make('Товары','products', Product::class),
        ];
    }
}
