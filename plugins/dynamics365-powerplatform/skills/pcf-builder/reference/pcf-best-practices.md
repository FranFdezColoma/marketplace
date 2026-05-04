# PCF Best Practices

## Performance
- Only update DOM in `updateView()` when values actually changed (compare vs cached)
- React: use `React.memo()` / `shouldComponentUpdate()`
- Use DocumentFragment for batch DOM insertions
- Lazy-load heavy libraries via dynamic imports
- **destroy()**: remove listeners, clear timers, unmount React, release large objects

## Accessibility (WCAG 2.1)
- All inputs: `<label>` or `aria-label`; interactive elements: `role` attribute
- Keyboard: all functionality available, `tabindex="0"` (not positive), visible focus, Escape to close
- Use semantic HTML (`<button>` not `<div onClick>`); `aria-live="polite"` for dynamic updates
- Contrast ≥ 4.5:1; never color-only information; test Windows High Contrast Mode

## Localization
- `.resx` per language; reference via manifest keys; never hard-code UI text
- RTL: CSS logical properties (`margin-inline-start`); test Arabic/Hebrew
- Use `context.formatting` APIs for dates/numbers — never format manually

## Responsive Design
- Adapt to `context.mode.allocatedWidth` / `allocatedHeight` — breakpoints on container, not viewport
- Handle `context.mode.isControlDisabled` and `context.mode.isVisible`
- Relative units (%, em, rem); Flexbox/Grid layout; no fixed dimensions

## Testing
- Unit: test business logic separate from DOM; mock `ComponentFramework.Context`; verify `getOutputs()`
- Integration: PCF Test Harness (`npm start`); test Create and Update form modes; test disabled state
- Cross-browser: Edge, Chrome, Firefox, Safari; mobile iOS/Android; Model-Driven, Canvas, Power Pages

## Security
- Validate/sanitize all bound property values (XSS prevention)
- Use `context.webAPI` (not direct HTTP) — respects security context
- Use `context.navigation` (not `window.location`)
- No `eval()`, no `Function()`, no dynamic external script loading
