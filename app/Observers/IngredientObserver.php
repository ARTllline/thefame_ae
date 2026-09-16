<?php

namespace App\Observers;

use App\Models\Ingredient;

class IngredientObserver
{
    public function saving(Ingredient $Ingredient)
    {
        // если slug уже выставлен — не трогаем
        if (!empty($Ingredient->slug)) {
            return;
        }

        // используем трейт-метод в модели Product (см. ниже)
        $Ingredient->slug = $Ingredient->generateUniqueSlug();
    }
}
