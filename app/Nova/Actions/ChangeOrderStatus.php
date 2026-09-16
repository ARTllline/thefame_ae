<?php

namespace App\Nova\Actions;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Laravel\Nova\Actions\Action;
use Laravel\Nova\Fields\Select;
use Laravel\Nova\Fields\ActionFields;
use Illuminate\Support\Collection;
use Laravel\Nova\Http\Requests\NovaRequest;

class ChangeOrderStatus extends Action
{
    use InteractsWithQueue, Queueable;

    public $name = 'Сменить статус заказа';

    /**
     * Выполняется на выбранных ресурсах.
     *
     * @param  \Laravel\Nova\Fields\ActionFields  $fields
     * @param  \Illuminate\Support\Collection  $models
     * @return mixed
     */
    public function handle(ActionFields $fields, Collection $models)
    {
        $newStatus = $fields->status;

        foreach ($models as $order) {
            // Опционально: проверяем разрешённые переходы
            if (! $this->isAllowedTransition($order->status, $newStatus)) {
                return Action::danger("Переход {$order->status} → {$newStatus} запрещён для заказа #{$order->id}.");
            }

            // Выполняем побочную логику централизовано — вызываем метод модели или событие
            // Например: $order->changeStatus($newStatus, auth()->user());
            $order->status = $newStatus;
            $order->save();

            // Если нужен лог/уведомление — можно бросать событие:
            // event(new \App\Events\OrderStatusChanged($order, $newStatus));
        }

        return Action::message("Статус изменён на «{$newStatus}» для выбранных заказов.");
    }

    public function fields(NovaRequest $request)
    {
        return [
            Select::make('Новый статус', 'status')
                ->options([
                    'pending'    => 'В ожидании',
                    'processing' => 'В обработке',
                    'paid'       => 'Оплачен',
                    'cancelled'  => 'Отменён',
                    'refunded'   => 'Возвращён',
                ])
                ->rules('required'),
        ];
    }

    protected function isAllowedTransition(string $current, string $target): bool
    {
        // Пример допустимых переходов — подредактируй под бизнес-логику
        $allowed = [
            'pending' => ['processing', 'cancelled', 'paid'],
            'processing' => ['paid', 'cancelled', 'refunded'],
            'paid' => ['refunded'],
            'cancelled' => [],
            'refunded' => [],
        ];

        return in_array($target, $allowed[$current] ?? []);
    }
}
