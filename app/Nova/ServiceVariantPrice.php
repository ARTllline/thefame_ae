<?php
// app/Nova/VariantPrice.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Resource;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\Text;
use Outl1ne\NovaSortable\Traits\HasSortableRows;

class ServiceVariantPrice extends Resource
{
    use HasSortableRows;
    public static $perPageViaRelationship = 50;
    public static $model  = \App\Models\ServiceVariantPrice::class;
    public static $title  = 'name';
    public static $search = [
        'id', 'name->en', 'name->ru', 'name->uk'
    ];

    public static function label()
    {
        return __('Цены');
    }

    public static function singularLabel()
    {
        return __('Цену');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            BelongsTo::make('Вариант', 'variant', ServiceVariant::class)
                ->sortable()
                ->rules('required'),

            Text::make('Название', 'name')
                ->translatable(),

            Text::make('Цена', 'price')
                ->rules('required', 'numeric'),

            Text::make('Валюта', 'currency_code')
                ->rules('max:6'),
        ];
    }

    public static function redirectAfterCreate(Request $request, $resource)
    {
        return '/resources/service-variants/' . $resource->variant_id;
    }

    public static function redirectAfterUpdate(Request $request, $resource)
    {
        return '/resources/service-variants/' . $resource->variant_id;
    }
}
