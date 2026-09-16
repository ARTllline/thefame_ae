@php
    $classPrefix ='devices';
    $dataPrefix ='data-devices';
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}">
    <div class="{{$classPrefix}}__header">
        <h2 class="{{$classPrefix}}__title">{{ __('static.devices') }}</h2>
        <p class="{{$classPrefix}}__subtitle">
            {{ __('static.devices_subtitle') }}
        </p>
    </div>
    <div {{$dataPrefix}}-list class="{{$classPrefix}}__list">
        @foreach($devices as $device)
            <div {{$dataPrefix}}-card-index="{{$loop->index + 1}}" {{$dataPrefix}}-card class="{{$classPrefix}}__card">
                <div class="{{$classPrefix}}__card-img">
                    <div class="{{$classPrefix}}__card-img-main">
                        <svg class="{{$classPrefix}}__card-background" viewBox="0 0 461 500"
                             xmlns="http://www.w3.org/2000/svg">
                            <path fill-rule="evenodd" clip-rule="evenodd"
                                  d="M210.13 0.220271C287.534 3.51652 332.694 52.3801 378.436 123.332C420.64 188.796 477.185 259.225 456.651 336.924C436.774 412.134 352.563 423.074 290.225 457.116C227.939 491.13 146.035 521.764 80.5597 479.253C27.3351 444.696 29.313 386.646 13.5027 325.165C-7.63119 242.982 -5.26394 173.46 29.9304 108.491C71.3559 32.0186 131.096 -3.14541 210.13 0.220271Z"></path>
                        </svg>
                        <div {{$dataPrefix}}-image
                             class="swiper swiper--hidden {{$classPrefix}}__swiper-image-{{$loop->index + 1}}">
                            <div {{$dataPrefix}}-image-wrapper class="swiper-wrapper">
                                @foreach($device->getMedia('images') as $media)
                                    <div class="swiper-slide">
                                        <div class="{{$classPrefix}}__card-clip-path-effect">
                                            <a href="{{ $media->getUrl() }}" class="glightbox"
                                               data-gallery="gallery{{ $device->id }}">
                                                <img src="{{ $media->getUrl('webp') }}"
                                                     alt="{{ $device->title }}"
                                                     decoding="async"
                                                     fetchpriority="high"/>
                                            </a>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <div class="{{$classPrefix}}__card-img-prev">
                        <div {{$dataPrefix}}-slider
                             class="swiper swiper--hidden {{$classPrefix}}__swiper-prev {{$classPrefix}}__swiper-{{$loop->index + 1}}">
                            <div {{$dataPrefix}}-slider-wrapper class="swiper-wrapper">
                                @foreach($device->getMedia('images') as $media)
                                    <div class="swiper-slide">
                                        <div class="{{$classPrefix}}__card-img-nav-item">
                                            <img src="{{ $media->getUrl('webp') }}" alt="{{ $device->title }}">
                                        </div>

                                    </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                </div>

                <div class="{{$classPrefix}}__card-content">
                    <h2 class="{{$classPrefix}}__card-content-title">
                        @php
                            [$titleLeft, $titleRight] = \App\Helpers\TextHelper::splitTitle($device->title);
                        @endphp
                        <span class="{{$classPrefix}}__card-content-title-left">{{ $titleLeft }}</span>
                        <span class="{{$classPrefix}}__card-content-title-right">{{ $titleRight }}</span>
                    </h2>
                    <div class="{{$classPrefix}}__card-content-text">
                        {!! nl2br(e($device->description)) !!}
                    </div>

                    <div {{$dataPrefix}}-read-more class="link {{$classPrefix}}__card-content-read-more">
                        {{__('static.more_read')}}
                    </div>
                    <div {{$dataPrefix}}-read-less class="link {{$classPrefix}}__card-content-read-less">
                        {{__('static.less_read')}}
                    </div>

                    <div class="{{$classPrefix}}__card-links">
                        <button data-modal-open class="button button-clip {{$classPrefix}}__card-button">
                        <span class="clip">
                            <span>{{__('static.sign_up')}}</span>
                           <span>{{__('static.sign_up')}}</span>
                        </span>
                        </button>
                        @if($device->link)
                            <a class="link {{$classPrefix}}__card-link" href="{{$device->link}}">{{__('static.more')}}
                                <svg class="{{$classPrefix}}__card-link-icon">
                                    <use xlink:href="#link"></use>
                                </svg>
                            </a>
                        @endif

                    </div>

                </div>
            </div>
        @endforeach
    </div>
    @if($devices->count() > 4)
        <div class="show-more-wrapper">
            <button type="button" data-load-more="devices" class="btn-show-more">{{ __('static.show_more_devices') }}</button>
        </div>
    @endif
</div>
