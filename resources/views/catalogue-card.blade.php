@extends('templates.main')

@section('meta_title')

@endsection

@section('meta_description')
@endsection

@section('meta')
@endsection

@section('content')

    @include('components.catalogue-product-card.catalogue-product-card', ['productData' => $productData])
    @include('components.call-us.call-us')
@endsection
