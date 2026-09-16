<?php

namespace App\Listeners;

use App\Events\AppointmentCreated;
use App\Notifications\NewAppointmentNotification;
use App\Services\AppointmentNotificationSettings;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;

class SendAppointmentNotifications implements ShouldQueueAfterCommit
{
    public string $queue = 'notifications';

    public int $tries = 3;

    public int $timeout = 60;

    public bool $failOnTimeout = true;

    /** @var array<int, int> */
    public array $backoff = [5, 30];

    public function __construct(private AppointmentNotificationSettings $settings) {}

    public function handle(AppointmentCreated $event): void
    {
        try {
            if ($this->settings->emailEnabled()) {
                foreach ($this->settings->emailRecipients() as $email) {
                    $this->sendSafely(
                        'email',
                        $email,
                        fn () => Notification::route('mail', $email)
                            ->notify(new NewAppointmentNotification($event->appointment, 'mail')),
                        $event->appointment->getKey(),
                    );
                }
            }

            if ($this->settings->telegramEnabled()) {
                foreach ($this->settings->telegramRecipients() as $chatId) {
                    $this->sendSafely(
                        'telegram',
                        $chatId,
                        fn () => Notification::route('telegram', $chatId)
                            ->notify(new NewAppointmentNotification($event->appointment, 'telegram')),
                        $event->appointment->getKey(),
                    );
                }
            }
        } catch (\Throwable $exception) {
            Log::error('Appointment notification processing failed.', [
                'appointment_id' => $event->appointment->getKey(),
                'exception' => $exception,
            ]);
        }
    }

    private function sendSafely(
        string $channel,
        string $recipient,
        callable $send,
        int|string $appointmentId,
    ): void {
        try {
            $send();
        } catch (\Throwable $exception) {
            Log::error('Appointment notification delivery failed.', [
                'appointment_id' => $appointmentId,
                'channel' => $channel,
                'recipient' => $recipient,
                'exception' => $exception,
            ]);
        }
    }
}
