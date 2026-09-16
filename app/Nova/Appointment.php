<?php

namespace App\Nova;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\DateTime;
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
class Appointment extends Resource
{
    use HasSortableRows;


    public static $model = \App\Models\Appointment::class;
    public static $title = 'name';
    public static $search = [
        'id', 'name', 'phone'
    ];

    public static function label()
    {
        return __('Заявки');
    }

    public static function singularLabel()
    {
        return __('Заявка');
    }


    public function fields(Request $request)
    {
        return [
            ID::make()->sortable(),

            Textarea::make('Процедура', 'treatment')->onlyOnDetail(),
            Text::make('Email', 'email')->onlyOnDetail(),
            Text::make('Цель', 'goal')->onlyOnDetail(),
            Text::make('Источник формы / страница', 'from_page')->onlyOnDetail(),
            Text::make('UTM source', 'utm_source')->onlyOnDetail(),
            Text::make('UTM medium', 'utm_medium')->onlyOnDetail(),
            Text::make('UTM campaign', 'utm_campaign')->onlyOnDetail(),
            Text::make('UTM term', 'utm_term')->onlyOnDetail(),
            Text::make('UTM content', 'utm_content')->onlyOnDetail(),
            Text::make('Referrer', 'referrer')->onlyOnDetail(),

            Text::make('Имя', 'name'),
            Text::make('Телефон', 'phone'),
            Text::make('Регион', 'region'),
            //Text::make('Время отправки', 'created_at'),
            DateTime::make('Время отправки', 'created_at')->sortable(),
        ];
    }

    public function authorizeToUpdate(Request $request)
    {
        return false;
    }
    public static function authorizedToCreate(Request $request)
    {
        return false;
    }
    public function authorizedToReplicate(Request $request)
    {
        return false;
    }

}
