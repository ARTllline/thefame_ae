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
        Schema::create('service_variant_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('variant_id')
                ->constrained('service_variants')
                ->cascadeOnDelete();
            $table->json('name')->nullable();                         // 'ЛОБ', '3 сеанса', 'Стилист' и т.д.
            $table->decimal('price', 10, 2);              // числовая стоимость
            $table->string('currency_code', 6)->nullable();           // дублируем для удобства (или берём из regions)
            $table->integer('order')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_variant_prices');
    }
};
