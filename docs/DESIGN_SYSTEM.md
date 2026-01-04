# Design System & UI/UX Guidelines
## NexusChat - Visual Identity

---

## 1. Design Philosophy

### The Anti-WhatsApp Manifesto
> "Communication reimagined through bold design and seamless technology."

#### Core Principles
1. **Bold, Not Safe**: Unexpected colors and daring combinations
2. **Fluid, Not Static**: Everything animates with purpose
3. **Premium, Not Generic**: Every pixel feels expensive
4. **Delightful, Not Functional**: Users open the app just to look at it

---

## 2. Color System

### 2.1 Primary Palette - "Cosmic Noir"

| Token | Hex | Usage |
|-------|-----|-------|
| `void` | `#0A0A0F` | App background |
| `obsidian` | `#12121A` | Cards, elevated surfaces |
| `charcoal` | `#1A1A24` | Input fields, containers |
| `slate` | `#252532` | Borders, dividers |

### 2.2 Accent Palette - "Electric Dreams"

| Token | Hex | Role |
|-------|-----|------|
| `plasma` | `#8B5CF6` | Primary CTAs, sent messages |
| `nebula` | `#A855F7` | Hover states, gradients |
| `aurora` | `#22D3EE` | Links, online indicators |
| `solar` | `#F97316` | Notifications, alerts |

### 2.3 Semantic Colors

| Purpose | Hex |
|---------|-----|
| Success | `#10B981` |
| Error | `#F43F5E` |
| Warning | `#F59E0B` |
| Info | `#0EA5E9` |

### 2.4 Gradients

```css
--gradient-primary: linear-gradient(135deg, #8B5CF6, #A855F7, #D946EF);
--gradient-secondary: linear-gradient(135deg, #22D3EE, #8B5CF6, #A855F7);
--gradient-sent: linear-gradient(135deg, #8B5CF6, #7C3AED);
--glass-bg: rgba(18, 18, 26, 0.7);
--glass-border: rgba(139, 92, 246, 0.2);
```

---

## 3. Typography

### Font Families
- **Primary**: `'Inter'` - Clean, modern, excellent legibility
- **Display**: `'Outfit'` - Geometric, bold headers

### Type Scale

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `display-xl` | 36px | 700 | Splash branding |
| `display-lg` | 28px | 600 | Screen titles |
| `heading` | 22px | 600 | Section headers |
| `subheading` | 18px | 500 | Card titles |
| `body-lg` | 16px | 400 | Primary content |
| `body` | 14px | 400 | Chat messages |
| `caption` | 12px | 400 | Timestamps |
| `micro` | 10px | 500 | Badges |

### Text Colors

| Token | Value |
|-------|-------|
| `text-primary` | `#FFFFFF` 100% |
| `text-secondary` | `#FFFFFF` 70% |
| `text-tertiary` | `#FFFFFF` 50% |
| `text-accent` | `#8B5CF6` |

---

## 4. Spacing & Layout

### Spacing Scale (8px Base)

| Token | Value | Usage |
|-------|-------|-------|
| `space-xs` | 4px | Inline, icons |
| `space-sm` | 8px | Compact padding |
| `space-md` | 16px | Default padding |
| `space-lg` | 24px | Section spacing |
| `space-xl` | 32px | Screen padding |
| `space-2xl` | 48px | Major sections |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 6px | Buttons, chips |
| `radius-md` | 12px | Cards, inputs |
| `radius-lg` | 20px | Message bubbles |
| `radius-xl` | 28px | Modals, sheets |
| `radius-full` | 9999px | Avatars |

---

## 5. Components

### 5.1 Buttons

**Primary Button**
- Background: `gradient-primary`
- Padding: 16px 24px
- Border-radius: 6px
- Shadow: `0 4px 20px rgba(139, 92, 246, 0.4)`
- Hover: Scale 1.02, shadow +20%
- Press: Scale 0.98, haptic feedback

**Icon Button**
- Size: 44x44px
- Background: Transparent → `charcoal` on hover
- Border-radius: `radius-full`

### 5.2 Message Bubbles

**Sent (Right-aligned)**
- Background: `gradient-sent`
- Border-radius: 20px 20px 4px 20px
- Max-width: 75%
- Shadow: `0 4px 12px rgba(139, 92, 246, 0.25)`
- Animation: Slide from right + scale

**Received (Left-aligned)**
- Background: Glass effect with `gradient-received`
- Border: 1px solid `rgba(255, 255, 255, 0.08)`
- Border-radius: 20px 20px 20px 4px
- Animation: Slide from left + bounce

### 5.3 Chat Input

- Background: `charcoal` with glass effect
- Border: 1px `slate` → `plasma` on focus
- Border-radius: 28px
- Height: 52px (expandable to 120px)
- Focus: Border glow pulse animation

### 5.4 Chat List Item

- Background: Transparent → `obsidian` on hover
- Height: 76px
- Online indicator: Pulsing green dot
- Unread badge: `solar` pill
- Hover: Slide right 8px

### 5.5 Avatars

| Size | Dimensions |
|------|------------|
| Small | 32px |
| Medium | 48px |
| Large | 64px |

- Border: 2px gradient for current user
- Fallback: Letter on gradient background
- Online badge: 12px green circle, bottom-right

---

## 6. Motion & Animation

### Timing

| Token | Duration | Usage |
|-------|----------|-------|
| `instant` | 100ms | Hovers |
| `swift` | 200ms | Buttons |
| `smooth` | 300ms | Transitions |
| `deliberate` | 400ms | Modals |
| `dramatic` | 600ms | Splash |

### Key Animations

**Message Send**
```dart
Curves.easeOutBack
Scale: 0.8 → 1.0 (200ms)
Slide: right 20px → 0 (200ms)
Opacity: 0 → 1 (150ms)
```

**Typing Indicator**
```
Three dots, staggered 150ms delay
0.6s bounce loop each
translateY: 0 → -8px → 0
```

**Screen Transitions**
- Hero animation for avatars
- Staggered message fade-in (50ms delay)

---

## 7. Glassmorphism

```css
.glass-card {
  background: rgba(18, 18, 26, 0.6);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(139, 92, 246, 0.15);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.frosted-header {
  background: rgba(10, 10, 15, 0.8);
  backdrop-filter: blur(30px) saturate(180%);
}
```

---

## 8. Accessibility

- **Contrast**: Minimum 4.5:1 (WCAG AA)
- **Touch targets**: Minimum 44x44px
- **Motion**: Respect `prefers-reduced-motion`

---

## 9. Asset Requirements

### App Icons
- iOS: 1024x1024px
- Android: 512x512px, adaptive icon
- Style: Abstract "N" with cosmic gradient

### Splash Screen
- Animated logo (Lottie)
- Duration: 2-3 seconds
- Fade into home

---

*Design System Version: 1.0 | January 3, 2026*
