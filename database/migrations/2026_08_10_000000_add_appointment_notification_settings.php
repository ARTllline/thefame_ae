<?php

use App\Services\AppointmentNotificationSettings;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('site_settings', function (Blueprint $table) {
            $table->text('value')->change();
        });

        if (! DB::table('site_settings')->where('key', AppointmentNotificationSettings::KEY)->exists()) {
            DB::table('site_settings')->insert([
                'key' => AppointmentNotificationSettings::KEY,
                'value' => json_encode(config('notifications.appointments.defaults'), JSON_UNESCAPED_UNICODE),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        DB::table('site_settings')->where('key', AppointmentNotificationSettings::KEY)->delete();
    }
};
