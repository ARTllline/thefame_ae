<?php
// app/Http/Middleware/SetLocale.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;

class SetLocale
{
    public function handle(Request $request, Closure $next)
    {
        $urlSegment = $request->segment(1);

        $urlLocales = ['ru', 'ua', 'en'];

        if (in_array($urlSegment, $urlLocales)) {
            $internalLocale = $urlSegment === 'ua' ? 'uk' : $urlSegment;

            App::setLocale($internalLocale);
            session(['locale' => $internalLocale]);
        } else {
            App::setLocale(config('app.fallback_locale'));
        }

        return $next($request);
    }
}
