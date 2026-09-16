<?php

namespace App\Observers;

use App\Models\ProductBrand;

class ProductBrandObserver
{
    public function saving(ProductBrand $productBrand)
    {
        // если slug уже выставлен — не трогаем
        if (!empty($productBrand->slug)) {
            return;
        }

        // используем трейт-метод в модели Product (см. ниже)
        $productBrand->slug = $productBrand->generateUniqueSlug();
    }
}
