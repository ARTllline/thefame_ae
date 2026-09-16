<?php

namespace Tests\Feature;

use App\Models\Region;
use App\Models\Service;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    public function test_localized_home_routes_are_registered_explicitly(): void
    {
        foreach (['en', 'ua', 'ru'] as $locale) {
            $this->get('/'.$locale)->assertOk();
        }
    }

    public function test_unknown_or_cross_branch_service_returns_not_found(): void
    {
        $this->get('/services/not-a-real-service')->assertNotFound();
        $this->get('/en/services/not-a-real-service')->assertNotFound();
    }

    public function test_service_is_available_with_and_without_locale_prefix(): void
    {
        $region = Region::create([
            'code' => 'dubai',
            'name' => 'Dubai',
            'currency_code' => 'AED',
        ]);

        $service = Service::create([
            'region_id' => $region->id,
            'code' => 'fillers',
            'title' => [
                'en' => 'Fillers',
                'ru' => 'Fillers',
                'uk' => 'Fillers',
            ],
            'description' => [],
        ]);

        $this->get('/services/'.$service->code)
            ->assertOk()
            ->assertViewHas('service', fn (Service $viewService) => $viewService->is($service));

        foreach (['en', 'ua', 'ru'] as $locale) {
            $this->get('/'.$locale.'/services/'.$service->code)
                ->assertOk()
                ->assertViewHas('service', fn (Service $viewService) => $viewService->is($service));
        }
    }
}
