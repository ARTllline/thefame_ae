<?php
namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray($request): array
    {
        $locale = $request->input('locale') ?? app()->getLocale();

        $media = $this->getMedia('images');
        $images = $media->map(function ($image) {
            return [
                'url' => $image->getUrl('webp'),
                'url_original' => $image->getUrl(),
            ];
        });


        return [
            'id' => $this->id,
            'article' => $this->article,
            'code' => $this->code,
            'position' => $this->position,
            'images' => $images,
            // For translations: call helper to get current locale
            'name' => $this->getName($locale),
            'subtitle' => $this->getSubtitle($locale),
            'description' => $this->getDescription($locale),
            'slug' => $this->slug,
            'volume' => $this->volume,
            //format ua price from 1.00 to 1
            'price_ua' => round($this->price_ua, 0),
            'price_eu' => round($this->price_eu, 0),
            'is_active' => (bool)$this->is_active,
            'brand' => $this->whenLoaded('brand', function () {
                return [
                    'id' => $this->brand?->id,
                    'name' => $this->brand?->name,
                ];
            }),
            'category' => $this->whenLoaded('category', function () {
                return [
                    'id' => $this->category?->id,
                    'name' => $this->category?->name,
                ];
            }),
            // variants / ingredients only when requested
            'ingredients' => $this->whenLoaded('ingredients', fn() => $this->ingredients->map(fn($i)=>['id'=>$i->id,'name'=>$i->name])),
            'variants' => $this->whenLoaded('variants', fn() => $this->variants->map(fn($v)=>['id'=>$v->id,'name'=>$v->name])),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
