@php
    $classPrefix = 'product';
    $dataPrefix = 'data-product';
    $currency = 'грн';
    if (session('region') === 'dubai')
        {
              $currency = 'AED';
        }

@endphp


<section {{$dataPrefix}} class="{{$classPrefix}}">
    <div class="{{$classPrefix}}__product-img">
        <div class="{{$classPrefix}}__product-clip-path-effect">
            <img
                src="{{ $product->getFirstMediaUrl('main', 'webp') ?: asset('img/default.webp') }}"
                alt="{{ $product->title }}"
                decoding="async"
                fetchpriority="high"
            />
        </div>
        <svg class="{{$classPrefix}}__product-background" viewBox="0 0 461 500"
             xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" clip-rule="evenodd"
                  d="M210.13 0.220271C287.534 3.51652 332.694 52.3801 378.436 123.332C420.64 188.796 477.185 259.225 456.651 336.924C436.774 412.134 352.563 423.074 290.225 457.116C227.939 491.13 146.035 521.764 80.5597 479.253C27.3351 444.696 29.313 386.646 13.5027 325.165C-7.63119 242.982 -5.26394 173.46 29.9304 108.491C71.3559 32.0186 131.096 -3.14541 210.13 0.220271Z"></path>
        </svg>
    </div>

    <div class="{{$classPrefix}}__product-content">

        <h1 class="{{$classPrefix}}__product-title">
            @php
                [$titleLeft, $titleRight] = \App\Helpers\TextHelper::splitTitle($product->title);
            @endphp
            <span class="{{$classPrefix}}__product-title-left">{{ $titleLeft }}</span>
            <span class="{{$classPrefix}}__product-title-right">{{ $titleRight }}</span>
        </h1>


        <div class="{{$classPrefix}}__product-text">
            <p>{{$product->description}}</p>
        </div>

        @if($product->price)
            <div class="{{$classPrefix}}__product-price">
                {{number_format($product->price, 0, '.', '') }} {{$currency}}
                @if($product->old_price)
                    <span class="{{$classPrefix}}__product-price--old">{{number_format($product->old_price, 0, '.', '') }} {{$currency}}</span>
                @endif
            </div>
        @endif

        <div class="{{$classPrefix}}__product-links">
            <button data-modal-open class="button button-clip {{$classPrefix}}__product-button">
             	<span class="clip">
					<span>{{__('static.sign_up')}}</span>
					<span>{{__('static.sign_up')}}</span>
				</span>
            </button>
            <a class="link {{$classPrefix}}__product-link" href="#prices">{{__('static.more_price')}}</a>
        </div>
    </div>
</section>





