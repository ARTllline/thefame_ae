@php
    $classPrefix ='modal';
    $dataPrefix ='data-modal';
    $currentRegionName = 'Dubai';
    $callUs = \App\Models\CallUs::first();
    $location = \App\Models\Location::first();
    $socialLinks = \App\Models\SocialLink::where(function ($query) {
        $query->whereHas('region', fn ($regionQuery) => $regionQuery->where('code', 'dubai'))
            ->orWhereDoesntHave('region');
    })->get();
    $whatsApp = $socialLinks->first(fn ($link) => strcasecmp((string) $link->platform, 'WhatsApp') === 0);
    $instagram = $socialLinks->first(fn ($link) => strcasecmp((string) $link->platform, 'Instagram') === 0);
    $phone = $callUs?->phone_dubai ?: $location?->phone ?: '+971 52 577 6016';
    $email = $callUs?->email_dubai ?: $location?->email ?: 'thefameclinicdmcc@gmail.com';
    $address = $location?->title ?: 'Fortune Tower, JLT Cluster C, Office 1704, Dubai, UAE';
    $phoneHref = preg_replace('/[^\d+]/', '', $phone);
    $whatsAppUrl = $whatsApp?->url ?: 'https://wa.me/971525776016';
    $instagramUrl = $instagram?->url ?: 'https://instagram.com/the.fame.dubai';
@endphp

<div {{$dataPrefix}}
     data-modal-request-error="{{ __('static.appointment_request_error') }}"
     class="{{$classPrefix}}">
    <form {{$dataPrefix}}-form class="{{$classPrefix}}__form" novalidate>
        <div class="{{$classPrefix}}__container">
            <div {{$dataPrefix}}-close class="{{$classPrefix}}__container-close"></div>

            <h3 class="{{$classPrefix}}__container-title">{{__('static.appointment')}}</h3>

            <p {{$dataPrefix}}-promo-subtitle class="{{$classPrefix}}__promo-subtitle" style="display: none;">
                Booking for the 1st visit with a 15% discount
            </p>

            <div {{$dataPrefix}}-name class="{{$classPrefix}}__container-input">
                <input placeholder="{{__('static.appointment_name')}}" name="name" type="text">
                <span class="{{$classPrefix}}__container-input-err-message">
                    {{__('static.appointment_error_name')}}
                </span>
            </div>

            <div {{$dataPrefix}}-phone class="{{$classPrefix}}__container-input {{$classPrefix}}__container-input--phone">
                <input placeholder="{{__('static.appointment_phone')}}" name="phone" class="tel-input" type="tel">
                <span class="{{$classPrefix}}__container-input-err-message">
                    {{__('static.appointment_error_phone')}}
                </span>
            </div>

            <div {{$dataPrefix}}-treatment class="{{$classPrefix}}__container-input {{$classPrefix}}__container-input--textarea">
                <p class="{{$classPrefix}}__input-label">{{__('static.modal_treatment_label')}}</p>
                <textarea placeholder="{{__('static.modal_treatment_placeholder')}}" name="treatment" rows="3"></textarea>
            </div>

            <input {{$dataPrefix}}-region type="hidden" name="region" value="{{$currentRegionName}}">
            <input {{$dataPrefix}}-form-type type="hidden" name="form_type" value="standard">

            <button type="submit" {{$dataPrefix}}-submit class="button button-clip {{$classPrefix}}__container-button">
                <span class="clip">
                    <span>{{__('static.sign_up')}}</span>
                    <span>{{__('static.sign_up')}}</span>
                </span>
            </button>
        </div>
    </form>

    <div {{$dataPrefix}}-success class="{{$classPrefix}}__success-page" style="display: none;">
        <div class="{{$classPrefix}}__container {{$classPrefix}}__container--success">
            <div {{$dataPrefix}}-success-close class="{{$classPrefix}}__container-close"></div>

            <h3 class="{{$classPrefix}}__success-title">{{__('static.modal_success_title')}}</h3>
            <p class="{{$classPrefix}}__success-subtitle">{{__('static.modal_success_subtitle')}}</p>

            <p class="{{$classPrefix}}__success-desc">
                {{__('static.modal_success_desc')}}
            </p>

            <div class="{{$classPrefix}}__success-contacts">
                <p class="{{$classPrefix}}__success-contacts-title">{{__('static.modal_success_contacts_title')}}</p>
                <a href="tel:{{ $phoneHref }}" class="contact-link">📞 {{ $phone }}</a>
                <a href="mailto:{{ $email }}" class="contact-link">✉️ {{ $email }}</a>
                <span class="contact-link">📍 {{ $address }}</span>

                <a href="{{ $whatsAppUrl }}" target="_blank" rel="noopener noreferrer" class="button {{$classPrefix}}__success-wa-btn">{{__('static.modal_success_wa_btn')}}</a>
            </div>

            <div class="{{$classPrefix}}__success-social">
                <p>{{__('static.modal_success_social_title')}}</p>
                <a href="{{ $instagramUrl }}" target="_blank" rel="noopener noreferrer" class="social-link">@the.fame.dubai</a>
            </div>
        </div>
    </div>
</div>
