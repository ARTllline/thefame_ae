@extends('templates.main')

@section('meta_title')
    {{__('static.gallery')}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.gallery.gallery')
    @include('components.call-us.call-us')

@endsection
