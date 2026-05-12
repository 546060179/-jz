/**
 * Generates markdown pages for every component in cases.json.
 *
 * Output layout:
 *   components/overview.md              — the grid
 *   components/<category>/<case>.md     — one page per animation (37 files)
 *
 * Each detail page is a thin shell that just renders <AnimationDemo>.
 *
 * Usage:
 *   node --experimental-strip-types docs-site/scripts/gen-pages.ts
 */
import { mkdirSync, readFileSync, writeFileSync, rmSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const DATA_FILE = resolve(ROOT, 'data', 'cases.json');
const COMPONENTS_DIR = resolve(ROOT, 'components');

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

function main() {
  const data = JSON.parse(readFileSync(DATA_FILE, 'utf8')) as CategoryShape[];

  // Clean & recreate components/ dir
  rmSync(COMPONENTS_DIR, { recursive: true, force: true });
  mkdirSync(COMPONENTS_DIR, { recursive: true });

  // --- overview.md ---
  const overviewMd = [
    '---',
    'title: 组件总览',
    'description: Kinetic UI 全部动效组件',
    '---',
    '',
    '# 组件总览',
    '',
    '`Kinetic UI` 为跨端应用提供了丰富的动效组件，覆盖弹窗、转场、反馈、加载、编排、引导、手势七大场景。',
    '支持 React、Vue、iOS Swift、Android Kotlin 四端统一 API，开箱即用。',
    '',
    '<CaseGrid />',
    '',
  ].join('\n');
  writeFileSync(resolve(COMPONENTS_DIR, 'overview.md'), overviewMd, 'utf8');

  // --- per-case detail pages ---
  let detailCount = 0;
  for (const cat of data) {
    const catDir = resolve(COMPONENTS_DIR, cat.id);
    mkdirSync(catDir, { recursive: true });

    for (const c of cat.cases) {
      const md = [
        '---',
        `title: ${c.name}`,
        `description: ${c.desc}`,
        `outline: [2, 3]`,
        '---',
        '',
        `<AnimationDemo category-id="${cat.id}" case-id="${c.id}" />`,
        '',
      ].join('\n');
      writeFileSync(resolve(catDir, `${c.id}.md`), md, 'utf8');
      detailCount++;
    }
  }

  console.log(`✓ generated components/overview.md + ${detailCount} detail pages`);
}

main();
