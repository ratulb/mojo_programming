# Background from ChatGPT Mediator

## Current gradient (App.css)

```css
:root {
  --blue: rgb(0, 128, 128);
  --blueish: #0650b1;
  --greenish: rgb(0, 128, 0);
  --white: snow;
  --unusual_msg_color: rgb(199, 130, 26);
  --nice-blue: #0088ff;
}

body {
  background-color: var(--greenish);
  background-image: linear-gradient(120deg, var(--blueish), var(--greenish));
}
```

120° diagonal from `#0650b1` (dark blue) → `rgb(0, 128, 0)` (green).
Solid green fallback if gradient unsupported.

## Extracted variable (for reuse)

```css
--bg-gradient: linear-gradient(120deg, #0650b1, rgb(0, 128, 0));
```

## Unused image

`client/src/assets/clouds.jpg` — exists in the repo but never imported anywhere.
