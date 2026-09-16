<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\Translatable\HasTranslations;

class Banner extends Model implements HasMedia
{
    use HasFactory, HasTranslations;
    use InteractsWithMedia;


    protected $fillable = [
        'title',
        'is_show'
    ];

    public $translatable = ['title'];

    protected $casts = [
        'title' => 'array',
    ];

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('dubai_desktop')->singleFile()->useDisk('banners');
        $this->addMediaCollection('dubai_mobile')->singleFile()->useDisk('banners');
        $this->addMediaCollection('kyiv_desktop')->singleFile()->useDisk('banners');
        $this->addMediaCollection('kyiv_mobile')->singleFile()->useDisk('banners');
    }

    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(368)
            ->height(232)
            ->extractVideoFrameAtSecond(2);
    }
}
