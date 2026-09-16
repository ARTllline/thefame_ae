<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;

use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\Image\Manipulations;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class SpecialOffer extends Model implements Sortable, HasMedia
{
    use HasFactory, HasTranslations;
    use SortableTrait;
    use InteractsWithMedia;

    protected $fillable = [
        'region_id',
        'code',
        'title',
        'subtitle',
        'description',
        'order',
        'price',
        'old_price',
        'about_title',
        'about_text',
    ];

    public $translatable = ['title', 'subtitle', 'description', 'about_title', 'about_text'];

    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];

    protected $casts = [
        'description' => 'array',
        'title' => 'array',
        'subtitle' => 'array',
        'about_title' => 'array',
        'about_text' => 'array',
    ];

    public function registerMediaConversions(Media $media = null): void
    {
        $this
            ->addMediaConversion('webp')
            ->width(500)
            ->height(500)
            ->format(Manipulations::FORMAT_WEBP);
    }
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('main')->singleFile()->useDisk('specialOffers');
    }
    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }

    public function region()
    {
        return $this->belongsTo(Region::class);
    }
}
