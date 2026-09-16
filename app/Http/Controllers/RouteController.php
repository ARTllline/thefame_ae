<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Service;
use App\Models\SpecialOffer;
use App\Models\TeamMember;
use App\Models\Device;
use App\Models\About;
use App\Models\Gallery;

class RouteController extends Controller
{
    public function showHome()
    {
        $siteRegion = $this->siteRegion();

        $aboutMain = About::where('code', 'main')->first();

        $categories = Category::with(['services' => function ($serviceQuery) use ($siteRegion) {
            $serviceQuery
                ->whereHas('region', fn ($regionQuery) => $regionQuery->where('code', $siteRegion))
                ->with('variants')
                ->ordered();
        }])
            ->whereHas('services.region', fn ($query) => $query->where('code', $siteRegion))
            ->ordered()
            ->get();

        $team = TeamMember::query()
            ->where(function ($query) use ($siteRegion) {
                $query->whereHas('region', fn ($regionQuery) => $regionQuery->where('code', $siteRegion))
                    ->orWhereDoesntHave('region');
            })
            ->ordered()
            ->get();

        $gallery = Gallery::first();

        $devices = Device::query()
            ->whereHas('region', fn ($query) => $query->where('code', $siteRegion))
            ->ordered()
            ->get();

        return view('home', compact(
            'aboutMain',
            'categories',
            'team',
            'gallery',
            'devices'
        ));
    }

    // Оставляем методы для детальных страниц, если они открываются отдельно (например, по клику из лендинга)
    public function showService(string $service)
    {
        return $this->renderService($service);
    }

    public function showLocalizedService(string $locale, string $service)
    {
        return $this->renderService($service);
    }

    private function renderService(string $service)
    {
        $service = Service::query()
            ->where('code', $service)
            ->whereHas('region', fn ($query) => $query->where('code', $this->siteRegion()))
            ->firstOrFail();

        $service->load([
            'variants' => function ($query) {
                $query->ordered();
            },
            'variants.prices' => function ($query) {
                $query->ordered();
            }
        ]);

        return view('service-card', compact('service'));
    }

    private function siteRegion(): string
    {
        return 'dubai';
    }

    public function showSpecialOffer(SpecialOffer $offer)
    {
        // Убрали проверку региона
        return view('special-offer', compact('offer'));
    }
}
