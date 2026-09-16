@php
    $classPrefix = 'service-card';
    $dataPrefix = 'data-service-card';
@endphp


<div {{$dataPrefix}} class="{{$classPrefix}}">
    @include('components.product.product', ['product' => $service])

    <section id="prices" class="{{$classPrefix}}__prices">
        <div>
            <h4 class="{{$classPrefix}}__prices-title fadeInUp fadeInUp-active">
                {{__('static.prices')}}
            </h4>
        </div>
        <div class="{{$classPrefix}}__prices-list fadeInUp fadeInUp-active">
            @foreach($service->variants as $variant)
                <article class="{{$classPrefix}}__pricing-group">
                    <h5 class="{{$classPrefix}}__pricing-name">{{ $variant->title }}</h5>
                    <div class="{{$classPrefix}}__pricing-items">
                        @foreach($variant->prices as $price)
                            <div class="{{$classPrefix}}__prices-item">
                                <span class="{{$classPrefix}}__prices-item-name">{{ $price->name }}</span>
                                <span class="{{$classPrefix}}__prices-item-num">{{ number_format($price->price, 0, '.', '') }} AED
                                </span>
                            </div>
                        @endforeach
                    </div>
                </article>
            @endforeach
        </div>
    </section>
</div>



