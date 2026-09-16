<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Spatie\Translatable\HasTranslations;

class PromoBanner extends Model
{
    use HasTranslations;

    protected $fillable = ['content', 'link', 'is_active'];

    public $translatable = ['content'];

    protected $casts = [
        'content' => 'array',
        'is_active' => 'boolean',
    ];
}
