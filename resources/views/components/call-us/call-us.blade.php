@php
    $classPrefix = 'call-us';
    $dataPrefix = 'data-call-us';
    $callUs = \App\Models\CallUs::first();

    $modifierClass = isset($modifier) && $modifier === 'footer' ? $classPrefix . '--footer' : '';
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}} {{$modifierClass}}">
    <div class="{{$classPrefix}}__moving-shape"></div>

    <div class="{{$classPrefix}}__container">
        <h2 class="{{$classPrefix}}__container-title">
            @if($callUs)
                {{$callUs->text}}
            @endif
        </h2>
        <div data-modal-open class="button button-clip {{$classPrefix}}__container-button">
            <span class="clip">
                <span>{{__('static.sign_up')}}</span>
                <span>{{__('static.sign_up')}}</span>
            </span>
        </div>
    </div>
</div>
