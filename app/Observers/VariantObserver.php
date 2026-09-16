<?php

namespace App\Observers;

use App\Models\Variant;

class VariantObserver
{
    public function saving(Variant $variant)
    {
        // если slug уже выставлен — не трогаем
        if (!empty($variant->slug)) {
            return;
        }

        // используем трейт-метод в модели Product (см. ниже)
        $variant->slug = $variant->generateUniqueSlug();
    }
}
