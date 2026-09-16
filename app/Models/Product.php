<?php

namespace App\Models;

use App\Traits\HasSlug;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Image\Manipulations;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\Translatable\HasTranslations;

class Product extends Model implements Sortable, HasMedia
{
    use HasFactory, HasTranslations;
    use SortableTrait;
    use InteractsWithMedia;
    use HasSlug;


    protected $table = 'products';
    public $translatable = ['name', 'short_description', 'description', 'subtitle'];
    protected $fillable = [
        'article', 'code', 'name', 'volume', 'subtitle',
        'price_ua','price_eu','slug','order',
        'short_description','description','is_active',
        'product_category_id','product_brand_id', 'position'
    ];
    protected $casts = [
        'is_active' => 'boolean',
        'order' => 'integer',
        'price_ua' => 'decimal:2',
        'price_eu' => 'decimal:2',
    ];
    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];

    public function registerMediaConversions(Media $media = null): void
    {
        $this
            ->addMediaConversion('webp')
            ->width(1000)
            ->height(1000)
            ->format(Manipulations::FORMAT_WEBP);
    }
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('images')->useDisk('products');
    }

    // Relations
    public function brand()
    {
        return $this->belongsTo(ProductBrand::class, 'product_brand_id');
    }

    public function category()
    {
        return $this->belongsTo(ProductCategory::class, 'product_category_id');
    }

    public function ingredients()
    {
        return $this->belongsToMany(Ingredient::class, 'product_ingredients')
            ->withTimestamps()
            ->withPivot('order');
    }

    public function variants()
    {
        return $this->belongsToMany(Variant::class, 'product_variants')
            ->withTimestamps()
            ->withPivot('order');
    }

    // Scopes
    public function scopeActive($q)
    {
        return $q->where('is_active', true);
    }

    public function scopeOrdered($q)
    {
        return $q->orderBy('order')->orderBy('id','asc');
    }

    // Helpers for translations (simple)
    public function getTranslated(string $field, ?string $locale = null, bool $fallback = true)
    {
        $locale = $locale ?? app()->getLocale();

        // используем встроенные методы HasTranslations
        if ($this->hasTranslation($field, $locale)) {
            return $this->getTranslation($field, $locale);
        }

        if ($fallback) {
            // вернём первый непустой перевод
            foreach ($this->getTranslations($field) as $value) {
                if ($value) return $value;
            }
        }

        return null;
    }

    public function getName(string $locale = null)
    {
        return $this->getTranslated('name', $locale);
    }
    public function getSubtitle(?string $locale = null)
    {
        return $this->getTranslated('subtitle', $locale);
    }
    public function getDescription(?string $locale = null)
    {
        return $this->getTranslated('description', $locale);
    }


}

