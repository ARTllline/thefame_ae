@extends('templates.main')

@section('meta_title')
    {{$service->title}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.service-card.service-card', ['service'=>$service])
    @include('components.call-us.call-us')
    @include('components.footer.footer')
@endsection
