<?php
// app/Nova/ServiceCategory.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsToMany;
use Laravel\Nova\Resource;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Fields\HasMany;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;
use ZiffMedia\NovaSelectPlus\SelectPlus;

class Category extends Resource
{
    use HasSortableRows;

    public static $model  = \App\Models\Category::class;
    public static $title  = 'title';
    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Категории');
    }

    public static function singularLabel()
    {
        return __('Категория');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Название', 'title')
                ->translatable(),

            Textarea::make('Описание', 'description')
                ->translatable()
                ->alwaysShow(),

            Textarea::make('SEO текст', 'seo_text')->translatable()->nullable(),

            SelectPlus::make('Услуги', 'services', Service::class)
                ->label(fn ($state) => $state->title . ' (' . $state->region->name . ')')
                ->usingDetailLabel(fn($models) => $models->pluck('title'))
                ->reorderable('order'),


            BelongsToMany::make('Услуги', 'services', Service::class)
        ];
    }
}
