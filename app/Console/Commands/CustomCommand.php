<?php

namespace App\Console\Commands;

use App\Models\Ingredient;
use Illuminate\Console\Command;
use Illuminate\Support\Str;

class CustomCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:custom-command';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {

        $ingredients = Ingredient::query()
            ->whereNull('slug')
            ->orWhere('slug', '')
            ->get();

        $this->info("Found {$ingredients->count()} ingredients to update.");

        foreach ($ingredients as $ingredient) {
            $slug = Str::slug($ingredient->name); // генерируем slug
            $ingredient->slug = $slug;
            $ingredient->save();

            $this->line("Updated: {$ingredient->name} -> {$slug}");
        }

        $this->info('All slugs updated successfully.');
    }
}
