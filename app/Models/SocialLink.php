<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SocialLink extends Model
{
    use HasFactory;

    protected $fillable = ['platform', 'url', 'region_id', 'icon'];
    public function region()
    {
        return $this->belongsTo(Region::class);
    }
}
