<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductListRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'take' => ['nullable','integer','min:1','max:100'],
            'skip' => ['nullable','integer','min:0'],
            'locale' => ['nullable','string','size:2'],
            'with' => ['nullable','string'], // comma-separated: brand,category,variants,ingredients
            'q' => ['nullable','string'], // simple search
            'brand_id' => ['nullable','integer','exists:product_brands,id'],
            'category_id' => ['nullable','integer','exists:product_categories,id'],
            'is_active' => ['nullable','boolean'],
            'sort' => ['nullable','string'], // e.g. price_ua:asc
            // future: accept filter[...] arrays or other structured filters
        ];
    }

    public function prepareForValidation(): void
    {
        // normalize booleans from "0"/"1"
        if ($this->has('is_active')) {
            $this->merge(['is_active' => filter_var($this->input('is_active'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE)]);
        }
    }
}
