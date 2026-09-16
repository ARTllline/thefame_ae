@extends('templates.main')

@section('meta_title')
    {{__('static.contacts')}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.contact.contact')
    @include('components.locations.locations')
    @include('components.call-us.call-us')

@endsection
