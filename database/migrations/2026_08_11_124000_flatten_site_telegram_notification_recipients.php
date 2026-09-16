<?php

use App\Services\AppointmentNotificationSettings;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $setting = DB::table('site_settings')
            ->where('key', AppointmentNotificationSettings::KEY)
            ->first();

        if (! $setting) {
            return;
        }

        $config = json_decode($setting->value, true);

        if (! is_array($config)) {
            return;
        }

        $profileIds = $this->localValues($config['telegram_profile_ids'] ?? []);
        $directRecipients = $this->localValues($config['telegram_direct_recipients'] ?? []);

        if (($config['telegram_profile_ids'] ?? []) === $profileIds
            && ($config['telegram_direct_recipients'] ?? []) === $directRecipients) {
            return;
        }

        $config['telegram_profile_ids'] = array_values(array_unique(array_map('intval', $profileIds)));
        $config['telegram_direct_recipients'] = array_values(array_unique(array_map('strval', $directRecipients)));
        $config['telegram_recipients_migrated'] = true;

        DB::table('site_settings')
            ->where('id', $setting->id)
            ->update([
                'value' => json_encode($config, JSON_UNESCAPED_UNICODE),
                'updated_at' => now(),
            ]);
    }

    public function down(): void
    {
        // Regional settings cannot be reconstructed after they become site-local.
    }

    /** @return array<int, mixed> */
    private function localValues(mixed $values): array
    {
        if (! is_array($values)) {
            return [];
        }

        if (array_is_list($values)) {
            return array_values($values);
        }

        return collect(['all', 'dubai'])
            ->flatMap(fn ($scope) => is_array($values[$scope] ?? null) ? $values[$scope] : [])
            ->unique()
            ->values()
            ->all();
    }
};
