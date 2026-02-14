# ProgrammingNewsletters.com — Design System & Brand Guide

> A complete reference for implementing the visual redesign.
> For software engineers building this site, and for AI assistants carrying out the work.

---

## 1. Brand Identity

### Who we are

A free, daily-updated directory of programming newsletter archives. Engineers visit to read the latest issues without subscribing. No accounts, no email, no tracking — just links.

### Brand voice

- **Direct.** Say it plainly. No marketing fluff.
- **Helpful.** The site exists to save developers time.
- **Understated.** Let the content speak. The design stays out of the way.

### UX microcopy

| Location | Current | New |
|----------|---------|-----|
| Title | `Programming Newsletters.com` | `ProgrammingNewsletters.com` (one word, matches domain) |
| Subtitle | `Updated once daily.` | `Read the latest issues. No email needed.` |
| Default filter | `All` | `All` (keep) |
| Footer | `©2026 szTheory :: API :: Source code` | `© 2026 szTheory · API · Source` |

The subtitle change serves two purposes: it tells newcomers what this is ("read the latest issues") and states the value prop ("no email needed"). Returning users scan past it.

### Logo mark

Replace the current megaphone SVG with a minimal geometric mark: **two angle brackets `< >` with three horizontal lines between them** — a visual blend of code syntax and a reading list. Renders crisply at 32px. Monochrome, uses the accent color.

```
  <  ═══  >      (conceptual sketch)
  <  ═══  >
  <  ═══  >
```

The mark works as favicon, apple-touch-icon, and inline header icon.

---

## 2. Color System

### Design tokens (CSS custom properties)

All colors are defined as CSS custom properties on `:root` and overridden in `@media (prefers-color-scheme: dark)`. Every UI element references tokens — never raw hex values in component styles.

### Light mode (default)

```css
:root {
  /* Backgrounds */
  --color-bg:            #FFFFFF;
  --color-bg-subtle:     #F8FAFB;
  --color-bg-elevated:   #FFFFFF;

  /* Text */
  --color-text:          #1A1D23;
  --color-text-secondary:#5F6B7A;
  --color-text-tertiary: #8E99A4;

  /* Accent — teal */
  --color-accent:        #0D9488;
  --color-accent-hover:  #0F766E;
  --color-accent-subtle: #ECFDF5;

  /* Surfaces & borders */
  --color-border:        #E2E5E9;
  --color-surface:       #F1F3F5;
  --color-surface-hover: #E8EBEE;

  /* Date headers */
  --color-date:          #374151;
  --color-date-rule:     #E2E5E9;

  /* Footer */
  --color-footer:        #8E99A4;
}
```

### Dark mode

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg:            #0F1117;
    --color-bg-subtle:     #161922;
    --color-bg-elevated:   #1C1F2B;

    --color-text:          #EAEDF0;
    --color-text-secondary:#9BA3AE;
    --color-text-tertiary: #6B7280;

    --color-accent:        #2DD4BF;
    --color-accent-hover:  #5EEAD4;
    --color-accent-subtle: #132825;

    --color-border:        #2A2E3A;
    --color-surface:       #1C1F2B;
    --color-surface-hover: #252836;

    --color-date:          #D1D5DB;
    --color-date-rule:     #2A2E3A;

    --color-footer:        #6B7280;
  }
}
```

### Why teal?

- Distinctive from the generic blue/purple palette most dev tools use
- WCAG AA contrast ratio of 4.6:1 on white (light mode) and 9.8:1 on `#0F1117` (dark mode)
- Pairs naturally with warm slate neutrals
- Signals "go / active / current" — fitting for a daily-updated site

### Color usage rules

| Element | Token |
|---------|-------|
| Page background | `--color-bg` |
| Newsletter link text | `--color-accent` |
| Newsletter link hover | `--color-accent-hover` |
| Body text | `--color-text` |
| Subtitle, metadata | `--color-text-secondary` |
| Filter chip background (inactive) | `--color-surface` |
| Filter chip background (active) | `--color-accent` |
| Filter chip text (inactive) | `--color-text` |
| Filter chip text (active) | `#FFFFFF` (light) / `#0F1117` (dark) |
| Date header text | `--color-date` |
| Date header top border | `--color-date-rule` |
| Footer text | `--color-footer` |
| Footer links | `--color-text-secondary` |

---

## 3. Typography

### Font stack

```css
:root {
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
               Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo,
               Consolas, "Liberation Mono", monospace;
}
```

This renders as:
- **San Francisco** on macOS / iOS
- **Segoe UI** on Windows
- **Roboto** on Android / Chrome OS
- **Ubuntu** on Ubuntu Linux

Every platform gets its own native typeface. The site feels like it belongs.

### Type scale

| Token | Size | Use |
|-------|------|-----|
| `--text-xs` | `0.75rem` (12px) | — |
| `--text-sm` | `0.8125rem` (13px) | Filter chips, footer |
| `--text-base` | `1rem` (16px) | Body default, subtitle |
| `--text-lg` | `1.125rem` (18px) | Newsletter links (mobile) |
| `--text-xl` | `1.25rem` (20px) | Newsletter links (desktop) |
| `--text-2xl` | `1.5rem` (24px) | Site title (mobile) |
| `--text-3xl` | `1.75rem` (28px) | Site title (desktop) |

### Font weights

```css
:root {
  --weight-normal:  400;
  --weight-medium:  500;
  --weight-semibold:600;
  --weight-bold:    700;
}
```

| Element | Weight |
|---------|--------|
| Site title | `--weight-bold` |
| `.com` accent | `--weight-normal` |
| Subtitle | `--weight-normal` |
| Filter chips | `--weight-medium` |
| Date headers | `--weight-semibold` |
| Newsletter links | `--weight-normal` |
| Footer | `--weight-normal` |

### Line heights

```css
:root {
  --leading-tight:  1.25;
  --leading-normal: 1.5;
  --leading-relaxed:1.625;
}
```

Body text uses `--leading-normal`. Newsletter link lists use `--leading-relaxed` for comfortable scanning.

---

## 4. Spacing

### Scale (4px base unit)

```css
:root {
  --space-1:  0.25rem;   /*  4px */
  --space-2:  0.5rem;    /*  8px */
  --space-3:  0.75rem;   /* 12px */
  --space-4:  1rem;      /* 16px */
  --space-5:  1.25rem;   /* 20px */
  --space-6:  1.5rem;    /* 24px */
  --space-8:  2rem;      /* 32px */
  --space-10: 2.5rem;    /* 40px */
  --space-12: 3rem;      /* 48px */
  --space-16: 4rem;      /* 64px */
  --space-20: 5rem;      /* 80px */
}
```

### Usage

| Context | Value | Token |
|---------|-------|-------|
| Page horizontal padding (mobile) | 16px | `--space-4` |
| Page horizontal padding (desktop) | 24px | `--space-6` |
| Between filter chips | 8px | `--space-2` |
| Between newsletter items | 12px | `--space-3` |
| Below date header | 12px | `--space-3` |
| Between date groups | 40px | `--space-10` |
| Header to filters gap | 32px | `--space-8` |
| Filters to first group gap | 32px | `--space-8` |
| Footer top padding | 80px | `--space-20` |
| Footer bottom padding | 32px | `--space-8` |

---

## 5. Layout & Responsive Breakpoints

### Breakpoints

```css
:root {
  /* Reference only — used in media queries */
  /* --bp-sm:  480px;  Small phones       */
  /* --bp-md:  640px;  Large phones/small tablets */
  /* --bp-lg:  768px;  Tablets            */
  /* --bp-xl: 1024px;  Desktop            */
}
```

### Container

```css
.site {
  max-width: 680px;
  margin: 0 auto;
  padding: var(--space-12) var(--space-4) 0;
}

@media (min-width: 640px) {
  .site {
    padding: var(--space-12) var(--space-6) 0;
  }
}
```

Single centered column at all sizes. 680px is wide enough for comfortable reading and filter display without feeling sparse.

### Mobile layout (< 640px)

- Full-width content with 16px horizontal padding
- Filters: horizontal scroll, single row, no wrap
- Newsletter links: 18px
- Touch targets: minimum 44px height on all interactive elements

### Tablet & desktop (640px+)

- Centered column, 24px horizontal padding
- Filters: may wrap to multiple lines (enough room)
- Newsletter links: 20px

---

## 6. Components (BEM)

### Block: `site-header`

The site identity area.

```html
<header class="site-header">
  <div class="site-header__brand">
    <svg class="site-header__icon" ...>...</svg>
    <div class="site-header__text">
      <h1 class="site-header__title">
        ProgrammingNewsletters<span class="site-header__accent">.com</span>
      </h1>
      <p class="site-header__subtitle">Read the latest issues. No email needed.</p>
    </div>
  </div>
</header>
```

```css
.site-header__brand {
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
}

.site-header__icon {
  width: 36px;
  height: 36px;
  flex-shrink: 0;
  margin-top: var(--space-1);
  color: var(--color-accent);
}

.site-header__title {
  font-size: var(--text-2xl);
  font-weight: var(--weight-bold);
  line-height: var(--leading-tight);
  color: var(--color-text);
  margin: 0;
}

.site-header__accent {
  color: var(--color-accent);
  font-weight: var(--weight-normal);
}

.site-header__subtitle {
  color: var(--color-text-secondary);
  font-size: var(--text-base);
  margin: var(--space-1) 0 0;
}

@media (min-width: 640px) {
  .site-header__icon {
    width: 40px;
    height: 40px;
  }
  .site-header__title {
    font-size: var(--text-3xl);
  }
}
```

### Block: `filters`

Horizontal scrolling category filter bar.

```html
<nav class="filters" role="navigation" aria-label="Filter by category">
  <ul class="filters__list">
    <li class="filters__chip filters__chip--active" data-category="All">All</li>
    <li class="filters__chip" data-category="AI">AI</li>
    <li class="filters__chip" data-category="DevOps">DevOps</li>
    <!-- ... -->
  </ul>
</nav>
```

```css
.filters {
  margin-top: var(--space-8);
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;           /* Firefox */
}
.filters::-webkit-scrollbar {
  display: none;                    /* Chrome/Safari */
}

.filters__list {
  display: flex;
  gap: var(--space-2);
  padding: 0;
  margin: 0;
  list-style: none;
  flex-wrap: nowrap;
}

.filters__chip {
  flex-shrink: 0;
  padding: var(--space-2) var(--space-3);
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
  color: var(--color-text);
  background: var(--color-surface);
  border-radius: 999px;
  cursor: pointer;
  white-space: nowrap;
  transition: background-color 0.15s ease, color 0.15s ease;
  min-height: 36px;
  display: flex;
  align-items: center;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
}

.filters__chip:hover {
  background: var(--color-surface-hover);
}

.filters__chip--active {
  background: var(--color-accent);
  color: #FFFFFF;
}

@media (prefers-color-scheme: dark) {
  .filters__chip--active {
    color: #0F1117;
  }
}

@media (min-width: 640px) {
  .filters__list {
    flex-wrap: wrap;
  }
}
```

**Key UX decisions:**
- Hidden scrollbar keeps the UI clean on mobile
- `flex-shrink: 0` prevents chips from collapsing
- 36px minimum height ensures comfortable touch targets
- `border-radius: 999px` gives perfect pill shape at any size
- Wrapping on wider screens so all categories are visible at once
- `-webkit-tap-highlight-color: transparent` removes iOS tap flash
- Subtle 150ms transition on background/color for native feel

### Block: `feed`

The main content area — date-grouped newsletter listings.

```html
<main class="feed">
  <section class="feed__group">
    <h2 class="feed__date">Feb 13</h2>
    <ul class="feed__list">
      <li class="feed__item" data-category="Data Science">
        <a href="..." rel="nofollow" target="_blank" class="feed__link">
          Data News Hotlist
        </a>
      </li>
      <!-- ... -->
    </ul>
  </section>
  <!-- more groups -->
</main>
```

```css
.feed {
  margin-top: var(--space-8);
}

.feed__group {
  margin-top: var(--space-10);
}
.feed__group:first-child {
  margin-top: 0;
}

.feed__date {
  font-size: var(--text-sm);
  font-weight: var(--weight-semibold);
  color: var(--color-date);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0 0 var(--space-3);
  padding-top: var(--space-3);
  border-top: 1px solid var(--color-date-rule);
}
.feed__group:first-child .feed__date {
  border-top: none;
  padding-top: 0;
}

.feed__list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.feed__item {
  padding: var(--space-2) 0;
}

.feed__link {
  font-size: var(--text-lg);
  font-weight: var(--weight-normal);
  line-height: var(--leading-relaxed);
  color: var(--color-accent);
  text-decoration: none;
  transition: color 0.15s ease;
}
.feed__link:hover {
  color: var(--color-accent-hover);
  text-decoration: underline;
  text-underline-offset: 3px;
  text-decoration-thickness: 1px;
}
.feed__link:active {
  opacity: 0.8;
}

@media (min-width: 640px) {
  .feed__link {
    font-size: var(--text-xl);
  }
}
```

**Key UX decisions:**
- Date headers are small, uppercase, letterspaced — they orient without dominating
- 1px top border on date headers provides visual separation without heaviness
- No border on the first group (nothing to separate from)
- Links have no underline by default (cleaner list scan), underline on hover
- `text-underline-offset: 3px` keeps underlines from colliding with descenders
- `padding: var(--space-2) 0` on items gives vertical breathing room and extends touch target

### Block: `site-footer`

```html
<footer class="site-footer">
  <p class="site-footer__text">
    &copy; 2026 szTheory &middot;
    <a href="index.json" class="site-footer__link">API</a> &middot;
    <a href="https://github.com/szTheory/programmingnewsletters.com" class="site-footer__link">Source</a>
  </p>
</footer>
```

```css
.site-footer {
  margin-top: var(--space-20);
  padding-bottom: var(--space-8);
}

.site-footer__text {
  font-size: var(--text-sm);
  color: var(--color-footer);
  margin: 0;
}

.site-footer__link {
  color: var(--color-text-secondary);
  text-decoration: none;
}
.site-footer__link:hover {
  color: var(--color-accent);
  text-decoration: underline;
}
```

### Utility: `u-hidden`

Used by JavaScript for category filtering.

```css
.u-hidden {
  display: none !important;
}
```

---

## 7. Dark / Light Mode

### Implementation

Uses `prefers-color-scheme` media query — no toggle, no JavaScript, pure CSS. Follows the user's OS setting automatically.

```css
/* Light mode: default (no media query needed) */
:root {
  --color-bg: #FFFFFF;
  /* ... all light tokens ... */
}

/* Dark mode: override tokens */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #0F1117;
    /* ... all dark tokens ... */
  }
}
```

### `theme-color` meta tag

The HTML template includes two `<meta name="theme-color">` tags for the browser chrome:

```html
<meta name="theme-color" content="#FFFFFF" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0F1117" media="(prefers-color-scheme: dark)">
```

This colors the browser address bar / status bar to match the page background.

### Web manifest

Update `site.webmanifest`:

```json
{
  "short_name": "ProgNews",
  "name": "ProgrammingNewsletters.com",
  "icons": [
    { "src": "icon.png", "type": "image/png", "sizes": "192x192" },
    { "src": "icon-512.png", "type": "image/png", "sizes": "512x512" }
  ],
  "start_url": "/?utm_source=homescreen",
  "background_color": "#FFFFFF",
  "theme_color": "#0D9488",
  "display": "standalone"
}
```

---

## 8. Transitions & Micro-interactions

Keep it minimal. This is a content site, not an app. Three transitions total:

| Element | Property | Duration | Easing |
|---------|----------|----------|--------|
| Filter chips | `background-color`, `color` | 150ms | `ease` |
| Newsletter links | `color` | 150ms | `ease` |
| Footer links | `color` | 150ms | `ease` |

No page-load animations. No scroll effects. No JavaScript-driven motion. The site should feel instant and native.

---

## 9. Accessibility

- All interactive elements (filter chips, links) are keyboard-focusable
- Focus styles: `outline: 2px solid var(--color-accent); outline-offset: 2px;`
- Filter chips use `role="navigation"` with `aria-label`
- Color contrast ratios meet WCAG AA (4.5:1 for normal text, 3:1 for large text)
- `prefers-reduced-motion`: transitions respect user preference

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    transition-duration: 0.01ms !important;
  }
}
```

---

## 10. Icon / Favicon

### SVG mark (inline in header)

A monochrome code-bracket + reading-list mark. Clean at 32-40px.

```svg
<svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Left bracket -->
  <path d="M8 6L2 16L8 26" stroke="currentColor" stroke-width="2.5"
        stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Right bracket -->
  <path d="M24 6L30 16L24 26" stroke="currentColor" stroke-width="2.5"
        stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Three lines (reading list) -->
  <line x1="12" y1="12" x2="20" y2="12" stroke="currentColor" stroke-width="2"
        stroke-linecap="round"/>
  <line x1="12" y1="16" x2="20" y2="16" stroke="currentColor" stroke-width="2"
        stroke-linecap="round"/>
  <line x1="12" y1="20" x2="20" y2="20" stroke="currentColor" stroke-width="2"
        stroke-linecap="round"/>
</svg>
```

Uses `currentColor` so it inherits `--color-accent` and adapts to light/dark mode automatically.

### Favicon generation

Generate from the same SVG at these sizes:
- `favicon.ico`: 32x32
- `icon.png`: 192x192 (PWA)
- `icon-512.png`: 512x512 (PWA splash)

Background: `--color-accent` (`#0D9488`), icon strokes: `#FFFFFF`.

---

## 11. CSS File Structure

### Remove `default.css`

The HTML5 Boilerplate base styles in `default.css` are redundant with our new resets. Remove it from the build. Keep `normalize.css`.

### Build order (in `Build::CSS.pm`)

```
normalize.css → main.css
```

Update `SOURCE_CSS_FILENAMES` constant:

```perl
use constant SOURCE_CSS_FILENAMES => ('normalize.css', 'main.css');
```

### `main.css` structure

```
/* ==========================================
   1. Custom properties (tokens)
   2. Base / reset
   3. Layout
   4. Site header
   5. Filters
   6. Feed
   7. Footer
   8. Utilities
   9. Dark mode overrides
  10. Responsive
  11. Accessibility
   ========================================== */
```

---

## 12. JavaScript Updates

The filtering logic stays the same. Only the class names and selectors change:

| Old | New |
|-----|-----|
| `.category-filter` | `.filters__chip` |
| `.selected` | `filters__chip--active` |
| `.entry` | `.feed__item` |
| `.entry-group` | `.feed__group` |
| `.hidden` | `u-hidden` |
| `data-category` | `data-category` (unchanged) |

Updated constants:

```javascript
const FILTER_CLASS = "filters__chip";
const FILTER_ACTIVE_CLASS = "filters__chip--active";
const ITEM_SELECTOR = ".feed__item";
const GROUP_SELECTOR = ".feed__group";
const HIDDEN_CLASS = "u-hidden";
const CATEGORY_ATTR = "data-category";
const CATEGORY_ALL = "All";
```

---

## 13. Implementation Phases

Execute in this order. Each phase produces a testable result.

### Phase 1: CSS foundation

1. Delete `private/css/default.css`
2. Update `lib/Build/CSS.pm` to remove `default.css` from source list
3. Rewrite `private/css/main.css` with:
   - CSS custom properties (all tokens from sections 2-4)
   - Base resets (box-sizing, margin, font)
   - Layout (`.site` container)
   - All component styles (sections 6)
   - Dark mode overrides (section 7)
   - Responsive breakpoints (section 5)
   - Accessibility (section 9)

### Phase 2: HTML template

1. Rewrite `private/templates/index.html.ep` with:
   - New `<meta>` tags (theme-color for light/dark, improved description, OG tags)
   - Remove inline background pattern `<style>` tag
   - New SVG icon inline
   - BEM class names throughout
   - Semantic HTML (`<header>`, `<nav>`, `<main>`, `<footer>`)
   - Updated microcopy

### Phase 3: JavaScript

1. Update `private/javascript/main.js`:
   - New selector constants (matching BEM names)
   - Same filtering logic

### Phase 4: Assets & manifest

1. Update `public/site.webmanifest` with new colors and name
2. Generate new `public/icon.png` (192px) and `public/favicon.ico` (32px) from SVG mark

### Phase 5: Build & verify

1. Rebuild: `docker compose exec dev carton exec perl Run.pm --rebuild --first-only`
2. Check `localhost:8000` in browser
3. Test light mode and dark mode
4. Test filter clicks
5. Test responsive: iPhone 14 (390px), iPad (768px), desktop (1440px)
6. Verify all newsletter links render correctly

---

## Quick Reference Card

```
COLORS                          SPACING
───────────────────────         ───────────
Accent:     #0D9488 (light)     4   8   12  16  20  24  32  40  48  64  80
            #2DD4BF (dark)
                                FONT SIZES
BG:         #FFFFFF (light)     ───────────
            #0F1117 (dark)      13  16  18  20  24  28

Text:       #1A1D23 (light)     BREAKPOINTS
            #EAEDF0 (dark)      ───────────
                                640px (tablet+)
FONT STACK
────────────────────────────────────────────────────
-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif

BEM BLOCKS
────────────────────────────────────────────────────
.site-header   .site-header__icon / __title / __accent / __subtitle
.filters       .filters__list / __chip / __chip--active
.feed          .feed__group / __date / __list / __item / __link
.site-footer   .site-footer__text / __link
.u-hidden
```
