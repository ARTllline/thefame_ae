<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'status',
        'fname',
        'lname',
        'phone',
        'email',
        'products_total',
        'total',
        'total_items',
        'currency',
    ];


    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
