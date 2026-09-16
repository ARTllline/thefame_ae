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
class About extends Resource
{
    use HasSortableRows;


    public static $model = \App\Models\About::class;
    public static $title = 'code';
    public static $search = [
        'id', 'code'
    ];

    public static function label()
    {
        return __('О нас');
    }

    public static function singularLabel()
    {
        return __('О нас');
    }


    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Text::make('Страница', function (){

                if ($this->code == 'main')
                {
                    return 'Главная';
                }
                if ($this->code == 'full')
                {
                    return '"О нас"';
                }

                return '-';
            }),

            Images::make('Изображения', 'main-dubai')
                ->conversionOnIndexView('webp')
                ->fullSize(),


            Textarea::make('Заголовок', 'label_dubai')
                ->translatable()
                ->alwaysShow(),
            Textarea::make('Текст', 'text_dubai')
                ->translatable()
                ->alwaysShow(),
            Textarea::make('Акцент', 'accent_dubai')
                ->translatable()
                ->alwaysShow(),
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
