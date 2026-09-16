<?php

namespace App\Nova;

use Illuminate\Http\Request;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Http\Requests\NovaRequest;

class User extends Resource
{
    public static function indexQuery(NovaRequest $request, $query)
    {
        return $query->where('id', '!=', 1);
    }

    public static function label()
    {
        return __('Telegram-профили');
    }

    public static function singularLabel()
    {
        return __('Telegram-профиль');
    }

    public static $model = \App\Models\User::class;

    public static $title = 'telegram_login';

    public static $search = [
        'id', 'telegram_id', 'telegram_login', 'telegram_name',
    ];

    public function fields(NovaRequest $request)
    {
        return [
            Text::make('Telegram ID', 'telegram_id')->sortable(),
            Text::make('Логин', 'telegram_login')
                ->displayUsing(fn ($login) => $login ? '@'.ltrim($login, '@') : '—')
                ->sortable(),
            Text::make('Имя', 'telegram_name')->sortable(),
        ];
    }

    /**
     * Get the cards available for the request.
     *
     * @return array
     */
    public function cards(NovaRequest $request)
    {
        return [];
    }

    /**
     * Get the filters available for the resource.
     *
     * @return array
     */
    public function filters(NovaRequest $request)
    {
        return [];
    }

    /**
     * Get the lenses available for the resource.
     *
     * @return array
     */
    public function lenses(NovaRequest $request)
    {
        return [];
    }

    /**
     * Get the actions available for the resource.
     *
     * @return array
     */
    public function actions(NovaRequest $request)
    {
        return [];
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
