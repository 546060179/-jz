# react-continue-watching

A React component for "Continue Watching" banner with smooth collapse-to-widget animation.

## Features

- Banner slides up with title, cover image, play button
- Auto-collapses after configurable delay with right-to-left clipping animation
- Morphs into a floating widget with play/dismiss controls
- Fully customizable timing, sizes, and positioning
- Imperative API via `ref` for programmatic control
- Zero dependencies (besides React)

## Install

```bash
npm install react-continue-watching
```

## Usage

```tsx
import { ContinueWatching } from 'react-continue-watching';

function App() {
  return (
    <div style={{ position: 'relative', width: 375, height: 812 }}>
      {/* Your content */}
      <ContinueWatching
        cover="/path/to/cover.jpg"
        title="Genius Baby: Daddy Please Take Mommy Away"
        subtitle="EP.1 / EP.100"
        autoShow
        collapseDelay={3000}
        onPlay={() => console.log('play')}
        onDismiss={() => console.log('dismissed')}
      />
    </div>
  );
}
```

## Imperative API

```tsx
import { useRef } from 'react';
import { ContinueWatching, ContinueWatchingRef } from 'react-continue-watching';

function App() {
  const ref = useRef<ContinueWatchingRef>(null);

  return (
    <>
      <button onClick={() => ref.current?.show()}>Show</button>
      <button onClick={() => ref.current?.collapse()}>Collapse</button>
      <button onClick={() => ref.current?.dismiss()}>Dismiss</button>
      <ContinueWatching ref={ref} cover="/cover.jpg" title="My Show" />
    </>
  );
}
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `cover` | `string` | required | Cover image URL |
| `title` | `string` | required | Title text |
| `subtitle` | `string` | — | Subtitle / episode info |
| `autoShow` | `boolean` | `false` | Auto-show on mount |
| `collapseDelay` | `number` | `3000` | Delay before auto-collapse (ms) |
| `collapseDuration` | `number` | `600` | Collapse animation duration (ms) |
| `growDuration` | `number` | `600` | Grow-to-widget duration (ms) |
| `widgetSize` | `{ width, height }` | `{ 90, 120 }` | Widget dimensions (px) |
| `widgetPosition` | `{ left, bottom }` | `{ 0, 91 }` | Widget position (px) |
| `onPlay` | `() => void` | — | Play button callback |
| `onDismiss` | `() => void` | — | Dismiss callback |
| `onCollapsed` | `() => void` | — | Collapse complete callback |
| `className` | `string` | — | Custom class on root |
| `style` | `CSSProperties` | — | Custom style on root |

## Ref Methods

| Method | Description |
|--------|-------------|
| `show()` | Show the banner |
| `collapse()` | Trigger collapse animation |
| `dismiss()` | Dismiss the widget |

## License

MIT
