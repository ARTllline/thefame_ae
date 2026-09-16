<template>
    <div class="px-6 py-4">
        <h3 class="text-lg font-bold mb-3">
            Видео-инструкция
        </h3>

        <video
            controls
            class="w-full rounded-lg shadow"
        >
            <source src="/video/instruction.mp4" type="video/mp4">
            Ваш браузер не поддерживает видео.
        </video>
    </div>
</template>

<script>
export default {
    props: ['card'],
}
</script>
