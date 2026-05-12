<script setup lang="ts">
import { getPreviewShape } from '../previewShapes';

defineProps<{ caseId: string }>();
</script>

<template>
  <div class="ku-preview-card">
    <div class="cp-wrap" v-html="getPreviewShape(caseId)"></div>
  </div>
</template>

<style scoped>
.ku-preview-card {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
}
.cp-wrap {
  transform: scale(1.4);
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
