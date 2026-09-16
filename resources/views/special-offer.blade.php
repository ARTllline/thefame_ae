@extends('templates.main')

@section('meta_title')
    {{$offer->title}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.special-offer-product.special-offer-product', ['offer'=>$offer])
    @include('components.locations.locations')
    @include('components.call-us.call-us')

@endsection
