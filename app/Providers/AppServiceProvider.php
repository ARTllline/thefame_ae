<?php

namespace App\Providers;

use App\Models\ProductBrand;
use App\Models\ProductCategory;
use App\Models\Variant;
use App\Models\Ingredient;
use App\Observers\IngredientObserver;
use App\Observers\ProductBrandObserver;
use App\Observers\ProductCategoryObserver;
use App\Observers\VariantObserver;
use Illuminate\Support\Facades\App;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\View;

use App\Models\Product;
use App\Observers\ProductObserver;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Product::observe(ProductObserver::class);

        ProductCategory::observe(ProductCategoryObserver::class);
        ProductBrand::observe(ProductBrandObserver::class);
        Variant::observe(VariantObserver::class);
        Ingredient::observe(IngredientObserver::class);

        \Spatie\NovaTranslatable\Translatable::defaultLocales(['en', 'uk', 'ru']);


        View::composer('*', function ($view) {
            $currentLocale = App::getLocale();
            $languages = [
                'ru' => 'Рус',
                'uk' => 'Укр',
                'en' => 'Eng',
            ];
            $view->with('currentLocale', $currentLocale);
            $view->with('languages', $languages);
        });
    }
}
