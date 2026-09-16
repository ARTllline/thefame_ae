<?php

namespace App\Helpers;

class TextHelper
{
    public static function splitTitle(string $title): array
    {
        $words = explode(' ', trim($title));
        $count = count($words);

        // Если всего 2 слова, просто делим пополам
        if ($count === 2) {
            return [$words[0], $words[1]];
        }

        $middle = (int) ceil($count / 2);

        // Проверяем, чтобы не было короткого слова в конце первой части
        while ($middle > 1 && mb_strlen($words[$middle]) <= 3) {
            $middle--;
        }

        $leftPart = implode(' ', array_slice($words, 0, $middle));
        $rightPart = implode(' ', array_slice($words, $middle));

        return [$leftPart, $rightPart];
    }
}
