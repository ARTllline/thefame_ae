<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('users') && Schema::hasColumn('users', 'telegram_id')) {
            if (DB::getDriverName() === 'mysql') {
                DB::statement('ALTER TABLE `users` MODIFY `telegram_id` BIGINT NULL');

                return;
            }

            Schema::table('users', function (Blueprint $table) {
                $table->bigInteger('telegram_id')->nullable()->change();
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('users') && Schema::hasColumn('users', 'telegram_id')) {
            if (DB::getDriverName() === 'mysql') {
                DB::statement('ALTER TABLE `users` MODIFY `telegram_id` BIGINT NOT NULL');

                return;
            }

            Schema::table('users', function (Blueprint $table) {
                $table->bigInteger('telegram_id')->nullable(false)->change();
            });
        }
    }
};
