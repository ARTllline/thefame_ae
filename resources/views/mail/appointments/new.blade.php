<x-mail::message>
# {{ $content->title() }}

@foreach ($content->rows() as $row)
**{{ $row['label'] }}:** {{ $row['value'] }}

@endforeach

Заявка вже збережена в адміністративній панелі.
</x-mail::message>

