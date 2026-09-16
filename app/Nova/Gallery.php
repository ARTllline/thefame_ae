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
class Gallery extends Resource
{

    public static $model = \App\Models\Gallery::class;
    public static $title = 'title';
    public static $search = [
        'id', 'title->en', 'title->ru', 'title->uk'
    ];

    public static function label()
    {
        return __('Галереи');
    }

    public static function singularLabel()
    {
        return __('Галерея');
    }

    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Название', 'title')
                ->translatable(),

            Images::make('Изображения', 'gallery')
                ->conversionOnIndexView('webp')
                ->fullSize(),

            BelongsTo::make('Регион', 'region', Region::class)
                ->sortable()
                ->rules('required'),
        ];
    }


    public static function authorizedToCreate(Request $request)
    {
        return false;
    }
    public function authorizedToReplicate(Request $request)
    {
        return false;
    }
    public function authorizedToDelete(Request $request)
    {
        return false;
    }
}
