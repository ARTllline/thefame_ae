<?php

namespace Tests\Unit;

use App\Models\Appointment;
use App\Notifications\NewAppointmentNotification;
use App\Services\AppointmentNotificationContent;
use stdClass;
use Tests\TestCase;

class AppointmentNotificationContentTest extends TestCase
{
    public function test_it_builds_shared_content_and_escapes_telegram_html(): void
    {
        $appointment = new Appointment([
            'name' => 'Іван <Admin>',
            'phone' => '+380 00 000 00 00',
            'region' => 'Київ',
            'goal' => 'Консультація & запис',
            'utm_source' => 'google',
        ]);
        $appointment->id = 42;
        $appointment->created_at = '2026-08-10 10:00:00';

        $content = new AppointmentNotificationContent($appointment);
        $telegram = $content->toTelegramHtml();

        $this->assertSame('Нова заявка з посадкової сторінки', $content->title());
        $this->assertStringContainsString('<b>Номер заявки:</b> 42', $telegram);
        $this->assertStringContainsString('Іван &lt;Admin&gt;', $telegram);
        $this->assertStringContainsString('Консультація &amp; запис', $telegram);
        $this->assertStringContainsString('<b>UTM source:</b> google', $telegram);

        $mail = (new NewAppointmentNotification($appointment, 'mail'))->toMail(new stdClass);
        $renderedMail = (string) $mail->render();

        $this->assertSame('Нова заявка з посадкової сторінки', $mail->subject);
        $this->assertStringContainsString('Іван &lt;Admin&gt;', $renderedMail);
        $this->assertStringContainsString('Заявка вже збережена', $renderedMail);
    }
}
