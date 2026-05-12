/**
 * One-time extraction script: parses Desktop/index-2-1-1.html and writes
 * docs-site/data/cases.json with the full component catalog.
 *
 * Usage:
 *   npx tsx docs-site/scripts/extract-cases.ts
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const SOURCE_HTML = resolve(__dirname, '..', '..', 'Desktop', 'index-2-1-1.html');
const OUTPUT_JSON = resolve(__dirname, '..', 'data', 'cases.json');

function extract() {
  const html = readFileSync(SOURCE_HTML, 'utf8');

  // Grab the <script> block
  const scriptMatch = html.match(/<script>([\s\S]*?)<\/script>/);
  if (!scriptMatch) throw new Error('No <script> block found in source HTML');
  const script = scriptMatch[1];

  // Extract NAV and CASES declarations. NAV is an array literal, CASES is an
  // object literal. Both are assigned via `var NAV = ...;` / `var CASES = ...;`.
  const navMatch = script.match(/var NAV = (\[[\s\S]*?\]);/);
  const casesMatch = script.match(/var CASES = (\{[\s\S]*?\n\};)/);

  if (!navMatch || !casesMatch) {
    throw new Error('Could not locate NAV or CASES declarations');
  }

  // Evaluate in an isolated function scope. The source is trusted (our own HTML).
  // NAV contains SVG strings, which are plain strings — eval is fine here.
  // eslint-disable-next-line no-new-func
  const NAV: any[] = new Function('return ' + navMatch[1])();
  // eslint-disable-next-line no-new-func
  const CASES: Record<string, any[]> = new Function(
    'return ' + casesMatch[1].replace(/;$/, '')
  )();

  const categories = Object.keys(CASES).map((catId) => {
    const nav = NAV.find((n) => n.id === catId);
    return {
      id: catId,
      label: nav?.label ?? catId,
      count: CASES[catId].length,
      cases: CASES[catId].map((c) => ({
        id: c.id,
        name: c.name,
        icon: c.icon,
        desc: c.desc ?? '',
        tags: c.tags ?? [],
        effect: c.effect ?? '',
        duration: typeof c.duration === 'number' ? c.duration : 300,
        easing: c.easing ?? 'ease',
        scenario: c.scenario,
        react: c.react,
        vue: c.vue,
        swift: c.swift,
        kotlin: c.kotlin,
        cautions: c.cautions ?? [],
        tips: c.tips ?? [],
      })),
    };
  });

  writeFileSync(OUTPUT_JSON, JSON.stringify(categories, null, 2), 'utf8');
  const total = categories.reduce((sum, c) => sum + c.cases.length, 0);
  console.log(`✓ wrote ${OUTPUT_JSON} — ${categories.length} categories, ${total} cases`);
}

extract();
