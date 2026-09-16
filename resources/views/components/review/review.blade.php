@php($classPrefix ='review')
@php($dataPrefix ='data-review')


<div {{$dataPrefix}} class="{{$classPrefix}}">
    <h2 class="{{$classPrefix}}__title">
        <span class="{{$classPrefix}}__title-row {{$classPrefix}}__title-left">Что говорят</span>
        <span class="{{$classPrefix}}__title-row {{$classPrefix}}__title-right">наши клиенты</span>
    </h2>
    <div {{$dataPrefix}}-slider class="swiper {{$classPrefix}}__swiper">
        <div {{$dataPrefix}}-slider-wrapper class="swiper-wrapper">

        </div>
        <div class="swiper-pagination {{$classPrefix}}__swiper-pagination">

        </div>
    </div>
</div>


<template {{$dataPrefix}}-card-template>
    <div class="swiper-slide {{$classPrefix}}__card">
        <p class="{{$classPrefix}}__card-text"></p>
        <div class="{{$classPrefix}}__card-author">
            <div class="{{$classPrefix}}__card-author-photo" data-img="">
                <img decoding="async"
                     src="https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/author1.jpg.webp"
                     alt="">
            </div>
            <h5 class="{{$classPrefix}}__card-name"></h5>
            <span class="{{$classPrefix}}__card-footnote">группа «Время и Стекло»</span>
        </div>
    </div>
</template>


