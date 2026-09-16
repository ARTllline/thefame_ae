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
        Schema::create('special_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('region_id')->nullable()
                ->constrained('regions')
                ->cascadeOnDelete();
            $table->string('code')->nullable();
            $table->json('title');
            $table->json('subtitle')->nullable();
            $table->json('description')->nullable();

            $table->decimal('price', 10, 2)->nullable();
            $table->decimal('old_price', 10, 2)->nullable();


            $table->json('about_title')->nullable();
            $table->json('about_text')->nullable();

            $table->integer('order')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('special_offers');
    }
};
