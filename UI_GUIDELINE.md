# @typingself App UI Design Guideline v2.0

> 極簡克制色彩 × 無邊框卡片 × 字體即裝飾
> 融合 Official Brand Palette + Borderless Design Philosophy

---

## 1. 設計哲學

### 三個核心原則

1. **Borderless Cards（隱形卡片）** — 冇陰影、冇邊框，純白背景 + 極淺灰 #F4F5F6 分隔
2. **Typography as Ornament（字體即裝飾）** — 冇多餘 icon / 色塊，靠字體大細粗細建立 hierarchy
3. **Flat → Feedback（扁平但 responsive）** — 平時 flat，點擊時微灰反應

### 絕對避免
- ❌ Neo-Brutalism（新醜風）— 粗黑線、高飽和
- ❌ Cyberpunk（霓虹賽博朋克）— 螢光色、刺眼
- ❌ 無意義 icon、裝飾線、色塊

---

## 2. 顏色系統

### Light Mode

| 色名 | Hex | 角色 |
|------|-----|------|
| **TypingSelf Charcoal** | `#2A2D34` | 主文字 |
| **Body Text** | `#333333` | 內文 |
| **Neutral Background** | `#FAFAFA` | 全域背景 |
| **Card / Section Divider** | `#F4F5F6` | 卡片之間分隔 |
| **1px Divider Line** | `#E5E7EB` | 資訊切分線 |
| **Mindful Blue (Minimal Use)** | `#73A5C5` | CTA 按鈕 only |
| **Organic Cream** | `#F5F1E8` | 極少數溫暖容器 |

### Dark Mode

| 色名 | Hex | 角色 |
|------|-----|------|
| **Background** | `#121212` | 全域背景（非純黑） |
| **Surface** | `#1E1E1E` | 卡片表面 |
| **Text Primary** | `#E0E0E0` | 主文字（非純白） |
| **Text Secondary** | `#9CA3AF` | 次要文字 |
| **Divider** | `#2A2A2A` | 切分線 |

---

## 3. 排版規範（Typography as Ornament）

### 字體大小層級

| 層級 | 大小 | 字重 | 顏色 | 用途 |
|------|------|------|------|------|
| **H1 (Screen Title)** | 22pt | Bold `#2A2D34` | 頁面標題 — 視覺焦點 |
| **H2 (Section)** | 18pt | Semi-bold `#2A2D34` | 章節標題 |
| **H3 (Card Title)** | 16pt | Semi-bold `#2A2D34` | 卡片標題 |
| **Body** | 15pt | Regular `#333333` | 主內文 |
| **Caption** | 13pt | Regular `#9CA3AF` | 輔助文字 |

### 原則
- 放大標題代替 icon / 色塊做視覺焦點
- 字體大細粗細 = 界線
- 減少多餘視覺元素，靠 typography 建立閱讀順序

---

## 4. 無邊框卡片（Borderless Cards）

### Card 結構
```dart
// 冇陰影、冇邊框
Container(
  color: Colors.white,  // 或 transparent
  child: Column(
    children: [
      // Card content...
      Divider(height: 1, color: Color(0xFFE5E7EB)), // 1px細線切分
    ],
  ),
)
```

### 分隔方式
- **Card 之間：** 背景色 #F4F5F6 做 natural gap
- **Info 之間：** 1px #E5E7EB 幼線
- **Section 之間：** 加大 padding（24px+），唔用額外裝飾

### Press / Hover 狀態
```dart
// 平時 flat／click 時微灰
GestureDetector(
  onTapDown: (_) => setState(() => _pressed = true),
  onTapUp: (_) => setState(() => _pressed = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 150),
    color: _pressed ? Color(0xFFF4F5F6) : Colors.transparent,
    // ...
  ),
)
```

---

## 5. 互動元件規範

### 5.1 按鈕
- **Primary CTA：** Mindful Blue #73A5C5，白字
- **樣式：** Minimal — 冇 icon、冇 shadow、淨係文字 + background
- 高度：48px，圓角：8px（唔超過 12px）
- 平時 flat，press 時變暗

### 5.2 列表 / 選單
- 冇分隔線以外的裝飾
- Row 之間用 1px #E5E7EB 幼線分隔
- 點擊行時背景微灰 #F4F5F6

### 5.3 輸入框
- Borderless design — 冇邊框，淨係底線 1px
- Focus 時底線變 Mindful Blue

---

## 6. 開發注意事項

- 嚴格避免 shadow / elevation（除非 press state 微陰影）
- 避免 icon-only buttons — 用文字代替
- 所有 touch target ≥ 44px（iOS HIG minimum）
- Dark mode 背景 #121212，文字 #E0E0E0
- 字體用 SF Pro (iOS) / Noto Sans TC (Flutter)
- 字體大細係唯一 hierarchy signal — 確保夠明顯

---

> **Last updated：** 2026-07-22
> **Design direction：** Minimal + Borderless + Typography-led
> **Source palette：** Official TypingSelf Brand System
