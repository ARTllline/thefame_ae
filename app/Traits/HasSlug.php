<?php
namespace App\Traits;

use Illuminate\Support\Str;

trait HasSlug
{
    /**
     * Преобразует "name" модели в простой массив и выбирает имя по приоритету en->uk->ru
     */
    protected function resolveNameFromAttribute()
    {
        $raw = $this->getAttribute('name');

        // Если уже массив — используем напрямую
        if (is_array($raw)) {
            return $raw['en'] ?? $raw['uk'] ?? $raw['ru'] ?? null;
        }

        // Если stdClass — превратим в массив
        if (is_object($raw)) {
            $arr = (array) $raw;
            return $arr['en'] ?? $arr['uk'] ?? $arr['ru'] ?? null;
        }

        // Если строка — попробуем декодировать JSON
        if (is_string($raw) && $raw !== '') {
            $decoded = json_decode($raw, true);
            if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
                return $decoded['en'] ?? $decoded['uk'] ?? $decoded['ru'] ?? null;
            }

            // Возможно это просто строка с именем (не JSON)
            return trim($raw) !== '' ? $raw : null;
        }

        return null;
    }

    /**
     * Определяет язык строки для корректного транслита (en если есть латиница, иначе ru)
     */
    protected function detectSlugLang(string $value): string
    {
        if (preg_match('/[A-Za-z]/', $value)) {
            return 'en';
        }

        if (preg_match('/[А-Яа-яЁёІіЇїЄєҐґ]/u', $value)) {
            // Используем 'ru' для транслитерации кириллицы — Laravel хорошо справляется и с укр.
            return 'ru';
        }

        return 'en';
    }

    /**
     * Сгенерировать уникальный slug по правилам: en -> uk -> ru -> product-{article} -> product-{random}
     */
    public function generateUniqueSlug(): string
    {
        // Получаем имя безопасно
        $nameCandidate = $this->resolveNameFromAttribute();

        $base = null;

        if (!empty($nameCandidate)) {
            // иногда nameCandidate может быть массив с 'en' прямо — на всякий
            if (is_array($nameCandidate)) {
                $nameCandidate = $nameCandidate['en'] ?? $nameCandidate['uk'] ?? $nameCandidate['ru'] ?? null;
            }

            if (is_string($nameCandidate) && $nameCandidate !== '') {
                $lang = $this->detectSlugLang($nameCandidate);
                // Str::slug корректно транслитерирует кириллицу при указанном языке
                $base = Str::slug($nameCandidate, '-', $lang);
            }
        }

        // Если base пустой — пробуем article
        if (!$base && !empty($this->article)) {
            $base = Str::slug('product-' . (string)$this->article, '-', 'en');
        }

        // Если и article нет — используем рандом
        if (!$base) {
            $base = 'slug-' . $this->id . '-' . Str::random(6);
        }

        // Убедимся в уникальности
        $slug = $base;
        $i = 2;
        $modelClass = get_class($this);

        while ($modelClass::where('slug', $slug)->exists()) {
            $slug = $base . '-' . $i++;
        }

        return $slug;
    }
}
