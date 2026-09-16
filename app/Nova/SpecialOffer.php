<?php

namespace App\Nova;

use App\Models\SpecialOffer as SpecialOfferModel;
use App\Nova\Filters\RegionFilter;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;
use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;
use Outl1ne\NovaSortable\Traits\HasSortableRows;

class SpecialOffer extends Resource
{
    use HasSortableRows;

    public static $model = SpecialOfferModel::class;

    public static $title = 'title';

    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Спецпредложения');
    }

    public static function singularLabel()
    {
        return __('Спецпредложение');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Images::make('Изображение', 'main')
                ->conversionOnIndexView('webp')
                ->fullSize(),

            Text::make('Заголовок', 'title')
                ->translatable()
                ->sortable(),

            Textarea::make('Подзаголовок', 'subtitle')
                ->translatable()
                ->sortable(),

            Textarea::make('Описание', 'description')
                ->translatable()
                ->alwaysShow(),

            Text::make('Цена', 'price')
                ->sortable()
                ->rules('nullable', 'numeric'),

            Text::make('Старая цена', 'old_price')
                ->sortable()
                ->rules('nullable', 'numeric'),


            Text::make('Заголовок «О предложении»', 'about_title')
                ->translatable(),

            Textarea::make('Текст «О предложении»', 'about_text')
                ->translatable()
                ->alwaysShow(),

            BelongsTo::make('Регион', 'region', Region::class)
                ->sortable()->nullable(),
        ];
    }

    public function filters(Request $request)
    {
        return [
            new RegionFilter,
        ];
    }
}
