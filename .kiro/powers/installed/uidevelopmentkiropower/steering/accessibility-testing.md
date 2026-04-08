# Accessibility Testing

## Overview

This guide covers tools, strategies, and workflows for testing web accessibility. Use this when validating WCAG compliance, setting up automated accessibility testing, or conducting manual accessibility audits.

## Testing Layers

Comprehensive accessibility testing requires multiple approaches:

1. **Automated Testing**: Catches 30-40% of issues
2. **Manual Testing**: Catches complex interaction issues
3. **Screen Reader Testing**: Validates real user experience
4. **Keyboard Testing**: Ensures keyboard-only navigation works
5. **User Testing**: Validates with people with disabilities

## Automated Testing Tools

### axe-core

The industry-standard accessibility testing engine.

**Installation**:

```bash
npm install --save-dev @axe-core/react
# or for general use
npm install --save-dev axe-core
```

**React Integration**:

```jsx
// index.js (development only)
if (process.env.NODE_ENV !== "production") {
  import("@axe-core/react").then((axe) => {
    axe.default(React, ReactDOM, 1000);
  });
}
```

**Jest/Vitest Integration**:

```javascript
import { axe, toHaveNoViolations } from "jest-axe";

expect.extend(toHaveNoViolations);

test("Button should be accessible", async () => {
  const { container } = render(<Button>Click me</Button>);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

**Playwright Integration**:

```javascript
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("Homepage should be accessible", async ({ page }) => {
  await page.goto("https://example.com");

  const accessibilityScanResults = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  expect(accessibilityScanResults.violations).toEqual([]);
});
```

### eslint-plugin-jsx-a11y

Catch accessibility issues during development.

**Installation**:

```bash
npm install --save-dev eslint-plugin-jsx-a11y
```

**Configuration** (.eslintrc.json):

```json
{
  "extends": ["plugin:jsx-a11y/recommended"],
  "plugins": ["jsx-a11y"],
  "rules": {
    "jsx-a11y/alt-text": "error",
    "jsx-a11y/anchor-has-content": "error",
    "jsx-a11y/aria-props": "error",
    "jsx-a11y/aria-role": "error",
    "jsx-a11y/click-events-have-key-events": "error",
    "jsx-a11y/heading-has-content": "error",
    "jsx-a11y/label-has-associated-control": "error",
    "jsx-a11y/no-autofocus": "warn"
  }
}
```

### Lighthouse

Comprehensive auditing including accessibility.

**CLI Usage**:

```bash
npx lighthouse https://example.com --only-categories=accessibility --output=html --output-path=./lighthouse-report.html
```

**Programmatic Usage**:

```javascript
import lighthouse from "lighthouse";
import * as chromeLauncher from "chrome-launcher";

async function runLighthouse(url) {
  const chrome = await chromeLauncher.launch({ chromeFlags: ["--headless"] });

  const options = {
    logLevel: "info",
    output: "html",
    onlyCategories: ["accessibility"],
    port: chrome.port,
  };

  const runnerResult = await lighthouse(url, options);

  // Get accessibility score (0-100)
  const accessibilityScore =
    runnerResult.lhr.categories.accessibility.score * 100;

  await chrome.kill();

  return runnerResult;
}
```

**CI Integration**:

```yaml
# .github/workflows/accessibility.yml
name: Accessibility Tests

on: [push, pull_request]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Lighthouse
        uses: treosh/lighthouse-ci-action@v9
        with:
          urls: |
            https://example.com
            https://example.com/about
          uploadArtifacts: true
          temporaryPublicStorage: true
```

### pa11y

Automated accessibility testing tool.

**Installation**:

```bash
npm install --save-dev pa11y
```

**Usage**:

```javascript
import pa11y from "pa11y";

async function testAccessibility(url) {
  try {
    const results = await pa11y(url, {
      standard: "WCAG2AA",
      includeWarnings: true,
      includeNotices: false,
    });

    console.log(`Found ${results.issues.length} issues`);

    results.issues.forEach((issue) => {
      console.log(`${issue.type}: ${issue.message}`);
      console.log(`Element: ${issue.selector}`);
      console.log(`WCAG: ${issue.code}`);
    });
  } catch (error) {
    console.error("Error running pa11y:", error);
  }
}

testAccessibility("https://example.com");
```

## Manual Testing Workflows

### Keyboard Navigation Testing

Test all functionality using only the keyboard:

**Checklist**:

- [ ] Tab through all interactive elements in logical order
- [ ] Shift+Tab moves backward through elements
- [ ] Enter/Space activates buttons and links
- [ ] Arrow keys navigate within components (menus, tabs, etc.)
- [ ] Escape closes modals and dropdowns
- [ ] Focus is visible on all interactive elements
- [ ] No keyboard traps (can always move focus away)
- [ ] Skip links allow bypassing navigation

**Testing Script**:

```javascript
// Automated keyboard navigation test
test("All interactive elements are keyboard accessible", async () => {
  render(<App />);

  const interactiveElements = screen.getAllByRole(
    /button|link|textbox|checkbox|radio/
  );

  // Tab through all elements
  for (let i = 0; i < interactiveElements.length; i++) {
    userEvent.tab();
    expect(interactiveElements[i]).toHaveFocus();
  }

  // Shift+Tab backward
  for (let i = interactiveElements.length - 1; i >= 0; i--) {
    userEvent.tab({ shift: true });
    expect(interactiveElements[i]).toHaveFocus();
  }
});
```

### Focus Management Testing

Verify focus behavior in dynamic interfaces:

**Test Cases**:

```javascript
test("Modal traps focus and restores on close", async () => {
  const { getByRole } = render(<ModalExample />);

  const openButton = getByRole("button", { name: "Open Modal" });
  openButton.focus();

  // Open modal
  userEvent.click(openButton);

  const modal = getByRole("dialog");
  const closeButton = within(modal).getByRole("button", { name: "Close" });

  // Focus should move to modal
  expect(modal).toContainElement(document.activeElement);

  // Tab should stay within modal
  userEvent.tab();
  expect(modal).toContainElement(document.activeElement);

  // Close modal
  userEvent.click(closeButton);

  // Focus should return to open button
  expect(openButton).toHaveFocus();
});
```

### Color Contrast Testing

**Manual Tools**:

- Browser DevTools (Chrome, Firefox, Edge)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)

**Automated Testing**:

```javascript
import { getContrast } from "polished";

function checkContrast(foreground, background, fontSize, isBold) {
  const ratio = getContrast(foreground, background);
  const isLargeText = fontSize >= 18 || (fontSize >= 14 && isBold);
  const requiredRatio = isLargeText ? 3 : 4.5;

  return {
    ratio,
    passes: ratio >= requiredRatio,
    required: requiredRatio,
  };
}

test("Button text has sufficient contrast", () => {
  const result = checkContrast("#ffffff", "#0066cc", 16, false);
  expect(result.passes).toBe(true);
  expect(result.ratio).toBeGreaterThanOrEqual(4.5);
});
```

### ARIA Testing

Verify ARIA attributes are correct:

**Common Issues to Check**:

```javascript
test("ARIA attributes are valid", () => {
  const { container } = render(<Component />);

  // Check for invalid ARIA roles
  const invalidRoles = container.querySelectorAll('[role="invalid"]');
  expect(invalidRoles).toHaveLength(0);

  // Check aria-labelledby references exist
  const labelledByElements = container.querySelectorAll("[aria-labelledby]");
  labelledByElements.forEach((el) => {
    const labelId = el.getAttribute("aria-labelledby");
    const label = container.querySelector(`#${labelId}`);
    expect(label).toBeInTheDocument();
  });

  // Check aria-describedby references exist
  const describedByElements = container.querySelectorAll("[aria-describedby]");
  describedByElements.forEach((el) => {
    const descId = el.getAttribute("aria-describedby");
    const description = container.querySelector(`#${descId}`);
    expect(description).toBeInTheDocument();
  });
});
```

## Screen Reader Testing

### Screen Readers by Platform

- **Windows**: NVDA (free), JAWS (paid)
- **macOS**: VoiceOver (built-in)
- **iOS**: VoiceOver (built-in)
- **Android**: TalkBack (built-in)

### VoiceOver Testing (macOS)

**Enable VoiceOver**: Cmd + F5

**Basic Commands**:

- `VO + Right Arrow`: Next element
- `VO + Left Arrow`: Previous element
- `VO + Space`: Activate element
- `VO + A`: Read from current position
- `VO + U`: Open rotor (navigation menu)
- `Control`: Stop reading

**Testing Checklist**:

- [ ] All content is announced
- [ ] Interactive elements have clear labels
- [ ] Form inputs announce their purpose and state
- [ ] Error messages are announced
- [ ] Dynamic content updates are announced
- [ ] Images have meaningful alt text
- [ ] Headings create logical structure

### NVDA Testing (Windows)

**Enable NVDA**: Ctrl + Alt + N

**Basic Commands**:

- `Down Arrow`: Next element
- `Up Arrow`: Previous element
- `Enter/Space`: Activate element
- `Insert + Down Arrow`: Read from current position
- `Insert + F7`: Elements list
- `H`: Next heading
- `B`: Next button
- `F`: Next form field

### Testing Script Example

```javascript
// Verify screen reader announcements
test("Button announces correctly to screen readers", () => {
  const { getByRole } = render(
    <button aria-label="Delete item" aria-describedby="delete-help">
      <TrashIcon />
    </button>
  );

  const button = getByRole("button", { name: "Delete item" });

  // Verify accessible name
  expect(button).toHaveAccessibleName("Delete item");

  // Verify accessible description
  expect(button).toHaveAccessibleDescription();
});
```

## Component-Specific Testing

### Form Testing

```javascript
test("Form is accessible", async () => {
  const { container } = render(<ContactForm />);

  // All inputs have labels
  const inputs = container.querySelectorAll("input, textarea, select");
  inputs.forEach((input) => {
    const label = container.querySelector(`label[for="${input.id}"]`);
    expect(label).toBeInTheDocument();
  });

  // Required fields are marked
  const requiredInputs = container.querySelectorAll("[required]");
  requiredInputs.forEach((input) => {
    expect(input).toHaveAttribute("aria-required", "true");
  });

  // Error messages are associated
  const invalidInput = screen.getByLabelText("Email");
  userEvent.type(invalidInput, "invalid-email");
  userEvent.tab();

  await waitFor(() => {
    const errorId = invalidInput.getAttribute("aria-describedby");
    const errorMessage = container.querySelector(`#${errorId}`);
    expect(errorMessage).toHaveTextContent(/valid email/i);
  });

  // Run axe
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Modal/Dialog Testing

```javascript
test("Modal is accessible", async () => {
  const { getByRole } = render(<ModalExample />);

  // Open modal
  const openButton = getByRole("button", { name: "Open Modal" });
  userEvent.click(openButton);

  const modal = getByRole("dialog");

  // Has accessible name
  expect(modal).toHaveAccessibleName();

  // Has aria-modal
  expect(modal).toHaveAttribute("aria-modal", "true");

  // Focus is trapped
  const focusableElements = within(modal).getAllByRole(/button|link|textbox/);
  expect(focusableElements.length).toBeGreaterThan(0);

  // First element is focused
  expect(focusableElements[0]).toHaveFocus();

  // Escape closes modal
  userEvent.keyboard("{Escape}");
  expect(modal).not.toBeInTheDocument();

  // Focus returns to trigger
  expect(openButton).toHaveFocus();
});
```

### Navigation Testing

```javascript
test("Navigation is accessible", () => {
  const { container, getByRole } = render(<Navigation />);

  // Has nav landmark
  const nav = getByRole("navigation");
  expect(nav).toBeInTheDocument();

  // Has accessible name if multiple navs
  const navs = container.querySelectorAll("nav");
  if (navs.length > 1) {
    navs.forEach((nav) => {
      expect(nav).toHaveAttribute("aria-label");
    });
  }

  // Current page is marked
  const currentLink = within(nav).getByRole("link", { current: "page" });
  expect(currentLink).toHaveAttribute("aria-current", "page");

  // Skip link is present
  const skipLink = getByRole("link", { name: /skip to main content/i });
  expect(skipLink).toBeInTheDocument();
});
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Accessibility Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  a11y-tests:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Install dependencies
        run: npm ci

      - name: Run accessibility tests
        run: npm run test:a11y

      - name: Build application
        run: npm run build

      - name: Start server
        run: npm run start &

      - name: Wait for server
        run: npx wait-on http://localhost:3000

      - name: Run Lighthouse CI
        uses: treosh/lighthouse-ci-action@v9
        with:
          urls: |
            http://localhost:3000
            http://localhost:3000/about
          configPath: "./lighthouserc.json"
          uploadArtifacts: true

      - name: Run pa11y
        run: |
          npx pa11y-ci --config .pa11yci.json
```

### Lighthouse CI Configuration

```json
// lighthouserc.json
{
  "ci": {
    "collect": {
      "numberOfRuns": 3,
      "settings": {
        "onlyCategories": ["accessibility"]
      }
    },
    "assert": {
      "assertions": {
        "categories:accessibility": ["error", { "minScore": 0.9 }],
        "color-contrast": "error",
        "image-alt": "error",
        "label": "error",
        "aria-*": "error"
      }
    }
  }
}
```

### pa11y CI Configuration

```json
// .pa11yci.json
{
  "defaults": {
    "standard": "WCAG2AA",
    "timeout": 10000,
    "wait": 1000,
    "chromeLaunchConfig": {
      "args": ["--no-sandbox"]
    }
  },
  "urls": [
    "http://localhost:3000",
    "http://localhost:3000/about",
    "http://localhost:3000/contact"
  ]
}
```

## Testing Checklist

### Pre-Release Accessibility Audit

- [ ] **Automated Testing**

  - [ ] axe-core tests pass
  - [ ] Lighthouse accessibility score > 90
  - [ ] ESLint jsx-a11y rules pass
  - [ ] No console warnings about accessibility

- [ ] **Keyboard Testing**

  - [ ] All functionality accessible via keyboard
  - [ ] Focus order is logical
  - [ ] Focus is visible on all elements
  - [ ] No keyboard traps
  - [ ] Skip links work

- [ ] **Screen Reader Testing**

  - [ ] Test with VoiceOver (macOS/iOS)
  - [ ] Test with NVDA (Windows)
  - [ ] All content is announced
  - [ ] Form labels are clear
  - [ ] Error messages are announced
  - [ ] Dynamic updates are announced

- [ ] **Visual Testing**

  - [ ] Color contrast meets WCAG AA (4.5:1)
  - [ ] Text is readable at 200% zoom
  - [ ] No information conveyed by color alone
  - [ ] Focus indicators are visible

- [ ] **Content Testing**

  - [ ] All images have alt text
  - [ ] Headings create logical structure
  - [ ] Links have descriptive text
  - [ ] Form inputs have labels
  - [ ] Error messages are clear

- [ ] **Responsive Testing**
  - [ ] Works at 320px width
  - [ ] Works at 200% zoom
  - [ ] Touch targets are 44x44px minimum
  - [ ] No horizontal scrolling

## Best Practices

### Do's

- ✅ Test early and often during development
- ✅ Use automated tools as a first pass
- ✅ Always follow up with manual testing
- ✅ Test with real screen readers
- ✅ Test with keyboard only
- ✅ Include accessibility tests in CI/CD
- ✅ Fix issues as they're found
- ✅ Document accessibility features
- ✅ Test with users with disabilities when possible
- ✅ Keep accessibility testing tools updated

### Don'ts

- ❌ Don't rely solely on automated testing
- ❌ Don't ignore warnings from testing tools
- ❌ Don't test only on one browser
- ❌ Don't skip keyboard testing
- ❌ Don't assume automated tests catch everything
- ❌ Don't test only at the end of development
- ❌ Don't ignore screen reader testing
- ❌ Don't forget mobile accessibility
- ❌ Don't disable accessibility features to "fix" issues

## Resources

### Testing Tools

- [axe DevTools](https://www.deque.com/axe/devtools/) - Browser extension
- [WAVE](https://wave.webaim.org/) - Web accessibility evaluation tool
- [Accessibility Insights](https://accessibilityinsights.io/) - Microsoft's testing tool
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) - Google's auditing tool

### Screen Readers

- [NVDA](https://www.nvaccess.org/) - Free Windows screen reader
- [JAWS](https://www.freedomscientific.com/products/software/jaws/) - Popular Windows screen reader
- [VoiceOver](https://www.apple.com/accessibility/voiceover/) - Built-in macOS/iOS screen reader
- [TalkBack](https://support.google.com/accessibility/android/answer/6283677) - Built-in Android screen reader

### Learning Resources

- [WebAIM](https://webaim.org/) - Web accessibility resources
- [A11y Project](https://www.a11yproject.com/) - Community-driven accessibility resources
- [Deque University](https://dequeuniversity.com/) - Accessibility training
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility) - Mozilla's accessibility docs

### Standards

- [WCAG 2.2](https://www.w3.org/WAI/WCAG22/quickref/) - Quick reference guide
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/) - ARIA patterns and examples
- [Section 508](https://www.section508.gov/) - US federal accessibility standards
