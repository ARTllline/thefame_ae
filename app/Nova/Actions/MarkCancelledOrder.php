<?php

namespace App\Nova\Actions;

use Laravel\Nova\Actions\Action;
use Laravel\Nova\Fields\ActionFields;
use Illuminate\Support\Collection;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;

class MarkCancelledOrder extends Action
{
    public $name = 'Отменить заказ';

    public function handle(ActionFields $fields, Collection $models)
    {
        foreach ($models as $order) {

            // Обновляем статус
            $order->status = 'cancelled';
            $order->save();

        }

        return Action::message('Выбранные заказы помечены как "Отменённые".');
    }

    public function fields(NovaRequest $request)
    {
        return [];
    }
}
