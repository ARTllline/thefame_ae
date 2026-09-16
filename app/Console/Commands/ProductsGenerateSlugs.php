<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;

class ProductsGenerateSlugs extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'products:generate-slugs';

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
        $chunk = 200;

        Product::whereNull('slug')
            ->orWhere('slug', '')
            ->orderBy('id')
            ->chunkById($chunk, function($products){
                foreach ($products as $product) {
                    $product->slug = $product->generateUniqueSlug();
                    $product->save();

                    $this->info("Product ID {$product->id} -> {$product->slug}");
                }
            });

        $this->info('Done.');
    }

}
