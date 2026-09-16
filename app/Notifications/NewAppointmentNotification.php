<?php

namespace App\Notifications;

use App\Models\Appointment;
use App\Notifications\Channels\TelegramChannel;
use App\Services\AppointmentNotificationContent;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewAppointmentNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public int $timeout = 60;

    public bool $failOnTimeout = true;

    /** @var array<int, int> */
    public array $backoff = [5, 30];

    public function __construct(
        public Appointment $appointment,
        private string $channel,
    ) {
        $this->onQueue('notifications');
        $this->afterCommit();
    }

    public function via(object $notifiable): array
    {
        return $this->channel === 'telegram'
            ? [TelegramChannel::class]
            : ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $content = new AppointmentNotificationContent($this->appointment);

        return (new MailMessage)
            ->subject($content->title())
            ->markdown('mail.appointments.new', ['content' => $content]);
    }

    public function toTelegram(object $notifiable): string
    {
        return (new AppointmentNotificationContent($this->appointment))->toTelegramHtml();
    }
}
