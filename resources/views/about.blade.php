@extends('templates.main')

@section('meta_title')
    {{__('static.about')}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.about.about', ['about'=>$about])
    @include('components.locations.locations')
    @include('components.call-us.call-us')

@endsection
