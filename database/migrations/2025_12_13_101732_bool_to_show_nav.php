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
            $table->boolean('is_show_nav')->default(true);
        });
        Schema::table('product_brands', function (Blueprint $table) {
            $table->boolean('is_show_nav')->default(true);
        });
        Schema::table('ingredients', function (Blueprint $table) {
            $table->boolean('is_show_nav')->default(true);
        });
        Schema::table('variants', function (Blueprint $table) {
            $table->boolean('is_show_nav')->default(true);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

    }
};
