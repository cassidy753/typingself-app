---
name: typingself
description: Cantonese personality self-discovery app — warm, introspective, poetic authority
colors:
  background: "#F8F6F3"
  surface: "#FFFFFF"
  elevated: "#FAFAF8"
  textPrimary: "#2D2D2D"
  textSecondary: "#8E8E93"
  textMuted: "#AEAEB2"
  accent: "#8B7355"
  cta: "#D4735E"
  accentLight: "#D4C8B4"
  accentSurface: "#F0EBE3"
  border: "#E8E6E1"
  divider: "#E8E6E1"
  darkBackground: "#1C1C1E"
  darkSurface: "#2C2C2E"
  darkElevated: "#38383A"
  darkTextPrimary: "#F5F5F0"
  darkTextSecondary: "#8E8E93"
  darkTextMuted: "#636366"
  darkAccent: "#A08565"
  darkCta: "#E0836E"
  darkAccentSurface: "#3A352E"
  darkBorder: "#3A3A3C"
  badgeSage: "#7A9E7E"
  badgeGold: "#C9A84C"
  badgeDusty: "#B8A9C9"
typography:
  display:
    fontFamily: Noto Serif TC
    fontWeight: 700
    lineHeight: 1.1
  h1:
    fontFamily: Noto Serif TC
    fontSize: 1.75rem
    fontWeight: 700
    lineHeight: 1.2
  h2:
    fontFamily: Noto Sans TC
    fontSize: 1.25rem
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: Noto Sans TC
    fontSize: 1rem
    fontWeight: 400
    lineHeight: 1.6
  caption:
    fontFamily: Noto Sans TC
    fontSize: 0.8125rem
    fontWeight: 400
    lineHeight: 1.4
    color: "{colors.textSecondary}"
  label:
    fontFamily: Noto Sans TC
    fontSize: 0.75rem
    fontWeight: 600
    letterSpacing: 0.05em
    textTransform: uppercase
rounded:
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  xxl: 24px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px
  xxxl: 40px
---

## Overview

@typingself（型得你）is a Cantonese-first personality self-discovery app. The design language blends **dark academia warmth** with **psychological authority** — think a leather-bound journal in a dim library, not a sterile clinical assessment. The visual identity is anchored in the Daebi palette: deep navy foundations with warm earth accents, punctuated by coral for emotion and gold for achievement.

### Brand Essence

- **Category:** Personality assessment / Self-discovery / Psychology tech
- **Audience:** HK-based 20-35 year olds, Cantonese speakers, growth-minded
- **Core Metaphor:** 4-stage journey of inner discovery
- **Emotional Promise:** "Understanding yourself is the first step to becoming yourself."
- **Tone Spectrum:** Scientific authoritative → Poetic vulnerable
- **Language:** Cantonese (Traditional Chinese), natural Hong Kong voice

### The 4-Stage Journey

1. **Self-Discovery** — Assessment and type identification
2. **Growth** — Daily practices and skill development
3. **Integration** — Understanding patterns across all life domains
4. **Expression** — Sharing and teaching others

## Colors

### Palette Philosophy

One accent, used consistently. Earth brown (#8B7355) is the primary identity accent — warm, grounding, trustworthy. Coral (#D4735E) is reserved for CTAs and emotional emphasis. Sage, gold, and dusty are badge-only colors for achievements and type-specific content.

### Color Consistency Rules

- **ONE accent per page.** Once accent is set, it's used on ALL sections
- **No section inverts.** Dark pages stay dark, light pages stay light throughout
- **Never pure #000000.** Use off-black (#2D2D2D light, #1C1C1E dark)
- **Never pure #FFFFFF.** Use warm off-white (#F8F6F3)
- **Coral is CTA-only.** Not for decoration, headings, or backgrounds
- **Saturation < 80%** for all colors

## Typography

### Font Pairing

| Usage | Font | Weight |
|-------|------|--------|
| Display / Hero | Noto Serif TC | 700-900 |
| Headings | Noto Sans TC | 600-700 |
| Body | Noto Sans TC | 400 |
| Labels / Stats | Noto Sans TC | 600, uppercase |

### Rules

- **BANNED:** Inter, Roboto, Arial, Helvetica for Chinese text
- Body max-width: 65 characters per line
- Line-height: 1.1 for headers, 1.6 for body
- Tracking: tight for headings (-0.02em to -0.04em)
- HK Cantonese mix: Noto Sans TC + Noto Serif TC pair naturally with Chinese characters

## Layout & Spacing

### Principles

- **Macro-whitespace between sections.** Breathing room is a premium feature
- **Content rhythm:** quiet → emotional → reflective
- **Card-first design.** Information lives in cards with consistent elevation
- **Grid over Flex.** CSS Grid for layout, never flexbox percentage math

### Spacing Scale

Use the spacing tokens above. Never invent values outside this scale.

### Shadows

- Cards: tinted to background hue, never pure black shadows
- Elevated: deeper tint, wider blur
- No pure black drop shadows on light backgrounds

## Components

### Cards
- Background: surface color
- Border radius: md (12px) default
- Shadow: Card shadow from shadows scale
- Inner padding: lg (16px)

### Buttons
- Primary: accent background, white text, lg (16px) radius
- CTA: coral background, white text, lg radius
- Minimum touch target: 48px height
- Text style: body weight 700

### Bottom Navigation
- 4 tabs max
- Active indicator: accent underline, 250ms animation
- Icon size: 22px
- Labels: 10px, weight 600 when active

### Progress / Achievement
- Sage badges: growth milestones
- Gold badges: achievements and streaks
- Dusty purple: depth / introspection content

## Do's and Don'ts

### Do
- Use warm, tactile language in Cantonese
- Mix Chinese and English naturally ("你嘅 personality type 係咁嘅")
- Keep scientific accuracy in psychology concepts
- Use the 4-stage journey framework for all content
- Let images breathe with generous whitespace

### Don't
- Use AI clichés: "Elevate", "Unlock", "Next-Gen", "Seamless"
- Use em-dash (—) anywhere — use hyphen (-) instead
- Use section-numbering as labels ("Stage 01", "Phase 02")
- Use scroll cues ("Scroll to explore", "↓ swipe")
- Overlay labels/pills on images
- Use fake-precise numbers without real data
- Use decorative status dots
- Mix light and dark sections on the same page
- Use pure black (#000) or pure white (#FFF)
