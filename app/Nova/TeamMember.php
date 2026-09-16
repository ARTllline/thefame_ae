<?php

namespace App\Nova;

use App\Nova\Filters\RegionFilter;
use Illuminate\Http\Request;
use Laravel\Nova\Fields\BelongsTo;
use Laravel\Nova\Fields\ID;
use Ebess\AdvancedNovaMediaLibrary\Fields\Images;
use Laravel\Nova\Fields\Text;
use Outl1ne\NovaSortable\Traits\HasSortableRows;
class TeamMember extends Resource
{
    use HasSortableRows;
    public static $model = \App\Models\TeamMember::class;
    public static $title = 'full_name';
    public static $search = [
        'id', 'name', 'position'
    ];

    public static $perPageOptions = [
        50,  // будет выбрано по умолчанию
        100,
        200,
    ];

    public static function label()
    {
        return __('Члены команды');
    }

    public static function singularLabel()
    {
        return __('Член команды');
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

            Images::make('Изображение', 'main')
                ->conversionOnIndexView('webp')->fullSize(),

            Text::make(__('Полное имя'), 'name')
                ->sortable()
                ->rules('required', 'max:255'),

            Text::make(__('Должность'), 'position')
                ->sortable()
                ->rules('required', 'max:255'),

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
                ->sortable()->nullable()

        ];
    }
}
