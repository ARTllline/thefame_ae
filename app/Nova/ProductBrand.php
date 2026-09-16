<?php
// app/Nova/ServiceCategory.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsTo;
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

class ProductBrand extends Resource
{
    use HasSortableRows;

    public static $model  = \App\Models\ProductBrand::class;
    public static $title  = 'name';
    public static $search = [
        'name'
    ];

    public static function label()
    {
        return __('Бренды товаров');
    }

    public static function singularLabel()
    {
        return __('Бренд товаров');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),
            ToggleSwitchField::make('Активен','is_active')
                ->color('#3AB95A'),
            ToggleSwitchField::make('Отображать в навигации','is_show_nav')
                ->color('#3AB95A'),
            Text::make('Название', 'name'),
            Slug::make('Ключ', 'slug')->rules('max:255')->sortable()->from('name'),
            Textarea::make('SEO текст', 'seo_text')->translatable()->nullable(),

            Text::make('Ссылка на каталог', function () {
                return '<a href="' . route('catalogue.resolve','brand/' . $this->slug) . '" target="_blank">' . route('catalogue.resolve', 'brand/'. $this->slug) . '</a>';
            })->asHtml(),

            HasMany::make('Товары','products', Product::class),

        ];
    }
}
