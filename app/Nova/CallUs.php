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
class CallUs extends Resource
{
    use HasSortableRows;


    public static $model = \App\Models\CallUs::class;
    public static $title = 'text';
    public static $search = [
        'id', 'text'
    ];

    public static function label()
    {
        return __('Контакты');
    }

    public static function singularLabel()
    {
        return __('Контакт');
    }


    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Textarea::make('Текст', 'text')
                ->translatable()
                ->alwaysShow(),
            Text::make('Телефон Київ', 'phone_ua'),
            Text::make('Почта Київ', 'email_ua'),
            Text::make('Телефон Dubai', 'phone_dubai'),
            Text::make('Почта Dubai', 'email_dubai'),
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
