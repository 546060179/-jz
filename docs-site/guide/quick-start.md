# 快速开始

## React

```tsx
import { Motion, Fade, Presence } from '@fade-animation/react';

function Modal({ open, onClose, children }) {
  return (
    <Presence>
      {open && (
        <Fade key="overlay" in intent="enter">
          <div className="overlay" onClick={onClose} />
        </Fade>
      )}
      {open && (
        <Motion key="content" in effect="scale-fade-in" intent="enter">
          <div className="modal">{children}</div>
        </Motion>
      )}
    </Presence>
  );
}
```

## Vue 3

```vue
<script setup>
import { Motion, Fade, Presence } from '@fade-animation/vue';
defineProps<{ open: boolean }>();
</script>

<template>
  <Presence>
    <Fade v-if="open" key="overlay" in intent="enter">
      <div class="overlay" @click="$emit('close')" />
    </Fade>
    <Motion v-if="open" key="content" in effect="scale-fade-in" intent="enter">
      <div class="modal"><slot /></div>
    </Motion>
  </Presence>
</template>
```

## iOS Swift

```swift
import FadeAnimation
import UIKit

class ModalViewController: UIViewController {
  func show() {
    modalView.motion(
      entering: true,
      effects: EffectPresets.scaleFadeIn,
      options: FadeOptions(intent: .enter)
    )
  }

  func hide() {
    modalView.motion(
      entering: false,
      effects: EffectPresets.scaleFadeOut,
      options: FadeOptions(intent: .exit)
    ) { [weak self] in
      self?.modalView.removeFromSuperview()
    }
  }
}
```

## Android Kotlin

```kotlin
import com.fadeanimation.*

fun showModal() {
  MotionAnimator(
    modalView,
    FadeOptions(intent = MotionIntent.ENTER)
  ).start(entering = true, effects = EffectPresets.SCALE_FADE_IN)
}

fun hideModal() {
  MotionAnimator(
    modalView,
    FadeOptions(intent = MotionIntent.EXIT)
  ).start(
    entering = false,
    effects = EffectPresets.SCALE_FADE_OUT,
    onEnd = { (modalView.parent as? ViewGroup)?.removeView(modalView) }
  )
}
```

## 下一步

- [浏览所有动效组件](/components/overview)
- [理解 Design Tokens](/guide/design-tokens)
- [学习 Presence 生命周期管理](/guide/presence)
