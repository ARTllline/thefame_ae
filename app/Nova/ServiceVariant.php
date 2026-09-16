<?php
// app/Nova/ServiceVariant.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Resource;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Fields\HasMany;
use Outl1ne\NovaSortable\Traits\HasSortableRows;

class ServiceVariant extends Resource
{
    use HasSortableRows;
    public static $perPageViaRelationship = 15;
    public static $model  = \App\Models\ServiceVariant::class;
    public static $title  = 'title';
    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Варианты услуг');
    }

    public static function singularLabel()
    {
        return __('Вариант услуги');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            BelongsTo::make('Услуга', 'service', Service::class)
                ->sortable()
                ->rules('required'),

            Text::make('Код', 'code')
                ->sortable()
                ->rules('nullable', 'max:100'),

            Text::make('Название', 'title')
                ->translatable(),

            Textarea::make('Описание', 'description')
                ->translatable()
                ->alwaysShow(),

            HasMany::make('Цены', 'prices', ServiceVariantPrice::class),
        ];
    }
}
