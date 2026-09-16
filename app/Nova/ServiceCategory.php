<?php
// app/Nova/ServiceCategory.php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Resource;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Fields\HasMany;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;

class ServiceCategory extends Resource
{
    use HasSortableRows;

    public static $model  = \App\Models\ServiceCategory::class;
    public static $title  = 'id';
    public static $search = [
        'id'
    ];

    public static function label()
    {
        return __('Категории услуг');
    }

    public static function singularLabel()
    {
        return __('Категорию услуг');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),
        ];
    }
}
