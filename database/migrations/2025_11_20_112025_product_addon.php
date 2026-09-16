<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('slug')->unique()->nullable()->after('name');
            $table->unsignedBigInteger('order')->default(0);
            $table->json('short_description')->nullable();
            $table->json('subtitle')->nullable();
            $table->json('description')->nullable();
            $table->boolean('is_active')->default(true);

            $table->index(['product_category_id', 'product_brand_id']);
            $table->index('slug');
            $table->string('position', 20)->comment('2x2, 2x1,1x2')->nullable();
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
