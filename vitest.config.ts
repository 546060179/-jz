import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue';
import path from 'path';

export default defineConfig({
  plugins: [vue()],
  root: path.resolve(__dirname),
  resolve: {
    alias: {
      '@fade-animation/core': path.resolve(__dirname, 'packages/core/src'),
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    include: ['packages/*/src/**/*.test.{ts,tsx}'],
  },
});
