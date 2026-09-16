<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'phone', 'region', 'goal', 'from_page', 'email', 'treatment',
        'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'referrer',
    ];

}
