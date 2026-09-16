@php
    $classPrefix ='global-loader';
      $dataPrefix ='data-global-loader';

@endphp


<div {{$dataPrefix}} class="{{$classPrefix}}">
    <div class="{{$classPrefix}}__loader">
        <div class="lds-ripple">
            <div></div>
            <div></div>
        </div>
    </div>

</div>
