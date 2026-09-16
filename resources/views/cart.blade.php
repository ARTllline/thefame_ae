@extends('templates.main')

@section('meta_title')

@endsection

@section('meta_description')
@endsection

@section('meta')
    <meta name="robots" content="noindex, nofollow">
@endsection

@section('content')
    @include('components.catalogue-breadcrumbs.catalogue-breadcrumbs', ['catalogueData' => $catalogueData])
    @include('components.cart.cart')
    @include('components.call-us.call-us')
@endsection
