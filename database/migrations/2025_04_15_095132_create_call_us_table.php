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
        Schema::create('call_us', function (Blueprint $table) {
            $table->id();
            $table->json('text')->nullable();
            $table->string('phone_ua')->nullable();
            $table->string('email_ua')->nullable();
            $table->string('phone_dubai')->nullable();
            $table->string('email_dubai')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('call_us');
    }
};
