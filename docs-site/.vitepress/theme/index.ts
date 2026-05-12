import DefaultTheme from 'vitepress/theme';
import type { Theme } from 'vitepress';
import AnimationDemo from './components/AnimationDemo.vue';
import VisualEditor from './components/VisualEditor.vue';
import AIPromptBlock from './components/AIPromptBlock.vue';
import PreviewCard from './components/PreviewCard.vue';
import CaseGrid from './components/CaseGrid.vue';
import './styles.css';

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    // Register globally so any markdown page can use them without imports
    app.component('AnimationDemo', AnimationDemo);
    app.component('VisualEditor', VisualEditor);
    app.component('AIPromptBlock', AIPromptBlock);
    app.component('PreviewCard', PreviewCard);
    app.component('CaseGrid', CaseGrid);
  },
} satisfies Theme;
