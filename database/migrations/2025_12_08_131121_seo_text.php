<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('product_categories', function (Blueprint $table) {
            $table->json('seo_text')->nullable();
        });
        Schema::table('product_brands', function (Blueprint $table) {
            $table->json('seo_text')->nullable();
        });
        Schema::table('ingredients', function (Blueprint $table) {
            $table->json('seo_text')->nullable();
        });
        Schema::table('variants', function (Blueprint $table) {
            $table->json('seo_text')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
