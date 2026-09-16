<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;
class ServiceVariantPrice extends Model
{
    use HasFactory, HasTranslations, SortableTrait;

    protected $fillable = [
        'variant_id',
        'name',
        'price',
        'currency_code',
        'order',
    ];

    public $translatable = ['name'];

    protected $casts = [
        'name' => 'array',
    ];

    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];

    public function variant()
    {
        return $this->belongsTo(ServiceVariant::class, 'variant_id');
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }
}
