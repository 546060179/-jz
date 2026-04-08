# Accessibility Standards

## Overview

This guide provides comprehensive accessibility standards and best practices for building WCAG 2.2 Level AA compliant user interfaces. Use this guidance whenever you're implementing UI components, forms, interactive elements, or any user-facing features to ensure they are accessible to all users, including those using assistive technologies.

## WCAG 2.2 Level AA Requirements

The Web Content Accessibility Guidelines (WCAG) 2.2 are organized around four core principles, often abbreviated as POUR:

### 1. Perceivable

Information and user interface components must be presentable to users in ways they can perceive.

**1.1 Text Alternatives**

- Provide text alternatives for non-text content (images, icons, charts)
- Use descriptive `alt` attributes for images that convey information
- Use `alt=""` for decorative images
- Provide captions and transcripts for audio/video content

**1.2 Time-based Media**

- Provide captions for pre-recorded and live audio content
- Provide audio descriptions for pre-recorded video content
- Provide transcripts for audio-only content

**1.3 Adaptable**

- Create content that can be presented in different ways without losing information
- Use semantic HTML elements (`<nav>`, `<main>`, `<article>`, `<section>`, `<header>`, `<footer>`)
- Ensure proper heading hierarchy (h1 → h2 → h3, no skipping levels)
- Use ARIA landmarks when semantic HTML is insufficient
- Ensure reading order matches visual order

**1.4 Distinguishable**

- **Color Contrast**: Minimum 4.5:1 ratio for normal text, 3:1 for large text (18pt+ or 14pt+ bold)
- **Color Independence**: Don't rely solely on color to convey information
- **Text Resize**: Text can be resized up to 200% without loss of functionality
- **Text Spacing**: Support increased line height, paragraph spacing, letter spacing, and word spacing
- **Reflow**: Content reflows at 320px width without horizontal scrolling
- **Focus Visible**: Keyboard focus indicator is clearly visible

### 2. Operable

User interface components and navigation must be operable.

**2.1 Keyboard Accessible**

- All functionality available via keyboard
- No keyboard traps (users can navigate away from any component)
- Provide keyboard shortcuts where appropriate
- Ensure logical tab order

**2.2 Enough Time**

- Provide users enough time to read and use content
- Allow users to turn off, adjust, or extend time limits
- Warn users before time expires

**2.3 Seizures and Physical Reactions**

- Don't design content that flashes more than 3 times per second
- Avoid motion that could trigger vestibular disorders

**2.4 Navigable**

- Provide ways to help users navigate and find content
- Skip links to bypass repeated content
- Descriptive page titles
- Logical focus order
- Clear link purpose (avoid "click here")
- Multiple ways to find pages (search, sitemap, navigation)
- Visible focus indicator
- Descriptive headings and labels

**2.5 Input Modalities**

- Support various input methods beyond keyboard
- Ensure touch targets are at least 44×44 pixels
- Provide labels for user interface components
- Support pointer cancellation (actions occur on up-event, not down-event)

### 3. Understandable

Information and the operation of user interface must be understandable.

**3.1 Readable**

- Specify page language with `lang` attribute
- Specify language changes within content
- Avoid unusual words or provide definitions
- Provide explanations for abbreviations

**3.2 Predictable**

- Components behave consistently across the site
- Navigation appears in consistent locations
- Components are identified consistently
- No automatic context changes on focus
- No automatic context changes on input (unless user is warned)

**3.3 Input Assistance**

- Identify and describe input errors clearly
- Provide labels or instructions for user input
- Provide suggestions for correcting errors
- Allow error prevention for legal/financial/data submissions (confirmation, reversible, or checked)

### 4. Robust

Content must be robust enough to be interpreted by a wide variety of user agents, including assistive technologies.

**4.1 Compatible**

- Use valid HTML (proper nesting, unique IDs, complete start/end tags)
- Provide name and role for all UI components
- Ensure status messages can be programmatically determined (ARIA live regions)
- Use ARIA attributes correctly and only when necessary

## Accessibility Testing Checklist

Use this checklist to verify accessibility compliance before shipping:

### Automated Testing

- [ ] Run axe-core or similar automated accessibility scanner
- [ ] Check color contrast ratios with browser DevTools or contrast checker
- [ ] Validate HTML with W3C validator
- [ ] Run Lighthouse accessibility audit

### Keyboard Testing

- [ ] Navigate entire page using only Tab, Shift+Tab, Enter, Space, and Arrow keys
- [ ] Verify all interactive elements are reachable
- [ ] Verify focus indicator is clearly visible on all elements
- [ ] Verify no keyboard traps exist
- [ ] Test keyboard shortcuts don't conflict with assistive technology

### Screen Reader Testing

- [ ] Test with at least one screen reader (NVDA, JAWS, VoiceOver, TalkBack)
- [ ] Verify all images have appropriate alt text
- [ ] Verify form labels are properly associated
- [ ] Verify headings create logical document outline
- [ ] Verify ARIA labels and descriptions are meaningful
- [ ] Verify dynamic content updates are announced

### Visual Testing

- [ ] Zoom page to 200% and verify no content is cut off
- [ ] Test with Windows High Contrast Mode
- [ ] Verify content reflows properly at 320px width
- [ ] Test with increased text spacing
- [ ] Verify color is not the only means of conveying information

### Form Testing

- [ ] Verify all form fields have visible labels
- [ ] Verify error messages are clear and associated with fields
- [ ] Verify required fields are indicated
- [ ] Verify form can be completed using only keyboard
- [ ] Verify validation errors are announced to screen readers

### Interactive Component Testing

- [ ] Verify modals trap focus and return focus on close
- [ ] Verify dropdowns are keyboard accessible
- [ ] Verify custom controls have appropriate ARIA roles and states
- [ ] Verify tooltips are accessible via keyboard
- [ ] Verify carousels can be paused and controlled via keyboard

## Common Accessible Patterns

### Accessible Button

```jsx
// ✅ Good: Semantic button with clear label
<button
  type="button"
  onClick={handleClick}
  aria-label="Close dialog"
>
  <CloseIcon aria-hidden="true" />
</button>

// ✅ Good: Button with visible text
<button type="submit">
  Submit Form
</button>

// ❌ Bad: Div styled as button
<div onClick={handleClick}>Click me</div>

// ❌ Bad: Button without accessible label
<button onClick={handleClick}>
  <CloseIcon />
</button>
```

**Best Practices:**

- Use `<button>` element for actions, `<a>` for navigation
- Provide accessible labels (visible text or `aria-label`)
- Use `type="button"` to prevent form submission
- Ensure minimum 44×44px touch target size
- Hide decorative icons from screen readers with `aria-hidden="true"`

### Accessible Form

```jsx
// ✅ Good: Properly labeled form with error handling
<form onSubmit={handleSubmit}>
  <div>
    <label htmlFor="email">
      Email Address <span aria-label="required">*</span>
    </label>
    <input
      id="email"
      type="email"
      name="email"
      required
      aria-required="true"
      aria-invalid={errors.email ? "true" : "false"}
      aria-describedby={errors.email ? "email-error" : undefined}
    />
    {errors.email && (
      <span id="email-error" role="alert" className="error">
        {errors.email}
      </span>
    )}
  </div>

  <div>
    <label htmlFor="password">Password</label>
    <input
      id="password"
      type="password"
      name="password"
      required
      aria-required="true"
      aria-describedby="password-hint"
    />
    <span id="password-hint" className="hint">
      Must be at least 8 characters
    </span>
  </div>

  <button type="submit">Sign In</button>
</form>

// ❌ Bad: Form without labels
<form>
  <input type="email" placeholder="Email" />
  <input type="password" placeholder="Password" />
  <button>Submit</button>
</form>
```

**Best Practices:**

- Always use `<label>` elements associated with inputs via `htmlFor`/`id`
- Use `aria-required` for required fields
- Use `aria-invalid` to indicate validation errors
- Use `aria-describedby` to associate hints and error messages
- Use `role="alert"` for error messages to announce them immediately
- Use appropriate input types (`email`, `tel`, `number`, `date`)
- Group related inputs with `<fieldset>` and `<legend>`

### Accessible Modal Dialog

```jsx
// ✅ Good: Accessible modal with focus management
function Modal({ isOpen, onClose, title, children }) {
  const modalRef = useRef(null);
  const previousFocusRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      // Store previously focused element
      previousFocusRef.current = document.activeElement;

      // Focus modal
      modalRef.current?.focus();

      // Trap focus within modal
      const handleKeyDown = (e) => {
        if (e.key === "Escape") {
          onClose();
        }
      };

      document.addEventListener("keydown", handleKeyDown);

      return () => {
        document.removeEventListener("keydown", handleKeyDown);
        // Restore focus when modal closes
        previousFocusRef.current?.focus();
      };
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose} role="presentation">
      <div
        ref={modalRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        tabIndex={-1}
      >
        <h2 id="modal-title">{title}</h2>

        <button
          onClick={onClose}
          aria-label="Close dialog"
          className="modal-close"
        >
          ×
        </button>

        <div className="modal-body">{children}</div>
      </div>
    </div>
  );
}

// ❌ Bad: Modal without proper ARIA and focus management
function BadModal({ isOpen, onClose, children }) {
  if (!isOpen) return null;

  return (
    <div className="modal">
      <div>{children}</div>
      <button onClick={onClose}>X</button>
    </div>
  );
}
```

**Best Practices:**

- Use `role="dialog"` and `aria-modal="true"`
- Use `aria-labelledby` to reference modal title
- Trap focus within modal (prevent tabbing to background content)
- Return focus to trigger element when modal closes
- Support Escape key to close modal
- Prevent background scrolling when modal is open
- Ensure close button is clearly labeled

### Accessible Navigation

```jsx
// ✅ Good: Semantic navigation with skip link
<>
  <a href="#main-content" className="skip-link">
    Skip to main content
  </a>

  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/" aria-current={isHome ? "page" : undefined}>Home</a></li>
      <li><a href="/about">About</a></li>
      <li><a href="/contact">Contact</a></li>
    </ul>
  </nav>

  <main id="main-content" tabIndex={-1}>
    {/* Page content */}
  </main>
</>

// ❌ Bad: Navigation without semantic HTML
<div className="nav">
  <div onClick={() => navigate('/')}>Home</div>
  <div onClick={() => navigate('/about')}>About</div>
</div>
```

**Best Practices:**

- Use `<nav>` element for navigation regions
- Provide `aria-label` when multiple nav elements exist
- Use `aria-current="page"` for current page link
- Provide skip links to bypass repetitive content
- Ensure links have descriptive text (avoid "click here")

### Accessible Custom Checkbox

```jsx
// ✅ Good: Custom checkbox with proper ARIA
function CustomCheckbox({ checked, onChange, label, id }) {
  return (
    <div className="checkbox-wrapper">
      <input
        type="checkbox"
        id={id}
        checked={checked}
        onChange={onChange}
        className="visually-hidden"
      />
      <label htmlFor={id}>
        <span
          className="custom-checkbox"
          role="checkbox"
          aria-checked={checked}
          tabIndex={0}
          onKeyDown={(e) => {
            if (e.key === ' ' || e.key === 'Enter') {
              e.preventDefault();
              onChange(!checked);
            }
          }}
        >
          {checked && <CheckIcon aria-hidden="true" />}
        </span>
        {label}
      </label>
    </div>
  );
}

// CSS for visually-hidden
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

**Best Practices:**

- Keep native input for accessibility, style custom visual
- Use `role="checkbox"` and `aria-checked` for custom visuals
- Support keyboard interaction (Space and Enter keys)
- Ensure focus indicator is visible
- Associate label with input

## Automated Testing Integration

### Using axe-core with Jest/Vitest

```bash
npm install --save-dev @axe-core/react jest-axe
```

```jsx
import { render } from "@testing-library/react";
import { axe, toHaveNoViolations } from "jest-axe";

expect.extend(toHaveNoViolations);

describe("Button accessibility", () => {
  it("should have no accessibility violations", async () => {
    const { container } = render(<button onClick={() => {}}>Click me</button>);

    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

### Using axe-core with Playwright

```javascript
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("should not have accessibility violations", async ({ page }) => {
  await page.goto("http://localhost:3000");

  const accessibilityScanResults = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  expect(accessibilityScanResults.violations).toEqual([]);
});
```

### Using React Testing Library with Accessibility Queries

```jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('form is accessible', () => {
  render(<LoginForm />);

  // Use accessible queries
  const emailInput = screen.getByLabelText(/email/i);
  const passwordInput = screen.getByLabelText(/password/i);
  const submitButton = screen.getByRole('button', { name: /sign in/i });

  // Test keyboard interaction
  await userEvent.type(emailInput, 'user@example.com');
  await userEvent.type(passwordInput, 'password123');
  await userEvent.click(submitButton);

  expect(emailInput).toHaveValue('user@example.com');
});
```

### Continuous Integration

Add accessibility testing to your CI pipeline:

```yaml
# .github/workflows/accessibility.yml
name: Accessibility Tests

on: [push, pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run test:a11y
      - run: npm run build
      - run: npm run lighthouse:ci
```

## ARIA Best Practices

### When to Use ARIA

**First Rule of ARIA**: Don't use ARIA if you can use native HTML instead.

```jsx
// ✅ Good: Use native HTML
<button>Click me</button>

// ❌ Bad: Unnecessary ARIA
<div role="button" tabIndex={0} onClick={handleClick}>Click me</div>
```

### Common ARIA Attributes

**Roles**: Define what an element is

- `role="button"`, `role="dialog"`, `role="alert"`, `role="navigation"`

**States**: Define current state of an element

- `aria-checked`, `aria-expanded`, `aria-selected`, `aria-pressed`

**Properties**: Define characteristics of an element

- `aria-label`, `aria-labelledby`, `aria-describedby`, `aria-required`

**Live Regions**: Announce dynamic content changes

- `aria-live="polite"` - announce when user is idle
- `aria-live="assertive"` - announce immediately
- `role="alert"` - equivalent to `aria-live="assertive"`

### ARIA Live Regions Example

```jsx
// ✅ Good: Announce status updates to screen readers
function SearchResults({ results, isLoading }) {
  return (
    <div>
      <div aria-live="polite" aria-atomic="true" className="sr-only">
        {isLoading ? "Loading results..." : `${results.length} results found`}
      </div>

      <ul>
        {results.map((result) => (
          <li key={result.id}>{result.title}</li>
        ))}
      </ul>
    </div>
  );
}
```

## Resources

### Official Standards and Guidelines

- [WCAG 2.2 Guidelines](https://www.w3.org/WAI/WCAG22/quickref/) - Complete WCAG 2.2 quick reference
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/) - Patterns and widgets
- [ARIA in HTML](https://www.w3.org/TR/html-aria/) - Using ARIA with HTML

### Testing Tools

- [axe DevTools](https://www.deque.com/axe/devtools/) - Browser extension for accessibility testing
- [WAVE](https://wave.webaim.org/) - Web accessibility evaluation tool
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) - Automated auditing tool
- [Color Contrast Analyzer](https://www.tpgi.com/color-contrast-checker/) - Check color contrast ratios

### Learning Resources

- [WebAIM](https://webaim.org/) - Web accessibility in mind
- [The A11y Project](https://www.a11yproject.com/) - Community-driven accessibility resource
- [Inclusive Components](https://inclusive-components.design/) - Accessible component patterns
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility) - Comprehensive accessibility docs

### Screen Readers

- [NVDA](https://www.nvaccess.org/) - Free screen reader for Windows
- [JAWS](https://www.freedomscientific.com/products/software/jaws/) - Popular screen reader for Windows
- [VoiceOver](https://www.apple.com/accessibility/voiceover/) - Built-in screen reader for macOS/iOS
- [TalkBack](https://support.google.com/accessibility/android/answer/6283677) - Built-in screen reader for Android

### Communities and Support

- [WebAIM Discussion List](https://webaim.org/discussion/) - Email list for accessibility questions
- [A11y Slack](https://web-a11y.slack.com/) - Accessibility community on Slack
- [Accessibility Stack Exchange](https://accessibility.stackexchange.com/) - Q&A for accessibility

## Quick Reference: Common Issues and Fixes

| Issue                         | Fix                                                                         |
| ----------------------------- | --------------------------------------------------------------------------- |
| Image without alt text        | Add `alt` attribute with descriptive text or `alt=""` for decorative images |
| Low color contrast            | Increase contrast to at least 4.5:1 for normal text, 3:1 for large text     |
| Missing form labels           | Add `<label>` element with `htmlFor` matching input `id`                    |
| Keyboard trap                 | Ensure Tab key can navigate away from all components                        |
| No focus indicator            | Add visible `:focus` styles (outline, border, shadow)                       |
| Div/span as button            | Replace with `<button>` element                                             |
| Missing heading hierarchy     | Use proper heading levels (h1 → h2 → h3) without skipping                   |
| Modal doesn't trap focus      | Implement focus trap and return focus on close                              |
| Dynamic content not announced | Use `aria-live` regions or `role="alert"`                                   |
| Custom control without ARIA   | Add appropriate `role`, `aria-*` attributes, and keyboard support           |
