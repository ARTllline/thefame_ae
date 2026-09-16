<?php
// app/Models/ServiceVariant.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;
use Spatie\Translatable\HasTranslations;

class ServiceVariant extends Model implements Sortable
{
    use HasFactory, HasTranslations, SortableTrait;

    protected $fillable = [
        'service_id',
        'code',
        'title',
        'description',
        'order',
    ];

    public $translatable = ['title', 'description'];

    protected $casts = [
        'title'       => 'array',
        'description' => 'array',
    ];

    public $sortable = [
        'order_column_name' => 'order',
        'sort_when_creating' => true,
    ];

    public function service()
    {
        return $this->belongsTo(Service::class);
    }

    public function prices()
    {
        return $this->hasMany(ServiceVariantPrice::class, 'variant_id');
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }
}
