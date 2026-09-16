<?php

namespace App\Nova;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\Field;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Select;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\HasMany;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;

use App\Nova\Filters\RegionFilter;
class Device extends Resource
{
    use HasSortableRows;


    public static $model = \App\Models\Device::class;
    public static $title = 'title';
    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Аппараты');
    }

    public static function singularLabel()
    {
        return __('Аппарат');
    }

    public function filters(Request $request)
    {
        return [
            new RegionFilter,
        ];
    }


    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Images::make('Изображения', 'images')
                ->conversionOnIndexView('webp')
                ->fullSize(),

            Text::make('Название', 'title')
                ->translatable(),

            Textarea::make('Описание', 'description')
                ->translatable()
                ->alwaysShow(),

            Text::make('Ссылка', 'link')
                ->displayUsing(function ($value) {
                    if (!$value) return null;
                    return "<a href=\"{$value}\" target=\"_blank\"
            style=\"
                display:inline-block;
                background-color:#3490dc;
                color:white;
                padding:6px 12px;
                border-radius:6px;
                text-decoration:none;
                box-shadow:0 2px 6px rgba(0,0,0,0.2);
                font-weight:600;
                font-size:14px;
            \"
        >
            ПЕРЕЙТИ
        </a>";
                })
                ->asHtml(),

            BelongsTo::make('Регион', 'region', Region::class)
                ->sortable()->nullable(),

        ];
    }
}
