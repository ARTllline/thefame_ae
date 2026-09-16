<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use Spatie\Translatable\HasTranslations;

class Location extends Model
{
    use HasFactory, HasTranslations;


    protected $fillable = [
        'title',
        'subtitle',
        'phone',
        'email',
        'map',
    ];

    public $translatable = ['title', 'subtitle'];

    protected $casts = [
        'subtitle' => 'array',
        'title' => 'array',
    ];
}
