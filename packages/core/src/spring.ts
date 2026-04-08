/**
 * Spring Physics 弹簧动画引擎
 *
 * 基于阻尼谐振子模型（Damped Harmonic Oscillator），
 * 和 iOS UIKit Spring / Android SpringAnimation 使用相同的物理模型。
 *
 * 参数说明：
 * - stiffness: 刚度，越大弹簧越硬、振动越快（默认 100）
 * - damping: 阻尼，越大衰减越快、弹跳越少（默认 10）
 * - mass: 质量，越大惯性越大、运动越慢（默认 1）
 * - velocity: 初始速度（默认 0）
 */

export interface SpringConfig {
  /** 刚度，默认 100 */
  stiffness?: number;
  /** 阻尼，默认 10 */
  damping?: number;
  /** 质量，默认 1 */
  mass?: number;
  /** 初始速度，默认 0 */
  velocity?: number;
  /** 精度阈值，位移和速度都小于此值时视为静止，默认 0.001 */
  restThreshold?: number;
}

/** 预设弹簧配置 */
export const SPRING_PRESETS = {
  /** 轻柔弹跳，适合 UI 元素进入 */
  gentle: { stiffness: 120, damping: 14, mass: 1 },
  /** 快速响应，适合按钮反馈 */
  snappy: { stiffness: 300, damping: 20, mass: 1 },
  /** 明显弹跳，适合品牌个性动效 */
  bouncy: { stiffness: 200, damping: 10, mass: 1 },
  /** 缓慢柔和，适合大面积过渡 */
  slow: { stiffness: 80, damping: 12, mass: 1.5 },
  /** 无弹跳，临界阻尼 */
  noWobble: { stiffness: 170, damping: 26, mass: 1 },
} as const;

export type SpringPresetName = keyof typeof SPRING_PRESETS;

/** Spring 求解器的单帧状态 */
export interface SpringState {
  /** 当前位置（0 = 起点，1 = 终点） */
  position: number;
  /** 当前速度 */
  velocity: number;
  /** 是否已到达静止状态 */
  atRest: boolean;
}

/**
 * 创建一个 Spring 求解器。
 *
 * 返回一个 step 函数，每次调用传入时间步长（秒），
 * 返回当前状态。用于 rAF 循环驱动动画。
 *
 * @example
 * const spring = createSpring({ stiffness: 200, damping: 15 });
 * function animate() {
 *   const state = spring.step(1/60);
 *   element.style.transform = `scale(${0.95 + 0.05 * state.position})`;
 *   if (!state.atRest) requestAnimationFrame(animate);
 * }
 * animate();
 */
export function createSpring(config: SpringConfig = {}) {
  const {
    stiffness = 100,
    damping = 10,
    mass = 1,
    velocity: initialVelocity = 0,
    restThreshold = 0.001,
  } = config;

  let position = 0; // 从 0 开始，目标是 1
  let velocity = initialVelocity;

  return {
    step(dt: number): SpringState {
      // 弹簧力 = -stiffness * (position - target)
      // 阻尼力 = -damping * velocity
      // F = ma → a = F/m
      const target = 1;
      const displacement = position - target;
      const springForce = -stiffness * displacement;
      const dampingForce = -damping * velocity;
      const acceleration = (springForce + dampingForce) / mass;

      velocity += acceleration * dt;
      position += velocity * dt;

      const atRest =
        Math.abs(velocity) < restThreshold &&
        Math.abs(position - target) < restThreshold;

      if (atRest) {
        position = target;
        velocity = 0;
      }

      return { position, velocity, atRest };
    },

    /** 重置到初始状态 */
    reset() {
      position = 0;
      velocity = initialVelocity;
    },

    /** 获取当前状态（不推进时间） */
    current(): SpringState {
      const target = 1;
      return {
        position,
        velocity,
        atRest:
          Math.abs(velocity) < restThreshold &&
          Math.abs(position - target) < restThreshold,
      };
    },
  };
}

/**
 * 预计算 spring 动画的总时长（ms）。
 * 通过模拟求解器直到静止来估算。
 */
export function estimateSpringDuration(config: SpringConfig = {}): number {
  const spring = createSpring(config);
  const dt = 1 / 60; // 60fps
  let frames = 0;
  const maxFrames = 600; // 最多 10 秒

  while (frames < maxFrames) {
    const state = spring.step(dt);
    frames++;
    if (state.atRest) break;
  }

  return Math.round(frames * (1000 / 60));
}
