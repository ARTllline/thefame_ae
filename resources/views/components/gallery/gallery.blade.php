@php
    $classPrefix ='gallery';
    $dataPrefix ='data-gallery';

    $mediaItems = $gallery?->getMedia('gallery')->all() ?? [];
    $chunkSize = 3;
    $total = count($mediaItems);
    $globalIndex = 0;
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}">
    <div class="{{$classPrefix}}__header">
        <h2 class="{{$classPrefix}}__title">{{ __('static.gallery') }}</h2>
        <p class="{{$classPrefix}}__subtitle">
            {{ __('static.gallery_subtitle') }}
        </p>
    </div>

    <div class="{{$classPrefix}}__container">
        <div {{$dataPrefix}}-slider class="swiper swiper--hidden swiper--padding {{$classPrefix}}__swiper">
            <div {{$dataPrefix}}-slider-wrapper class="swiper-wrapper">
                @for ($i = 0; $i < $total; $i += $chunkSize)
                    @php
                        $chunk = array_slice($mediaItems, $i, $chunkSize);
                    @endphp
                    <div class="swiper-slide {{$classPrefix}}__swiper-image-slide">
                        <div class="slide-content">
                            @foreach($chunk as $media)
                                <div class="slide-item">
                                    <a href="{{ $media->getUrl() }}"
                                       class="glightbox {{$classPrefix}}__swiper-image-link"
                                       data-gallery="gallery{{ $gallery?->id ?? 'empty' }}"
                                       data-g-index="{{ $globalIndex++ }}">
                                        <img src="{{ $media->getUrl('webp') }}"
                                             alt="{{ __('static.about_us') }}"
                                             decoding="async"
                                             fetchpriority="high"/>
                                    </a>
                                </div>
                            @endforeach
                        </div>
                    </div>
                @endfor
            </div>

            <div class="swiper-button-next slider-button-next {{$classPrefix}}__swiper-button-next">
                <svg width="26" height="27" viewBox="0 0 26 27" xmlns="http://www.w3.org/2000/svg">
                    <path d="M9.43594 5.56387L1.68611 13.3137M1.68611 13.3137L9.43594 21.0635M1.68611 13.3137H24.3135" stroke-width="2" stroke-linecap="round"></path>
                </svg>
            </div>
            <div class="swiper-button-prev slider-button-prev {{$classPrefix}}__swiper-button-prev">
                <svg width="26" height="27" viewBox="0 0 26 27" xmlns="http://www.w3.org/2000/svg">
                    <path d="M9.43594 5.56387L1.68611 13.3137M1.68611 13.3137L9.43594 21.0635M1.68611 13.3137H24.3135" stroke-width="2" stroke-linecap="round"></path>
                </svg>
            </div>

            <div class="swiper-pagination {{$classPrefix}}__swiper-pagination"></div>
        </div>
    </div>

    <a class="link {{$classPrefix}}__link" href="https://www.instagram.com/the.fame.dubai/">
        {{ __('static.view_more_instagram') }}
        <svg class="{{$classPrefix}}__link-icon">
            <use xlink:href="#link"></use>
        </svg>
    </a>
</div>
