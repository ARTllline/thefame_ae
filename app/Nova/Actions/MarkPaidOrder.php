<?php

namespace App\Nova\Actions;

use Laravel\Nova\Actions\Action;
use Laravel\Nova\Fields\ActionFields;
use Illuminate\Support\Collection;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;

class MarkPaidOrder extends Action
{
    public $name = 'Пометить как оплаченный';

    public function handle(ActionFields $fields, Collection $models)
    {
        foreach ($models as $order) {

            // Обновляем статус
            $order->status = 'paid';
            $order->save();

        }

        return Action::message('Выбранные заказы помечены как "Оплаченные".');
    }

    public function fields(NovaRequest $request)
    {
        return [];
    }
}
