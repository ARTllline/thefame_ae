@extends('templates.main')

@section('meta_title')
    {{__('static.team')}}
@endsection

@section('meta_description')
@endsection

@section('content')

    @include('components.our-team.our-team', ['team' => $team])
    @include('components.call-us.call-us')

@endsection
