@extends('templates.main')

@section('meta_title')
    {{__('static.devices')}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.devices.devices', [$devices])
    @include('components.call-us.call-us')
@endsection
