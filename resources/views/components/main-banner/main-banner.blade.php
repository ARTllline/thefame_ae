@php
    $classPrefix ='main-banner';
    $dataPrefix ='data-main-banner';

    $banner = \App\Models\Banner::where('is_show', true)->first();

    $dubaiDesktop = $banner ? $banner->getFirstMediaUrl('dubai_desktop') : null;
    $dubaiMobile  = $banner ? $banner->getFirstMediaUrl('dubai_mobile') : null;
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}"
     data-dubai-desktop="{{ $dubaiDesktop }}"
     data-dubai-mobile="{{ $dubaiMobile }}">

    <div {{$dataPrefix}}-background class="{{$classPrefix}}__background">
        <div {{$dataPrefix}}-background-loader class="{{$classPrefix}}__background-loader">
            @include('components.loader.loader')
        </div>

        <video {{$dataPrefix}}-background-video id="banner-video" class="{{$classPrefix}}__background-video"
               autoplay loop muted playsinline></video>
    </div>

    <div class="{{$classPrefix}}__content">
        <h1 class="{{$classPrefix}}__title">{{ __('static.banner_title') }}</h1>
        <p class="{{$classPrefix}}__subtitle">{{ __('static.banner_subtitle') }}</p>
    </div>


</div>
