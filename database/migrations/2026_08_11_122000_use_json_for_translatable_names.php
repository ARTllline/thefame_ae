<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->convertToJson('ingredients', 'ingredients_name_unique');
        $this->convertToJson('product_categories', 'product_categories_name_unique');
    }

    public function down(): void
    {
        foreach (['ingredients', 'product_categories'] as $tableName) {
            if (Schema::hasTable($tableName) && Schema::hasColumn($tableName, 'name')) {
                Schema::table($tableName, function (Blueprint $table) {
                    $table->text('name')->change();
                });
            }
        }
    }

    private function convertToJson(string $tableName, string $uniqueIndex): void
    {
        if (! Schema::hasTable($tableName) || ! Schema::hasColumn($tableName, 'name')) {
            return;
        }

        $invalidJsonExists = DB::table($tableName)
            ->whereNotNull('name')
            ->whereRaw('JSON_VALID(name) = 0')
            ->exists();

        if ($invalidJsonExists) {
            throw new RuntimeException("Cannot convert {$tableName}.name to JSON: invalid values exist.");
        }

        if ($this->indexExists($tableName, $uniqueIndex)) {
            Schema::table($tableName, function (Blueprint $table) use ($uniqueIndex) {
                $table->dropUnique($uniqueIndex);
            });
        }

        Schema::table($tableName, function (Blueprint $table) {
            $table->json('name')->change();
        });
    }

    private function indexExists(string $table, string $index): bool
    {
        return in_array($index, Schema::getIndexListing($table), true);
    }
};
