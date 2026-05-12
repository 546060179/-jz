/**
 * Preview markup per case id.
 * Ported from Desktop/index-2-1-1.html `getCasePreviewHTML`.
 * Returns inline HTML string rendered via v-html in <PreviewCard>.
 */
export const PREVIEW_SHAPES: Record<string, string> = {
  // Popup
  modal: '<div class="cp-el" style="width:64px;height:44px;border-radius:8px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.12);box-shadow:0 4px 16px rgba(0,0,0,.3);display:flex;align-items:center;justify-content:center"><div style="width:32px;height:5px;border-radius:3px;background:var(--ku-c)"></div></div>',
  toast: '<div class="cp-el" style="padding:6px 14px;border-radius:6px;background:rgba(255,255,255,.1);color:var(--ku-t1);font-size:10px;white-space:nowrap;border:1px solid rgba(255,255,255,.08)">操作成功</div>',
  drawer: '<div class="cp-el" style="display:flex;width:64px;height:44px;border-radius:6px;overflow:hidden;border:1px solid rgba(255,255,255,.1)"><div style="width:22px;background:var(--ku-c);border-radius:5px 0 0 5px"></div><div style="flex:1;background:rgba(255,255,255,.04)"></div></div>',
  actionsheet: '<div class="cp-el" style="width:56px;display:flex;flex-direction:column;gap:3px"><div style="height:8px;border-radius:4px 4px 0 0;background:var(--ku-c)"></div><div style="height:8px;background:var(--ku-c);opacity:.6"></div><div style="height:8px;border-radius:0 0 4px 4px;background:var(--ku-c);opacity:.3"></div></div>',
  notification: '<div class="cp-el" style="width:64px;padding:6px 8px;border-radius:6px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);box-shadow:0 2px 8px rgba(0,0,0,.2)"><div style="width:100%;height:5px;border-radius:3px;background:var(--ku-c);margin-bottom:4px"></div><div style="width:60%;height:4px;border-radius:2px;background:rgba(255,255,255,.1)"></div></div>',
  'continue-watching': '<div class="cp-el" style="width:72px;height:22px;border-radius:10px;background:rgba(255,255,255,.06);display:flex;align-items:center;gap:3px;padding:3px 4px 3px 3px"><div style="width:15px;height:16px;border-radius:3px;background:var(--ku-c);flex-shrink:0"></div><div style="flex:1;min-width:0;display:flex;flex-direction:column;gap:1px"><div style="width:22px;height:2.5px;border-radius:1px;background:#fff"></div><div style="width:14px;height:2px;border-radius:1px;background:rgba(255,255,255,.35)"></div></div><div style="width:10px;height:10px;border-radius:50%;background:var(--ku-c);display:flex;align-items:center;justify-content:center;flex-shrink:0"><div style="width:0;height:0;border-top:3px solid transparent;border-bottom:3px solid transparent;border-left:4.5px solid #fff;margin-left:1px"></div></div></div>',

  // Feedback
  press: '<div class="cp-el" style="padding:8px 20px;border-radius:8px;background:var(--ku-c);color:#fff;font-size:11px;font-weight:600">按钮</div>',
  shake: '<div class="cp-el" style="width:56px;height:28px;border-radius:6px;border:1.5px solid var(--ku-c);display:flex;align-items:center;padding:0 8px"><div style="width:100%;height:4px;border-radius:2px;background:rgba(255,255,255,.1)"></div></div>',
  success: '<div class="cp-el" style="width:42px;height:42px;border-radius:50%;background:rgba(24,108,229,.1);border:2px solid var(--ku-c);display:flex;align-items:center;justify-content:center;color:var(--ku-c);font-size:20px;font-weight:700">✓</div>',
  pulse: '<div class="cp-el" style="position:relative"><div style="width:16px;height:16px;border-radius:50%;background:var(--ku-c);box-shadow:0 0 8px rgba(24,108,229,.4)"></div></div>',
  ripple: '<div class="cp-el" style="width:40px;height:28px;border-radius:6px;background:var(--ku-c);display:flex;align-items:center;justify-content:center;color:#fff;font-size:9px">点击</div>',

  // Transition
  'fade-in': '<div class="cp-el" style="width:48px;height:32px;border-radius:6px;background:var(--ku-c);display:flex;align-items:center;justify-content:center;color:#fff;font-size:8px">内容</div>',
  'blur-in': '<div class="cp-el" style="width:44px;height:30px;border-radius:4px;background:var(--ku-c)"></div>',
  'flip-in': '<div class="cp-el" style="width:40px;height:28px;border-radius:4px;background:var(--ku-c);display:flex;align-items:center;justify-content:center;color:#fff;font-size:8px;perspective:200px">正面</div>',
  collapse: '<div class="cp-el" style="width:48px;display:flex;flex-direction:column;gap:2px"><div style="height:6px;border-radius:3px;background:var(--ku-c)"></div><div style="height:10px;border-radius:3px;background:var(--ku-c);opacity:.4"></div><div style="height:6px;border-radius:3px;background:var(--ku-c)"></div></div>',
  'slide-in': '<div class="cp-el" style="width:48px;height:32px;border-radius:6px;background:var(--ku-c);display:flex;align-items:center;justify-content:center;color:#fff;font-size:8px;opacity:.8">页面</div>',

  // Loading
  spinner: '<div class="cp-el" style="width:28px;height:28px;border:3px solid rgba(255,255,255,.15);border-top-color:var(--ku-c);border-radius:50%"></div>',
  progress: '<div class="cp-el" style="width:52px;height:6px;border-radius:3px;background:rgba(255,255,255,.15);overflow:hidden"><div style="width:0;height:100%;border-radius:3px;background:var(--ku-c)"></div></div>',
  typing: '<div class="cp-el" style="display:flex;gap:4px;align-items:center"><div style="width:8px;height:8px;border-radius:50%;background:var(--ku-c)"></div><div style="width:8px;height:8px;border-radius:50%;background:var(--ku-c);opacity:.6"></div><div style="width:8px;height:8px;border-radius:50%;background:var(--ku-c);opacity:.3"></div></div>',
  wave: '<div class="cp-el" style="display:flex;gap:2px;align-items:end;height:28px"><div style="width:3px;height:10px;border-radius:1.5px;background:var(--ku-c)"></div><div style="width:3px;height:22px;border-radius:1.5px;background:var(--ku-c)"></div><div style="width:3px;height:7px;border-radius:1.5px;background:var(--ku-c)"></div><div style="width:3px;height:18px;border-radius:1.5px;background:var(--ku-c)"></div><div style="width:3px;height:12px;border-radius:1.5px;background:var(--ku-c)"></div></div>',
  'count-up': '<div class="cp-el" style="font-size:20px;font-weight:700;color:var(--ku-ch);font-family:var(--ku-mono)">0</div>',

  // List
  stagger: '<div class="cp-el" style="display:flex;flex-direction:column;gap:3px"><div style="width:44px;height:6px;border-radius:3px;background:var(--ku-c)"></div><div style="width:36px;height:6px;border-radius:3px;background:var(--ku-c);opacity:.6"></div><div style="width:28px;height:6px;border-radius:3px;background:var(--ku-c);opacity:.3"></div></div>',
  reorder: '<div class="cp-el" style="display:flex;flex-direction:column;gap:3px"><div style="width:44px;height:7px;border-radius:3px;background:var(--ku-c)"></div><div style="width:44px;height:7px;border-radius:3px;background:var(--ku-ch)"></div><div style="width:44px;height:7px;border-radius:3px;background:var(--ku-c);opacity:.5"></div></div>',
  'swipe-delete': '<div class="cp-el" style="display:flex;width:56px;height:24px;overflow:hidden;border-radius:4px"><div style="flex-shrink:0;width:56px;height:24px;background:var(--ku-c);border-radius:4px"></div><div style="flex-shrink:0;width:20px;height:24px;background:#ff4d4f;display:flex;align-items:center;justify-content:center;color:#fff;font-size:10px">✕</div></div>',
  insert: '<div class="cp-el" style="display:flex;flex-direction:column;gap:2px;align-items:center"><div style="width:44px;height:6px;border-radius:3px;background:var(--ku-c)"></div><div style="width:44px;height:8px;border-radius:3px;border:1.5px dashed var(--ku-c);opacity:.4"></div><div style="width:44px;height:6px;border-radius:3px;background:var(--ku-c)"></div></div>',
  marquee: '<div class="cp-el" style="display:flex;gap:4px;overflow:hidden;width:52px"><div style="display:flex;gap:4px;flex-shrink:0"><div style="width:16px;height:16px;border-radius:3px;background:var(--ku-c)"></div><div style="width:16px;height:16px;border-radius:3px;background:var(--ku-c);opacity:.6"></div><div style="width:16px;height:16px;border-radius:3px;background:var(--ku-c)"></div></div></div>',
  sequence: '<div class="cp-el" style="display:flex;flex-direction:column;gap:3px"><div style="width:44px;height:6px;border-radius:3px;background:rgba(255,255,255,.1)"></div><div style="width:44px;height:14px;border-radius:4px;background:var(--ku-c);opacity:0;transform:scale(0.3)"></div><div style="width:20px;height:6px;border-radius:3px;background:var(--ku-c);opacity:0"></div></div>',

  // Emphasis
  float: '<div class="cp-el" style="width:36px;height:36px;border-radius:50%;background:var(--ku-c);box-shadow:0 4px 12px rgba(22,119,255,.3)"></div>',
  spotlight: '<div class="cp-el" style="width:36px;height:36px;border-radius:50%;background:radial-gradient(circle,rgba(22,119,255,.2) 30%,transparent 70%);display:flex;align-items:center;justify-content:center"><div style="padding:4px 8px;border-radius:4px;background:var(--ku-c);color:#fff;font-size:8px">发布</div></div>',
  'vip-shimmer': '<div class="cp-el" style="width:80px;height:36px;border-radius:6px;background:linear-gradient(135deg,#0a1628 0%,#132d5e 50%,#0a1628 100%);display:flex;align-items:center;justify-content:center;border:1px solid rgba(24,108,229,.3)"><span style="font-size:10px;color:var(--ku-ch);font-weight:700;letter-spacing:2px">VIP</span></div>',
  'vip-flip': '<div class="cp-el" style="width:52px;height:38px;border-radius:6px;background:var(--ku-c);display:flex;align-items:center;justify-content:center;perspective:200px"><div style="font-size:9px;color:#fff;font-weight:700">VIP</div></div>',
  'zoom-in': '<div class="cp-el" style="width:40px;height:40px;border-radius:6px;background:var(--ku-c)"></div>',

  // Gesture
  'drag-spring': '<div class="cp-el" style="width:36px;height:36px;border-radius:8px;background:var(--ku-c);cursor:grab;box-shadow:0 2px 8px rgba(0,0,0,.15)"></div>',
  'swipe-card': '<div class="cp-el" style="position:relative;width:36px;height:44px"><div style="position:absolute;left:0;top:4px;width:32px;height:40px;border-radius:6px;background:rgba(255,255,255,.12)"></div><div style="position:absolute;left:4px;top:0;width:32px;height:40px;border-radius:6px;background:var(--ku-c)"></div></div>',
  'pinch-zoom': '<div class="cp-el" style="width:32px;height:32px;border-radius:6px;background:var(--ku-c)"></div>',
  'long-press': '<div class="cp-el" style="position:relative"><div style="width:36px;height:36px;border-radius:8px;background:var(--ku-c)"></div><div style="position:absolute;inset:-5px;border-radius:12px;border:2px solid var(--ku-c);opacity:.3"></div></div>',
  'bubble-expand': '<div class="cp-el" style="height:22px;border-radius:8px;background:var(--ku-c);width:40px;display:flex;align-items:center;justify-content:center"><span style="font-size:7px;color:#fff;font-weight:700">限时免费</span></div>',
};

export function getPreviewShape(id: string): string {
  return PREVIEW_SHAPES[id] || '';
}
