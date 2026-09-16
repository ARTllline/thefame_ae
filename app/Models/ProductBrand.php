<?php

namespace App\Models;

use App\Traits\HasSlug;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;

class ProductBrand extends Model
{
    use HasFactory, HasTranslations;
    use HasSlug;

    use SortableTrait;
    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];

    protected $fillable = ['name','is_active','order','is_show_nav'];
    public $translatable = ['seo_text'];
    protected $casts = ['is_active'=>'boolean','order'=>'integer'];

    public function products()
    {
        return $this->hasMany(Product::class, 'product_brand_id');
    }
}
