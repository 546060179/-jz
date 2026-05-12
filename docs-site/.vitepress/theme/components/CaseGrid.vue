<script setup lang="ts">
import casesJson from '../../../data/cases.json';
import PreviewCard from './PreviewCard.vue';

interface CaseShape {
  id: string;
  name: string;
  desc: string;
}
interface CategoryShape {
  id: string;
  label: string;
  count: number;
  cases: CaseShape[];
}

const categories = casesJson as CategoryShape[];

function engName(id: string): string {
  return id.split('-').map((s) => s.charAt(0).toUpperCase() + s.slice(1)).join('');
}
</script>

<template>
  <div>
    <div v-for="cat in categories" :key="cat.id" class="ku-cat-section" :id="`cat-${cat.id}`">
      <h2 class="ku-cat-title">
        {{ cat.label }}
        <span class="count">{{ cat.count }}</span>
      </h2>
      <div class="ku-cases">
        <a
          v-for="c in cat.cases"
          :key="c.id"
          :href="`/components/${cat.id}/${c.id}`"
          class="ku-case"
        >
          <div class="ku-case-preview">
            <PreviewCard :case-id="c.id" />
          </div>
          <div class="ku-case-info">
            <div class="ku-case-name">{{ c.name }}</div>
            <div class="ku-case-eng">{{ engName(c.id) }}</div>
          </div>
        </a>
      </div>
    </div>
  </div>
</template>
