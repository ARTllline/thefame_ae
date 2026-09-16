<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('abouts') && ! Schema::hasColumn('abouts', 'label_dubai')) {
            Schema::table('abouts', function (Blueprint $table) {
                $table->json('label_dubai')->nullable();
            });
        }

        if (Schema::hasTable('categories') && ! Schema::hasColumn('categories', 'seo_text')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->json('seo_text')->nullable();
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('abouts') && Schema::hasColumn('abouts', 'label_dubai')) {
            Schema::table('abouts', function (Blueprint $table) {
                $table->dropColumn('label_dubai');
            });
        }

        if (Schema::hasTable('categories') && Schema::hasColumn('categories', 'seo_text')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->dropColumn('seo_text');
            });
        }
    }
};
