<?php

namespace Tests\Feature;

use App\Events\AppointmentCreated;
use App\Listeners\SendAppointmentNotifications;
use App\Models\Appointment;
use App\Notifications\NewAppointmentNotification;
use App\Services\AppointmentNotificationSettings;
use App\Services\TelegramService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldQueueAfterCommit;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Notifications\AnonymousNotifiable;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Notification;
use Mockery;
use RuntimeException;
use Tests\TestCase;

class AppointmentNotificationFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_appointment_response_queues_notifications_without_waiting_for_delivery(): void
    {
        Event::fake([AppointmentCreated::class]);
        Notification::fake();

        $this->postJson('/appointment', [
            'name' => 'Queued Notification',
            'phone' => '+971500000000',
            'region' => 'Dubai',
        ])->assertOk()->assertJson(['success' => true]);

        $this->assertDatabaseHas('appointments', ['name' => 'Queued Notification']);
        Notification::assertNothingSent();
        Event::assertDispatched(AppointmentCreated::class);

        $listener = app(SendAppointmentNotifications::class);
        $this->assertInstanceOf(ShouldQueueAfterCommit::class, $listener);
        $this->assertSame('notifications', $listener->queue);
        $this->assertSame(3, $listener->tries);

        $notification = new NewAppointmentNotification(
            new Appointment([
                'name' => 'Queue Metadata Test',
                'phone' => '+971500000099',
            ]),
            'telegram',
        );
        $this->assertInstanceOf(ShouldQueue::class, $notification);
        $this->assertSame('notifications', $notification->queue);
        $this->assertSame(3, $notification->tries);
        $this->assertSame([5, 30], $notification->backoff);
    }

    public function test_new_appointment_is_saved_and_routed_to_enabled_channels(): void
    {
        Notification::fake();

        $settings = Mockery::mock(AppointmentNotificationSettings::class);
        $settings->shouldReceive('emailEnabled')->once()->andReturnTrue();
        $settings->shouldReceive('emailRecipients')->once()->andReturn([
            'manager@example.com',
            'owner@example.com',
        ]);
        $settings->shouldReceive('telegramEnabled')->once()->andReturnTrue();
        $settings->shouldReceive('telegramRecipients')->once()->andReturn(['-1001234567890']);
        $this->app->instance(AppointmentNotificationSettings::class, $settings);

        $response = $this->postJson('/appointment', [
            'name' => 'Test Client',
            'phone' => '+380000000000',
            'region' => 'Київ',
            'treatment' => 'Consultation',
            'from_page' => 'promo_appointment: https://thefame.ae/en',
        ]);

        $response->assertOk()->assertJson(['success' => true]);
        $this->assertDatabaseHas('appointments', [
            'name' => 'Test Client',
            'phone' => '+380000000000',
            'treatment' => 'Consultation',
            'from_page' => 'promo_appointment: https://thefame.ae/en',
        ]);

        Notification::assertSentOnDemandTimes(NewAppointmentNotification::class, 3);
        Notification::assertSentOnDemand(
            NewAppointmentNotification::class,
            fn ($notification, $channels, AnonymousNotifiable $notifiable) => ($notifiable->routes['telegram'] ?? null) === '-1001234567890'
                && $notification->appointment->name === 'Test Client',
        );
    }

    public function test_disabled_channels_do_not_prevent_saving_the_appointment(): void
    {
        Notification::fake();

        $settings = Mockery::mock(AppointmentNotificationSettings::class);
        $settings->shouldReceive('emailEnabled')->once()->andReturnFalse();
        $settings->shouldReceive('telegramEnabled')->once()->andReturnFalse();
        $this->app->instance(AppointmentNotificationSettings::class, $settings);

        $this->postJson('/appointment', [
            'name' => 'No Notifications',
            'phone' => '+380000000001',
            'region' => 'Dubai',
        ])->assertOk();

        $this->assertDatabaseHas('appointments', ['name' => 'No Notifications']);
        Notification::assertNothingSent();
    }

    public function test_delivery_failure_does_not_rollback_or_fail_the_request(): void
    {
        $settings = Mockery::mock(AppointmentNotificationSettings::class);
        $settings->shouldReceive('emailEnabled')->once()->andReturnFalse();
        $settings->shouldReceive('telegramEnabled')->once()->andReturnTrue();
        $settings->shouldReceive('telegramRecipients')->once()->andReturn(['-1001234567890']);
        $this->app->instance(AppointmentNotificationSettings::class, $settings);

        $telegram = Mockery::mock(TelegramService::class);
        $telegram->shouldReceive('sendToChat')
            ->once()
            ->andThrow(new RuntimeException('Telegram is unavailable.'));
        $this->app->instance(TelegramService::class, $telegram);

        $this->postJson('/appointment', [
            'name' => 'Saved Despite Failure',
            'phone' => '+380000000002',
            'region' => 'Київ',
        ])->assertOk()->assertJson(['success' => true]);

        $this->assertDatabaseHas('appointments', ['name' => 'Saved Despite Failure']);
    }
}
