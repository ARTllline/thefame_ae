<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\App;
use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;

class Category extends Model implements Sortable
{
    use HasFactory, HasTranslations, SortableTrait;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'description',
        'order',
        'seo_text'
    ];

    public function getTitleAttribute($value)
    {
        $locale = App::getLocale();

        $title = json_decode($value, true);

        return $title[$locale]
            ?? $title['en']
            ?? reset($title);
    }

    public $translatable = ['name', 'description', 'seo_text'];


    public $sortable = [
        'order_column_name'  => 'order',
        'sort_when_creating' => true,
    ];

    /**
     * The services belonging to this category.
     */
    public function services()
    {
        return $this->belongsToMany(Service::class, 'service_categories')
            ->withPivot('order')
            ->orderBy('service_categories.order')
            ->withTimestamps();
    }

    /**
     * The service-category pivot records.
     */
    public function serviceCategories()
    {
        return $this->hasMany(ServiceCategory::class);
    }
}
