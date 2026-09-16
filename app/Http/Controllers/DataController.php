<?php

namespace App\Http\Controllers;

use App\Models\Service;
use App\Models\SpecialOffer;
use App\Models\TeamMember;
use App\Models\Device;
use App\Models\About;
use App\Models\Gallery;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Http\Request;


class DataController extends Controller
{

    public function loadMoreServices(Request $request)
    {
        $region = 'dubai';

        // get следующую «страницу» по тому же запросу
        $services = Service::with(['category', 'variants'])
            ->where(function ($q) use ($region) {
                $q->whereHas('region', fn($q2) => $q2->where('code', $region))
                    ->orWhereDoesntHave('region');
            })
            ->ordered()
            ->simplePaginate(9);

        // трансформируем модели в простой массив
        $data = $services->map(fn($s) => [
            'id'         => $s->id,
            'title'      => $s->title,
            'image_url'  => $s->getFirstMediaUrl('main', 'webp') ?: asset('img/default.webp'),
        ])->values();

        return response()->json([
            'data'          => $data,
            'next_page_url' => $services->nextPageUrl(),
        ]);
    }

}
