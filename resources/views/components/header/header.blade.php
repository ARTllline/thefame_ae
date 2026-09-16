@php
    $classPrefix = 'header';
    $dataPrefix = 'data-header';
    $routeName = Request::route()?->getName();
    $isHome = in_array($routeName, ['home', 'localized.home'], true);
    $routeLocale = request()->route('locale');
    $homeUrl = $routeLocale
        ? route('localized.home', ['locale' => $routeLocale])
        : route('home');
    $homeAnchorPrefix = $isHome ? '' : $homeUrl;
    $links = \App\Models\SocialLink::where(function ($query) {
        $query->whereHas('region', fn ($regionQuery) => $regionQuery->where('code', 'dubai'))
            ->orWhereDoesntHave('region');
    })->get();
@endphp

<div
    {{$dataPrefix}} class="{{$classPrefix}} {{ ! $isHome ? $classPrefix . '--dark' : '' }}">
    <div class="{{$classPrefix}}__mobile-menu">
        <button data-modal-open class="button-round {{$classPrefix}}__mobile-menu-button">
            <svg class="phone-svg" width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M15.4188 0.769072L12.1688 0.0190875C11.8157 -0.0621608 11.4532 0.12221 11.3095 0.453453L9.8095 3.95338C9.67825 4.25962 9.76575 4.61899 10.0251 4.82836L11.9188 6.37833C10.7939 8.77515 8.82827 10.7689 6.38145 11.9157L4.83148 10.022C4.61898 9.76263 4.26274 9.67513 3.95649 9.80638L0.456566 11.3063C0.122198 11.4532 -0.0621732 11.8157 0.0190751 12.1688L0.76906 15.4188C0.847183 15.7563 1.14718 16 1.50029 16C9.50326 16 16 9.51576 16 1.50031C16 1.15031 15.7594 0.847195 15.4188 0.769072Z"></path>
            </svg>
        </button>
        <button class="button-round {{$classPrefix}}__mobile-menu-button {{$classPrefix}}__mobile-menu-button-wrap">
            <svg class="btn-dark" width="22" height="23" viewBox="0 0 22 23" xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M19.6238 17.4419C18.6579 17.7441 17.6304 17.907 16.5649 17.907C10.9136 17.907 6.33238 13.3257 6.33238 7.67447C6.33238 5.57537 6.96444 3.62391 8.04861 2C3.89157 3.30054 0.875 7.18173 0.875 11.7675C0.875 17.4187 5.45626 22 11.1075 22C14.6597 22 17.7891 20.19 19.6238 17.4419Z"
                    stroke-width="1.5"></path>
            </svg>
            <svg class="btn-light" width="28" height="27" viewBox="0 0 28 27" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd"
                      d="M13.9998 0.0786133C14.4141 0.0786133 14.7498 0.4144 14.7498 0.828613V2.5629C14.7498 2.97711 14.4141 3.3129 13.9998 3.3129C13.5856 3.3129 13.2498 2.97711 13.2498 2.5629V0.828613C13.2498 0.4144 13.5856 0.0786133 13.9998 0.0786133ZM13.9998 23.6872C14.4141 23.6872 14.7498 24.023 14.7498 24.4372V26.1715C14.7498 26.5857 14.4141 26.9215 13.9998 26.9215C13.5856 26.9215 13.2498 26.5857 13.2498 26.1715V24.4372C13.2498 24.023 13.5856 23.6872 13.9998 23.6872ZM26.9347 13.7501C27.3489 13.7501 27.6847 13.4143 27.6847 13.0001C27.6847 12.5858 27.3489 12.2501 26.9347 12.2501H25.2004C24.7862 12.2501 24.4504 12.5858 24.4504 13.0001C24.4504 13.4143 24.7862 13.7501 25.2004 13.7501H26.9347ZM4.07608 13.0001C4.07608 13.4143 3.7403 13.7501 3.32608 13.7501H1.5918C1.17758 13.7501 0.841797 13.4143 0.841797 13.0001C0.841797 12.5858 1.17758 12.2501 1.5918 12.2501H3.32608C3.7403 12.2501 4.07608 12.5858 4.07608 13.0001ZM24.2745 22.6082C23.9816 22.9011 23.5067 22.9011 23.2138 22.6082L21.9875 21.3819C21.6946 21.089 21.6946 20.6141 21.9875 20.3212C22.2804 20.0283 22.7553 20.0283 23.0482 20.3212L24.2745 21.5476C24.5674 21.8405 24.5674 22.3153 24.2745 22.6082ZM6.52004 5.91444C6.81293 6.20733 7.28781 6.20733 7.5807 5.91444C7.87359 5.62154 7.87359 5.14667 7.5807 4.85378L6.35437 3.62745C6.06148 3.33456 5.58661 3.33456 5.29371 3.62745C5.00082 3.92035 5.00082 4.39522 5.29371 4.68811L6.52004 5.91444ZM4.65593 21.4783C4.36304 21.7712 4.36304 22.2461 4.65593 22.539C4.94883 22.8318 5.4237 22.8318 5.71659 22.539L6.94292 21.3126C7.23581 21.0197 7.23581 20.5449 6.94292 20.252C6.65003 19.9591 6.17515 19.9591 5.88226 20.252L4.65593 21.4783ZM21.3497 5.84517C21.0568 5.55228 21.0568 5.0774 21.3497 4.78451L22.576 3.55819C22.8689 3.26529 23.3438 3.26529 23.6367 3.55819C23.9296 3.85108 23.9296 4.32595 23.6367 4.61885L22.4104 5.84517C22.1175 6.13806 21.6426 6.13806 21.3497 5.84517ZM21.4999 13.5001C21.4999 17.3661 18.3659 20.5001 14.4999 20.5001C10.6339 20.5001 7.49988 17.3661 7.49988 13.5001C7.49988 9.63407 10.6339 6.50006 14.4999 6.50006C18.3659 6.50006 21.4999 9.63407 21.4999 13.5001ZM22.9999 13.5001C22.9999 18.1945 19.1943 22.0001 14.4999 22.0001C9.80546 22.0001 5.99988 18.1945 5.99988 13.5001C5.99988 8.80564 9.80546 5.00006 14.4999 5.00006C19.1943 5.00006 22.9999 8.80564 22.9999 13.5001Z"></path>
            </svg>
        </button>
        <div class="{{$classPrefix}}__mobile-menu-logo">
            <a href="{{$homeAnchorPrefix}}#hero">
                <img src="{{ asset('img/logo-dubai.png')}}" alt="Logo">
            </a>
        </div>
        <button {{$dataPrefix}}-menu-open
                class="button-round {{$classPrefix}}__mobile-menu-button {{$classPrefix}}__mobile-menu-wrapper">
            <span class="{{$classPrefix}}__mobile-menu-wrapper-burger">
                <span class="line"></span>
                <span class="line"></span>
                <span class="line"></span>
            </span>
        </button>
    </div>

    <div class="{{$classPrefix}}__menu">
        <a href="{{ $isHome ? '#hero' : $homeUrl }}" class="{{$classPrefix}}__menu-logo">
            <img src="{{ asset('img/logo-dubai.png')}}" alt="Logo">
        </a>

        <ul class="{{$classPrefix}}__menu-list {{ ! $isHome ? $classPrefix . '__menu-list--mobile-only' : '' }}">
            <li class="{{$classPrefix}}__menu-list-item"><a href="{{$homeAnchorPrefix}}#About_The_Fame" class="{{$classPrefix}}__menu-list-item-title">{{__('static.about')}}</a></li>
            <li class="{{$classPrefix}}__menu-list-item"><a href="{{$homeAnchorPrefix}}#Services_&_Price" class="{{$classPrefix}}__menu-list-item-title">{{__('static.services')}}</a></li>
            <li class="{{$classPrefix}}__menu-list-item"><a href="{{$homeAnchorPrefix}}#Our_Devices" class="{{$classPrefix}}__menu-list-item-title">{{__('static.devices')}}</a></li>
            <li class="{{$classPrefix}}__menu-list-item"><a href="{{$homeAnchorPrefix}}#Before_After" class="{{$classPrefix}}__menu-list-item-title">{{__('static.gallery')}}</a></li>
            <li class="{{$classPrefix}}__menu-list-item"><a href="{{$homeAnchorPrefix}}#Our_Team" class="{{$classPrefix}}__menu-list-item-title">{{__('static.team')}}</a></li>
            <li class="{{$classPrefix}}__menu-list-item"><a href="{{$homeAnchorPrefix}}#Contacts" class="{{$classPrefix}}__menu-list-item-title">{{__('static.locations')}}</a></li>
        </ul>

        <div class="{{$classPrefix}}__menu-bottom">
            <div class="{{$classPrefix}}__menu-social">
                @foreach($links as $link)
                    <a target="_blank" href="{{$link->url}}" class="link"> {{$link->platform}}</a>
                @endforeach
            </div>

            <div class="{{$classPrefix}}__menu-settings">
                <div data-modal-open class="button button-clip {{$classPrefix}}__action-button m-hide">
                    <span class="clip">
                        <span>{{ __('static.sign_up') }}</span>
                        <span>{{ __('static.sign_up') }}</span>
                    </span>
                </div>

                <a data-region-open target="_self" {{$dataPrefix}}-btn-dark
                   class="button-round {{$classPrefix}}__setting-button {{$classPrefix}}__setting-button--region">
                    <svg viewBox="0 0 24 24" width="24" height="24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M19.5 6L18.0333 7.1C17.6871 7.35964 17.2661 7.5 16.8333 7.5H13.475C12.8775 7.5 12.3312 7.83761 12.064 8.37206V8.37206C11.7342 9.03161 11.9053 9.83161 12.476 10.2986L14.476 11.9349C16.0499 13.2227 16.8644 15.22 16.6399 17.2412L16.6199 17.4206C16.5403 18.1369 16.3643 18.8392 16.0967 19.5083L15.5 21"/>
                        <path d="M2.5 10.5L5.7381 9.96032C7.09174 9.73471 8.26529 10.9083 8.03968 12.2619L7.90517 13.069C7.66434 14.514 8.3941 15.9471 9.70437 16.6022V16.6022C10.7535 17.1268 11.2976 18.3097 11.0131 19.4476L10.5 21.5"/>
                        <circle cx="12" cy="12" r="9.5"/>
                    </svg>
                </a>


                <div data-locale-open class="button-round {{$classPrefix}}__setting-button"
                     data-lang="{{ $currentLocale }}">
                    {{ $languages[$currentLocale] ?? 'Язык' }}
                </div>


            </div>
        </div>
    </div>
</div>
