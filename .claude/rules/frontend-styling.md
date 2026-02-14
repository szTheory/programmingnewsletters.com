# Frontend & Styling

## Color Palette

| Name          | Hex       | Current usage                                         |
|---------------|-----------|-------------------------------------------------------|
| Imperial Red  | `#e63946` | `.accent` class (the ".com" text)                     |
| Honeydew      | `#f1faee` | Background (theme-color meta, manifest background)    |
| Powder Blue   | `#a8dadc` | Defined in palette comment but not used in CSS yet    |
| Celadon Blue  | `#457b9d` | Links, logo text, SVG fill                            |
| Prussian Blue | `#1d3557` | Date borders, nav selected bg, footer text            |
| Near White    | `#fefefd` | Selected nav pill text                                |

### Where colors are hardcoded (all must change together for theming):
- `private/css/main.css` — all color values
- `private/css/default.css` — `html { color: #222; }` (body text color)
- `private/templates/index.html.ep` line 15 — `<meta name="theme-color" content="#f1faee">`
- `private/templates/index.html.ep` line 18 — inline `<style>` with base64 background data-URI
- `public/site.webmanifest` — `background_color: "#f1faee"`, `theme_color: "#457b9d"`

## CSS Architecture

Three source files concatenated **in this order** by `lib/Build/CSS.pm`:
1. `private/css/normalize.css` — browser reset (HTML5 Boilerplate v8, **vendor file — do not modify**)
2. `private/css/default.css` — HTML5 Boilerplate defaults + helper classes (rarely modify)
3. `private/css/main.css` — all project-specific styles (~122 lines, **primary edit target**)

Output: `public/css/index.css` (single minified bundle via CSS::Packer)

No CSS custom properties currently — all colors are raw hex values. No preprocessor (Sass/Less).

## Template — `private/templates/index.html.ep`

Mojo::Template syntax:
- `<%= $var %>` — output with HTML escaping
- `<% code %>` — execute Perl code
- `<% foreach ... { %>` / `<% } %>` — loops

Available variables from `lib/Presenter.pm`:
- `$title` ("ProgrammingNewsletters.com"), `$subtitle` ("No email needed")
- `$categories` — arrayref of category strings (with "All" first)
- `$grouped_entries` — arrayref of `{ date => "Feb 13", entries => [{url, category, name}, ...] }`
- `$year`, `$developer` ("szTheory"), `$source_url`, `$api_path` ("index.json")

Page structure: logo header → category nav pills → date-grouped entry lists → footer

Key details:
- Background pattern: inline base64 PNG data-URI in `<style>` block in `<head>`
- JS loaded with `defer` attribute
- Noscript fallback hides `.navlinks` (category filters need JS)
- Links open in new tab: `target="_blank" rel="nofollow"`

## JavaScript — `private/javascript/main.js`

Vanilla JS, no frameworks. Single feature: category filtering.
- Click delegation on `.category-filter` elements
- Matches `data-category` attribute on `.entry` elements
- Hides non-matching entries and empty `.entry-group` containers
- Constants: `CATEGORY_FILTER_CLASS`, `HIDDEN_CLASS`, `ENTRIES_SELECTOR`, etc.
- Minified by JavaScript::Packer → `public/javascript/main.js`

## CSS Class Naming

BEM-inspired with double-underscore for children:
- `.logo`, `.logo__graphic`, `.logo__text__header`, `.logo__text__subheader`
- `.navlinks`, `.navlinks__link`
- `.entry`, `.entry__link`, `.entries`, `.entry-group`
- `.date`, `.footer`, `.accent`
- Utility: `.hidden` (display:none), `.selected` (active nav state)

## Key Layout Values

- Body: `max-width: 480px`, `margin: 0 auto`, `padding: 48px 18px 0`
- Logo: SVG 54x54px, text 26px Helvetica Neue
- Nav pills: 10px font, `border-radius: 12px`, `padding: 1px 8px`
- Date headers: 24px italic Garamond, `border-top: 4px solid #1d3557`, `margin-top: 84px`
- Entry links: 24px, 8px bottom margin between entries
- Footer: `padding: 240px 0 32px`
- SVG logo fill: `#457b9d !important` (the `!important` must be overridden for dark mode)

## Dark Mode Implementation Notes

When adding `prefers-color-scheme: dark` support:
- Introduce CSS custom properties (variables) for all color values in `main.css`
- Add `@media (prefers-color-scheme: dark) { :root { ... } }` block
- Override the inline base64 background in template (or use CSS to cover it)
- Add a dark-mode `<meta name="theme-color">` with `media` attribute
- Update `site.webmanifest` `background_color` if desired
- Override `.logo__graphic path { fill: ... !important; }` for dark mode
- Override `html { color: #222; }` from `default.css`

## Mobile Improvement Notes

When improving mobile display:
- No responsive breakpoints exist yet (only `max-width: 480px` on body)
- Nav pills (10px, inline-block) may need horizontal scroll or flex-wrap on narrow screens
- Date `margin-top: 84px` and footer `padding: 240px 0` are very generous — reduce on mobile
- Entry font-size 24px may be large for smallest phones
- Consider adding `@media` queries to `main.css` for breakpoints below 480px
