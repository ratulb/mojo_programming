# AGENTS.md

⚠️ **Outdated project.** Uses the legacy `magic`/`mojoproject.toml` system from early Mojo (max-nightly channel). These commands will not work with current Mojo tooling. This repo is kept as a historical learning reference.

## Multi-project layout

Each directory with a `mojoproject.toml` was its own `magic` project with a separate environment and lockfile.

| Directory | What | Original tool |
|-----------|------|---------------|
| `codes/` | LeetCode-style algorithm problems, each in one `.mojo` file. Tests in `codes/test/` | `magic run mojo` |
| `gpu/` | GPU programming examples (matmul, broadcast, layouts) | `magic run mojo` |
| `cuda/histogram/` | CUDA histogram example (standalone, still buildable) | `make` (uses `nvcc`) |

## Original commands (for reference, run from project subdirectory)

- `magic run mojo file.mojo` — run a single Mojo file
- `magic run mojo build file.mojo` — build a binary
- `magic run mojo test/test_two_sum.mojo` — run a single test file
- `make` / `make clean` — build / clean the CUDA histogram (in `cuda/histogram/`)

## Testing conventions (historical)

- Tests in `codes/test/`, one file per problem (e.g. `test_two_sum.mojo`).
- Tests use `def` (not `fn`) and import with `from <module> import *`.
- Assertions from the Mojo `testing` module (`assert_equal`, `assert_true`, `assert_false`, `assert_raises`).

## Sparse clone

`cuda-clone.sh` checks out only the `cuda/` folder via git sparse-checkout.

## Current architecture

The project uses mdBook for documentation (migrated from MkDocs Material).

### Project structure

```
root/
├── book.toml           # mdBook config (committed)
├── pixi.toml           # Mojo project config
├── categories.yml      # Maps .mojo files → left-nav categories
├── scripts/
│   └── build_docs.py   # Generates mdBook site from .mojo files
├── src/                # Generated markdown (gitignored)
│   ├── SUMMARY.md      # Table of contents (auto-generated)
│   ├── introduction.md # Landing page
│   └── codes/ gpu/ ... # Per-category .md files
├── theme/
│   └── custom.css      # Greenish gradient styling (committed)
├── docs/               # Built HTML site (gitignored)
├── codes/              # Algorithm problem .mojo files
├── gpu/                # GPU example .mojo files
└── mojo_kernels/       # Kernel .mojo files
```

### Commands

| Task | Command |
|------|---------|
| Run a Mojo file | `pixi run mojo codes/two_sum.mojo` |
| Generate site content | `python3 scripts/build_docs.py` |
| Build site | `mdbook build` |
| Generate + build | `python3 scripts/build_docs.py && mdbook build` |
| Preview locally | `python3 scripts/build_docs.py && mdbook serve` |
| Build CUDA histogram | `make -C cuda/histogram` |

### Conventions

- **`### Title`** and **`### Description`** as lines 1–2 of each `.mojo` file drive the auto-generated docs.
- When adding a new `.mojo` file, add its stem (without extension) to the appropriate category in `categories.yml`.
- The site auto-deploys to GitHub Pages on push to `main` via `.github/workflows/github-pages.yml`.

### Docs site

- Built with **mdBook** (v0.5.3), deployed to GitHub Pages.
- Navy default theme with `theme/custom.css` greenish gradient override.
- Left nav uses nested SUMMARY.md sections for category browsing.
- Landing page lists categories with problem counts.
- Each code page embeds the full source and links back to GitHub.
- Default-theme: `navy`, preferred-dark-theme: `navy`.

### Gradient CSS decision log

- Palette: `linear-gradient(120deg, #0650b1, rgb(0, 128, 0))`
- `html` gets the gradient with `background-attachment: fixed`
- `.sidebar`, `#menu-bar`, `.page-wrapper` — transparent
- `.content` keeps `var(--bg)` for readability
- Text on gradient: `#d4d4d8` / `#e6edf3` with `text-shadow`
- Code blocks keep native dark background
