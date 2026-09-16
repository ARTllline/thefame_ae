<?php

namespace Tests\Feature;

use App\Models\SiteSetting;
use App\Nova\AppointmentNotificationSetting as AppointmentNotificationSettingResource;
use App\Services\AppointmentNotificationSettings;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Validator;
use Laravel\Nova\Http\Requests\NovaRequest;
use Laravel\Nova\Panel;
use Tests\TestCase;

class AppointmentNotificationNovaSettingsTest extends TestCase
{
    use RefreshDatabase;

    public function test_nova_fields_validate_and_persist_the_aggregate_setting(): void
    {
        $setting = SiteSetting::query()
            ->where('key', AppointmentNotificationSettings::KEY)
            ->firstOrFail();
        $profile = \App\Models\User::factory()->create([
            'telegram_id' => 123456,
            'telegram_login' => 'manager_kyiv',
        ]);

        $request = NovaRequest::create('/nova-api/appointment-notification-settings/'.$setting->id, 'PUT', [
            'email_enabled' => '0',
            'email_recipients' => json_encode([
                'Owner' => 'owner@example.com',
                'Second' => 'second@example.com',
            ]),
            'telegram_enabled' => '1',
            'telegram_profiles' => json_encode([$profile->id]),
            'telegram_direct_recipients' => "-100123\n@thefame_channel",
        ]);

        $resource = new AppointmentNotificationSettingResource($setting);
        $fields = collect($resource->fields($request))
            ->flatMap(fn ($field) => $field instanceof Panel ? $field->data : [$field]);

        foreach ($fields->whereIn('attribute', [
            'email_enabled',
            'email_recipients',
            'telegram_enabled',
            'telegram_profiles',
            'telegram_direct_recipients',
        ]) as $field) {
            $field->fill($request, $setting);
        }

        $setting->save();
        $config = json_decode($setting->fresh()->value, true);

        $this->assertFalse($config['email_enabled']);
        $this->assertSame('owner@example.com', $config['email_recipients']['Owner']);
        $this->assertTrue($config['telegram_enabled']);
        $this->assertSame([$profile->id], $config['telegram_profile_ids']);
        $this->assertSame(['-100123', '@thefame_channel'], $config['telegram_direct_recipients']);
        $this->assertTrue($config['telegram_recipients_migrated']);

        $this->app->instance(NovaRequest::class, $request);
        $profileField = collect((new AppointmentNotificationSettingResource($setting->fresh()))->fields($request))
            ->flatMap(fn ($field) => $field instanceof Panel ? $field->data : [$field])
            ->firstWhere('attribute', 'telegram_profiles');
        $profileField->resolve($setting->fresh());

        $this->assertSame([$profile->id], $profileField->value);
        $this->assertNotEmpty($profileField->jsonSerialize()['options']);

        $invalidRequest = NovaRequest::create('/nova-api/appointment-notification-settings/'.$setting->id, 'PUT', [
            'email_recipients' => json_encode(['Owner' => 'not-an-email']),
        ]);
        $emailField = collect($resource->fields($invalidRequest))
            ->flatMap(fn ($field) => $field instanceof Panel ? $field->data : [$field])
            ->firstWhere('attribute', 'email_recipients');

        $this->assertTrue(Validator::make(
            $invalidRequest->all(),
            $emailField->getUpdateRules($invalidRequest),
        )->fails());
    }

    public function test_edit_fields_resolve_intermediate_regional_telegram_values_without_warnings(): void
    {
        config(['notifications.appointments.site_region' => 'dubai']);

        $allProfile = \App\Models\User::factory()->create(['telegram_id' => 111111]);
        $dubaiProfile = \App\Models\User::factory()->create(['telegram_id' => 333333]);
        $setting = SiteSetting::query()
            ->where('key', AppointmentNotificationSettings::KEY)
            ->firstOrFail();
        $config = json_decode($setting->value, true);
        $config['telegram_recipients_migrated'] = true;
        $config['telegram_profile_ids'] = [
            'all' => [$allProfile->id],
            'dubai' => [$dubaiProfile->id],
        ];
        $config['telegram_direct_recipients'] = [
            'all' => ['-1001'],
            'dubai' => ['-1003'],
        ];
        $setting->update(['value' => json_encode($config)]);

        $request = NovaRequest::create('/nova-api/appointment-notification-settings/'.$setting->id, 'GET');
        $this->app->instance(NovaRequest::class, $request);
        $fields = collect((new AppointmentNotificationSettingResource($setting->fresh()))->fields($request))
            ->flatMap(fn ($field) => $field instanceof Panel ? $field->data : [$field]);
        $profileField = $fields->firstWhere('attribute', 'telegram_profiles');
        $directField = $fields->firstWhere('attribute', 'telegram_direct_recipients');

        $profileField->resolve($setting->fresh());
        $directField->resolve($setting->fresh());

        $this->assertSame([$allProfile->id, $dubaiProfile->id], $profileField->value);
        $this->assertSame("-1001\n-1003", $directField->value);
        $this->assertIsArray($profileField->jsonSerialize());
        $this->assertIsArray($directField->jsonSerialize());
    }
}
