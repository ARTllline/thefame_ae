<?php

namespace App\Notifications\Channels;

use App\Services\TelegramService;
use Illuminate\Notifications\Notification;

class TelegramChannel
{
    public function __construct(private TelegramService $telegram) {}

    public function send(object $notifiable, Notification $notification): void
    {
        $chatId = $notifiable->routeNotificationFor('telegram');

        if (! $chatId || ! method_exists($notification, 'toTelegram')) {
            return;
        }

        $this->telegram->sendToChat((string) $chatId, $notification->toTelegram($notifiable));
    }
}
