@php
    $classPrefix ='locations';
    $dataPrefix ='data-locations';
    $locations = \App\Models\Location::all();
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}">
    <h4 class="{{$classPrefix}}__title">
        {{ __('static.address_title') }}
    </h4>

    <div class="{{$classPrefix}}__list">
        @foreach($locations as $location)
            <div class="{{$classPrefix}}__list-item">
                <div class="{{$classPrefix}}__list-item-content">
                    <a href="https://maps.app.goo.gl/XvMEX9bdjVNrCsbV7" class="{{$classPrefix}}__list-item-content-street link link--anim">
                        {{$location->title}}
                    </a>
                    <div class="{{$classPrefix}}__list-item-content-district">
                        {{$location->subtitle}}
                    </div>
                </div>

                <div class="{{$classPrefix}}__list-item-map">
                    <iframe
                        src="{{$location->map}}"
                        height="450" style="border:0;" allowfullscreen="" aria-hidden="false"
                        tabindex="0"></iframe>
                </div>
            </div>
        @endforeach
    </div>

</div>
