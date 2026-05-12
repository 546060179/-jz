import { defineConfig, type DefaultTheme } from 'vitepress';
import casesJson from '../data/cases.json';

interface Category {
  id: string;
  label: string;
  count: number;
  cases: Array<{ id: string; name: string }>;
}

const categories = casesJson as Category[];

/** Build the full component sidebar from the extracted cases data */
function buildComponentSidebar(): DefaultTheme.SidebarItem[] {
  return categories.map((cat) => ({
    text: `${cat.label} (${cat.count})`,
    collapsed: false,
    items: cat.cases.map((c) => ({
      text: c.name,
      link: `/components/${cat.id}/${c.id}`,
    })),
  }));
}

export default defineConfig({
  title: 'Kinetic UI',
  description: '跨端动效组件库 — React / Vue / iOS / Android 四端统一 API',
  lang: 'zh-CN',
  cleanUrls: true,
  appearance: 'dark',
  lastUpdated: true,

  head: [
    ['meta', { name: 'theme-color', content: '#186CE5' }],
    ['link', { rel: 'icon', href: '/favicon.ico' }],
  ],

  themeConfig: {
    logo: { light: '/logo.png', dark: '/logo.png' },
    siteTitle: 'Kinetic UI',

    nav: [
      { text: '指南', link: '/guide/introduction', activeMatch: '^/guide/' },
      { text: '组件', link: '/components/overview', activeMatch: '^/components/' },
      { text: 'API', link: '/api/motion', activeMatch: '^/api/' },
      { text: '更新日志', link: '/changelog' },
    ],

    sidebar: {
      '/guide/': [
        {
          text: '入门',
          items: [
            { text: '介绍', link: '/guide/introduction' },
            { text: '安装', link: '/guide/installation' },
            { text: '快速开始', link: '/guide/quick-start' },
          ],
        },
        {
          text: '核心概念',
          items: [
            { text: '设计 Tokens', link: '/guide/design-tokens' },
            { text: '动画意图 (Intent)', link: '/guide/motion-intent' },
            { text: 'Presence 生命周期', link: '/guide/presence' },
            { text: '无障碍', link: '/guide/accessibility' },
          ],
        },
        {
          text: '四端接入',
          items: [
            { text: 'React', link: '/guide/react' },
            { text: 'Vue', link: '/guide/vue' },
            { text: 'iOS Swift', link: '/guide/ios' },
            { text: 'Android Kotlin', link: '/guide/android' },
          ],
        },
      ],
      '/components/': [
        {
          text: '总览',
          items: [{ text: '组件总览', link: '/components/overview' }],
        },
        ...buildComponentSidebar(),
      ],
      '/api/': [
        {
          text: 'React / Vue',
          items: [
            { text: 'Motion', link: '/api/motion' },
            { text: 'Fade', link: '/api/fade' },
            { text: 'FadeGroup', link: '/api/fade-group' },
            { text: 'Presence', link: '/api/presence' },
            { text: 'useSpring', link: '/api/use-spring' },
          ],
        },
        {
          text: '核心工具',
          items: [
            { text: 'stagger', link: '/api/stagger' },
            { text: 'planSequence', link: '/api/plan-sequence' },
            { text: 'resolveConfig', link: '/api/resolve-config' },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/546060179/jiuzhou' },
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: '© 2025 Kinetic UI (像素对齐组)',
    },

    outline: { level: [2, 3], label: '目录' },
    docFooter: { prev: '上一页', next: '下一页' },
    lastUpdatedText: '最后更新',
  },

  vite: {
    resolve: {
      alias: {
        '@data': new URL('../data/', import.meta.url).pathname,
      },
    },
  },
});
