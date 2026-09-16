@php
    $classPrefix = 'special-offer-product';
    $dataPrefix = 'data-special-offer-product';
@endphp


<div {{$dataPrefix}} class="{{$classPrefix}}">
    @include('components.product.product', ['product' => $offer])
</div>



