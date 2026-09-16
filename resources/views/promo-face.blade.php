@extends('templates.main')

@section('meta_title')

@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.promo-banner.promo-banner', ['isFace' => true])
    @include('components.promo-accordion.promo-accordion')
    @include('components.promo-about.promo-about')
{{--    @include('components.promo-review.promo-review')--}}

    @include('components.promo-result-photo.promo-result-photo')
    @include('components.promo-checkout.promo-checkout')
    @include('components.promo-review.promo-review')
    @include('components.promo-contacts.promo-contacts')



@endsection
