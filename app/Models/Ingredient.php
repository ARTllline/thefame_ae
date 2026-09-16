<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;

class Ingredient extends Model
{
    use HasFactory,HasTranslations;
    use SortableTrait;
    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];
    protected $fillable = ['name','is_active','order', 'seo_text','is_show_nav'];
    protected $casts = ['is_active'=>'boolean','order'=>'integer'];
    public $translatable = ['name', 'seo_text'];
    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_ingredients')
            ->withTimestamps()
            ->withPivot('order');
    }

}
