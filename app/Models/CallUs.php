<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\Translatable\HasTranslations;
class CallUs extends Model
{
    use HasFactory, HasTranslations;

    protected $fillable = [
        'text',
        'phone_ua',
        'email_ua',
        'phone_dubai',
        'email_dubai',
    ];

    public $translatable = ['text'];

    protected $casts = [
        'text' => 'array'
    ];



}
