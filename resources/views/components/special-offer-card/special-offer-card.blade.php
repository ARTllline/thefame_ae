@php($classPrefix ='special-offer-card')
@php($dataPrefix ='data-special-offer-card')


<a href="/special-offer/{{$specialOffer->id}}" {{$dataPrefix}} class="swiper-slide {{$classPrefix}}">

    <div class="{{$classPrefix}}__image">
        <img fetchpriority="high" decoding="async" loading="lazy"
             src="{{ $specialOffer->getFirstMediaUrl('main', 'webp') ?: asset('img/default.webp') }}"
             alt="{{ $specialOffer->title }}">

    </div>

    <div class="{{$classPrefix}}__description">
        <h5 class="{{$classPrefix}}__title">{{$specialOffer->title}}</h5>
        <p class="{{$classPrefix}}__text">
            {{$specialOffer->subtitle}}</p>
    </div>
</a>

