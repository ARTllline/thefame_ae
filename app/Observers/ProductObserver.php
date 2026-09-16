<?php

namespace App\Observers;

use App\Models\Product;

class ProductObserver
{
    public function saving(Product $product)
    {
        // если slug уже выставлен — не трогаем
        if (!empty($product->slug)) {
            return;
        }

        // используем трейт-метод в модели Product (см. ниже)
        $product->slug = $product->generateUniqueSlug();
    }
}
