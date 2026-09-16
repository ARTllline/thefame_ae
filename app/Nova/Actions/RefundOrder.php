<?php

namespace App\Nova\Actions;

use Laravel\Nova\Actions\Action;
use Laravel\Nova\Fields\ActionFields;
use Illuminate\Support\Collection;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;

class RefundOrder extends Action
{
    public $name = 'Возврат средств (Refund)';

    public function handle(ActionFields $fields, Collection $models)
    {
        foreach ($models as $order) {
            if ($order->status !== 'paid') {
                return Action::danger("Только оплаченные заказы можно возвращать. Заказ #{$order->id} имеет статус {$order->status}.");
            }

            // TODO: вызов сервиса возврата: PaymentService::refund($order)
            // Пример-псевдо:
            // $result = app(\App\Services\PaymentService::class)->refund($order);
            // if (! $result->success) { return Action::danger("Ошибка возврата для заказа #{$order->id}"); }

            // Обновляем статус
            $order->status = 'refunded';
            $order->save();

            // Лог/событие
            // event(new \App\Events\OrderRefunded($order));
        }

        return Action::message('Выбранные заказы помечены как "Возвращён".');
    }

    public function fields(NovaRequest $request)
    {
        return [
            Textarea::make('Комментарий (опционально)', 'comment')->rows(3),
        ];
    }
}
