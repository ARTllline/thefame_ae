@php
    $classPrefix = 'filter';
    $dataPrefix = 'data-filter';
@endphp

@if($filterData['type'] == 'checkbox')
    <div {{$dataPrefix}} data-filter-type="{{$filterData['type']}}" data-filter-for="{{$filterData['for']}}"
         class="{{$classPrefix}}">
        <div class="{{$classPrefix}}__header">
            <div class="{{$classPrefix}}__header-title">
                {{$filterData['label']}}
            </div>
        </div>
        <div class="{{$classPrefix}}__body">
            <ul class="{{$classPrefix}}__list">
                @foreach($filterData['options'] as $option)
                    <li data-filter-value="{{$option['value'] ?? $option['id']}}" class="{{$classPrefix}}__list-item">
                        {{$option['title']}}
                    </li>
                @endforeach
            </ul>
        </div>
    </div>
@endif









