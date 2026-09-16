@extends('templates.main')

@section('meta_title')
    {{__('static.services')}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.services.services', ['categories' => $categories])
  @include('components.call-us.call-us')

@endsection
