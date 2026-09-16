<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\EloquentSortable\Sortable;
use Spatie\EloquentSortable\SortableTrait;

class ServiceCategory extends Model implements Sortable
{
    use HasFactory, SortableTrait;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'service_categories';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'service_id',
        'category_id',
        'order',
    ];

    /**
     * Configuration for the Spatie sortable trait.
     *
     * @var array<string, mixed>
     */
//    public $sortable = [
//        'order_column_name'  => 'order',
//        'sort_when_creating' => true,
//    ];

    /**
     * Get the service associated with this pivot.
     */
    public function service()
    {
        return $this->belongsTo(Service::class);
    }

    /**
     * Get the category associated with this pivot.
     */
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
