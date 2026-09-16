@extends('templates.main')

@section('meta_title')
    The Fame — modern aesthetic clinic
@endsection

@section('meta_description')
    The Fame — modern aesthetic clinic. We combine a medical approach with care for comfort and aesthetics.
@endsection

@section('content')
    <section id="hero">
        @include('components.main-banner.main-banner')
    </section>

    <!-- Добавили класс reveal-section к блокам ниже -->
    <section id="About_The_Fame" >
        @include('components.main-about.main-about', ['about' => $aboutMain])
    </section>


    <section id="Services_&_Price" >
        @include('components.services.services', ['categories' => $categories])
    </section>

    <section id="Our_Devices" >
        @include('components.devices.devices', ['devices' => $devices])
    </section>

    <section id="Before_After" >
        @include('components.gallery.gallery', ['gallery' => $gallery])
    </section>

    <section id="Our_Team" >
        @include('components.our-team.our-team', ['team' => $team])
    </section>
{{--    class="reveal-section"--}}

    <section id="Contacts" >

        @include('components.call-us.call-us', ['modifier' => 'footer'])

        <div class="footer-section">
            @include('components.locations.locations')
            @include('components.contact.contact')
            @include('components.footer.footer')
        </div>
    </section>

    @include('components.social.social')

@endsection
