@extends('templates.main')

@section('meta_title')

@endsection

@section('meta_description')
@endsection

@section('content')
    @include('components.promo-banner.promo-banner', ['isFace' => true])
    @include('components.promo-review.promo-review')
    @include('components.promo-contacts.promo-contacts')
@endsection
