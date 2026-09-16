@php
    $classPrefix ='services';
    $routeLocale = request()->route('locale');
    $serviceRouteName = $routeLocale ? 'localized.service' : 'service';
@endphp

<div class="{{$classPrefix}}">
    <div class="{{$classPrefix}}__header">
        <h2 class="{{$classPrefix}}__title">{{ __('static.services') }}</h2>
        <p class="{{$classPrefix}}__subtitle">
            {{ __('static.services_subtitle') }}
        </p>
        <p class="{{$classPrefix}}__subtitle-bottom">
            {{ __('static.services_not_found') }}
            <a href="https://wa.me/971525776016" target="_blank" class="{{$classPrefix}}__whatsapp-link">{{ __('static.contact_whatsapp') }}</a>
            {{ __('static.leave_inquiry') }}
        </p>
    </div>

    @foreach($categories as $category)
        <div class="{{$classPrefix}}__category">
            <div class="{{ $classPrefix }}__list">
                @foreach($category->services as $service)
                    <div class="{{$classPrefix}}__card">

                        <a href="{{ route($serviceRouteName, array_filter(['locale' => $routeLocale, 'service' => $service->code])) }}" class="{{$classPrefix}}__card-link">

                            <div class="{{$classPrefix}}__card-img">
                                <svg class="{{$classPrefix}}__card-moving-svg" viewBox="0 0 249 315" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path fill-rule="evenodd" clip-rule="evenodd"
                                          d="M113.725 0.0576457C155.841 1.85016 179.188 51.3647 204.077 89.9486C227.04 125.548 257.806 163.848 246.633 206.101C235.819 247 189.999 252.949 156.08 271.462C122.19 289.959 89.304 327.417 54.631 310.893C19.1847 294.001 13.0187 242.483 5.51397 199.706C-1.62244 159.029 -4.69707 117.208 14.4524 81.8779C36.9922 40.292 70.7221 -1.77262 113.725 0.0576457Z"
                                          fill="#f4e4e8"></path>
                                </svg>
                                <div class="{{$classPrefix}}__card-clip-path">
                                    <img fetchpriority="high" decoding="async"
                                         src="{{ $service->getFirstMediaUrl('main', 'webp') ?: asset('img/default.webp') }}"
                                         alt="{{ $service->title }}"/>
                                </div>
                            </div>
                            <div class="{{$classPrefix}}__card-name">
                                {{$service->title}}
                            </div>
                        </a>

                        <a class="link {{$classPrefix}}__card-action" href="{{ route($serviceRouteName, array_filter(['locale' => $routeLocale, 'service' => $service->code])) }}">
                            {{ __('static.price') }}
                            <svg class="{{$classPrefix}}__card-action-icon">
                                <use xlink:href="#link"></use>
                            </svg>
                        </a>

                    </div>
                @endforeach
            </div>
        </div>
    @endforeach

    @if($categories->flatMap->services->count() > 9)
        <div class="show-more-wrapper">
            <button type="button" data-load-more="services" class="btn-show-more">{{ __('static.show_more_services') }}</button>
        </div>
    @endif
</div>
