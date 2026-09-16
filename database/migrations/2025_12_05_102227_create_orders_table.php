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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique(); // например ORD-20251126-0001
            $table->string('status')->default('pending')->index()->comment('pending, paid, cancelled, refunded'); // pending, paid, cancelled, refunded...

            $table->string('fname')->nullable();
            $table->string('lname')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();

            $table->decimal('products_total', 14, 2)->default(0); // в копейках
            $table->decimal('total', 14, 2)->default(0); // в копейках
            $table->integer('total_items')->default(0);
            $table->string('currency', 3)->default('UAH');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
