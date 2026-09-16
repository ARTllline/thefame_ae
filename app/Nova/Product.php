<?php

namespace App\Nova;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\BelongsToMany;
use Laravel\Nova\Fields\Boolean;
use Laravel\Nova\Fields\Field;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Number;
use Laravel\Nova\Fields\Select;
use Laravel\Nova\Fields\Slug;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\HasMany;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;
use Laravel\Nova\Panel;
use Naif\ToggleSwitchField\ToggleSwitchField;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;

use App\Nova\Filters\RegionFilter;
use ZiffMedia\NovaSelectPlus\SelectPlus;

class Product extends Resource
{
    use HasSortableRows;

    public static $perPageOptions = [
        100,
        150,
        200,
    ];
    public static $perPageViaRelationship = 25;
    public static $model = \App\Models\Product::class;
    public static $title = 'name';
    public static $search = [
        'id', 'name->en', 'name->ru', 'name->uk'
    ];

    public static function label()
    {
        return __('Товары');
    }

    public static function singularLabel()
    {
        return __('Товар');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            ToggleSwitchField::make('Активен','is_active')
                ->color('#3AB95A'),

            Slug::make('Ключ', 'slug')->rules('max:255')->sortable()->from('name')->hideFromIndex(),
            Text::make('Артикул', 'article'),
            Text::make('Код', 'code'),
            Select::make('Размер', 'position')
                ->options(function () {
                    return [
                        '1x1' => 'Обычная',
                        '2x2' => 'Большая',
                        '2x1' => 'Широкая',
                        '1x2' => 'Высокая',
                    ];
                })->hideFromIndex(),
            new Panel('Контент', $this->mainFields()),

            BelongsTo::make('Бренд', 'brand', ProductBrand::class)->nullable(),
            BelongsTo::make('Категория', 'category', ProductCategory::class)->nullable(),

            SelectPlus::make('Ингредиенты', 'ingredients', Ingredient::class)
                ->label('name'),
            SelectPlus::make('Промо вариации', 'variants', Variant::class)
                ->label('name'),

            BelongsToMany::make('Ингредиенты', 'ingredients', Ingredient::class),
            BelongsToMany::make('Промо вариации', 'variants', Variant::class),
        ];
    }

    protected function mainFields()
    {
        return [
            // Если есть Translatable пакет, заменить на Translatable fields
            Images::make('Изображения', 'images')
                ->conversionOnIndexView('webp')
                ->fullSize(),

            Text::make('Название', 'name')
                ->translatable(),

            Text::make('Подзаголовок', 'subtitle')
                ->translatable()->hideFromIndex(),

//            Textarea::make('Краткое описание', 'short_description')
//                ->help('JSON for localized short description')
//                ->nullable()
//                ->translatable(),

            Textarea::make('Описание', 'description')
                ->help('JSON for localized description')
                ->nullable()
                ->translatable(),

            Number::make('Цена Грн', 'price_ua')->step(0.01),
            Number::make('Цена Евро', 'price_eu')->step(0.01),
            Text::make('Объем', 'volume')->nullable(),
        ];
    }
}
