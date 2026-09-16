<?php

namespace App\Observers;

use App\Models\ProductCategory;

class ProductCategoryObserver
{
    public function saving(ProductCategory $productCategory)
    {
        // если slug уже выставлен — не трогаем
        if (!empty($productCategory->slug)) {
            return;
        }

        // используем трейт-метод в модели Product (см. ниже)
        $productCategory->slug = $productCategory->generateUniqueSlug();
    }
}
