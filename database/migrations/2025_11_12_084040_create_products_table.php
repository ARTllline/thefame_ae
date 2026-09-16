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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('article')->unique()->nullable();
            $table->unsignedBigInteger('code')->unique()->nullable();
            $table->json('name')->nullable();
            $table->string('volume', 50)->nullable();
            $table->decimal('price_ua', 8, 2)->nullable();
            $table->decimal('price_eu', 8, 2)->nullable();
            $table->timestamps();
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
