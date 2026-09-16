@php($classPrefix ='certificates')
@php($dataPrefix ='data-certificates')


<div {{$dataPrefix}} class="{{$classPrefix}}">
    <h2 class="{{$classPrefix}}__title">
        <span class="{{$classPrefix}}__title-row {{$classPrefix}}__title-left">Нагороди</span>
        <span class="{{$classPrefix}}__title-row {{$classPrefix}}__title-right">та сертифікати</span>
    </h2>
    <div {{$dataPrefix}}-slider class="swiper {{$classPrefix}}__swiper">
        <div {{$dataPrefix}}-slider-wrapper class="swiper-wrapper">

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


<template {{$dataPrefix}}-card-template>
    <div class="swiper-slide {{$classPrefix}}__card">
        <div class="{{$classPrefix}}__card-image" >
            <img decoding="async" src="https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xsert.png.webp.pagespeed.ic.q2B4Pv2o7p.webp" alt="">
        </div>

        <p class="{{$classPrefix}}__card-subtitle">Cтатус специалистов подтвержден академией Sassoon</p>
    </div>
</template>


