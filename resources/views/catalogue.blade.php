@extends('templates.main')

@section('meta_title')

@endsection

@section('meta_description')
@endsection

@section('meta')
@endsection

@section('content')
    @include('components.catalogue-breadcrumbs.catalogue-breadcrumbs', ['catalogueData' => $catalogueData])
    @include('components.catalogue.catalogue', ['catalogueData' => $catalogueData])
    @include('components.call-us.call-us')
@endsection
