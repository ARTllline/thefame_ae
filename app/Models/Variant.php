<?php

namespace App\Models;

use App\Traits\HasSlug;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;

class Variant extends Model
{
    use HasFactory,HasTranslations;
    use HasSlug;
    use SortableTrait;
    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];
    protected $fillable = ['slug','name','short_description','description','is_active','is_show_nav','order', 'seo_text' ,'is_show_nav'];
    protected $casts = [
        'is_active'=>'boolean',
        'order'=>'integer'
    ];
    public $translatable = ['name','short_description','description','seo_text'];

    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_variants')
            ->withTimestamps()
            ->withPivot('order');
    }
    public function scopeActive($q)
    {
        return $q->where('is_active', true);
    }
}
