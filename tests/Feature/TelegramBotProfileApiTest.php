<?php

namespace Tests\Feature;

use App\Models\SiteSetting;
use App\Models\User;
use App\Services\AppointmentNotificationSettings;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TelegramBotProfileApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_bot_registers_and_refreshes_profile_while_subscription_stays_admin_managed(): void
    {
        Sanctum::actingAs(User::factory()->create(['telegram_id' => 999999]));

        $this->postJson('/api/store-user', [
            'telegram_id' => 123456,
            'first_name' => 'First',
            'username' => 'old_login',
        ])->assertCreated()
            ->assertJsonPath('profile.username', 'old_login')
            ->assertJsonPath('statuses.enabled', false);

        $profile = User::query()->where('telegram_id', 123456)->firstOrFail();
        $setting = SiteSetting::query()
            ->where('key', AppointmentNotificationSettings::KEY)
            ->firstOrFail();
        $config = json_decode($setting->value, true);
        $config['telegram_recipients_migrated'] = true;
        $config['telegram_profile_ids'] = [$profile->id];
        $setting->update(['value' => json_encode($config)]);

        $this->postJson('/api/store-user', [
            'telegram_id' => 123456,
            'first_name' => 'Updated',
            'last_name' => 'Manager',
            'username' => 'new_login',
        ])->assertOk()
            ->assertJsonPath('profile.username', 'new_login')
            ->assertJsonPath('statuses.enabled', true);

        $this->getJson('/api/user/regions?telegram_id=123456')
            ->assertOk()
            ->assertJsonPath('statuses.enabled', true);

        $this->postJson('/api/user/change-region', [
            'telegram_id' => 123456,
            'region' => 'dubai',
        ])->assertStatus(409)
            ->assertJsonPath('message', 'Подписками теперь управляет администратор сайта.')
            ->assertJsonPath('statuses.enabled', true);

        $this->assertDatabaseHas('users', [
            'telegram_id' => 123456,
            'telegram_login' => 'new_login',
            'telegram_name' => 'Updated Manager',
        ]);
    }
}
