@extends('templates.main')

@section('meta_title')

@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.promo-banner.promo-banner', ['isFace' => false])
    @include('components.promo-about.promo-about')
    @include('components.promo-services.promo-services')
    @include('components.promo-procedures.promo-procedures')
    @include('components.promo-why-us.promo-why-us')
    @include('components.promo-contacts.promo-contacts')

    @include('components.call-us.call-us')

    @include('components.promo-modal.promo-modal')
@endsection
