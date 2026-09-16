@php
    use Illuminate\Support\Facades\Storage;
    $classPrefix ='contact';
    $dataPrefix ='data-contact';
  $links = \App\Models\SocialLink::where(function ($query) {
                $query->whereHas('region', function ($query)  {
                    $query->where('code', 'dubai');
                })->orWhereDoesntHave('region');
            })->get();
   $callUs = \App\Models\CallUs::first();
   $phone = $callUs?->phone_dubai;
   $email = $callUs?->email_dubai;
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}">
    <h1 class="{{$classPrefix}}__title">
        <span class="{{$classPrefix}}__title-row {{$classPrefix}}__title-left"> {{__('static.call_1')}}</span>
        <span class="{{$classPrefix}}__title-row {{$classPrefix}}__title-right"> {{__('static.call_2')}}</span>
    </h1>
    <div class="{{$classPrefix}}__container">
        <div class="{{$classPrefix}}__container-top">
            @if($phone)
                <div class="{{$classPrefix}}__container-phone">
                    <a class="link link--hover" href="tel:{{ preg_replace('/[^\d+]/', '', $phone) }}">
                        {{$phone}}
                    </a>
                </div>
            @endif
            @if($email)
                <div class="{{$classPrefix}}__container-mail">
                    <a class="link link--anim" href="mailto:{{$email}}">
                        {{$email}}
                    </a>
                </div>
            @endif
        </div>
        <div class="{{ $classPrefix }}__container-bot">
            @foreach($links as $link)
                @php
                    $parts = explode(' ', $link->icon);
$style = $parts[0] ?? 'default';
$icon  = $parts[1] ?? null;
           $iconPath = "{$style}/{$icon}.svg";
           $svg = $icon && Storage::disk('nova-icon-field')->exists($iconPath)
               ? Storage::disk('nova-icon-field')->get($iconPath)
               : '';
                @endphp

                <a class="link link--anim {{ $classPrefix }}__container-social"
                   href="{{ $link->url }}"
                   rel="nofollow noindex"
                   target="_blank">
                    {{$link->platform}}
                    {!! $svg !!}
                </a>
            @endforeach
        </div>
    </div>

</div>
