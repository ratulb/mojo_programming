# AGENTS.md

⚠️ **Historical learning repo.** Originally built with the legacy `magic`/`mojoproject.toml` system (max-nightly channel). Now uses **pixi** for Mojo tooling. Old `magic` commands will not work.

## Toolchain

| Tool | Purpose |
|------|---------|
| `pixi` | Mojo + Python environment manager (`pixi.toml` / `pixi.lock`) |
| `mojo` | Mojo compiler (v2024+) |
| `mdbook` v0.5.3 | Documentation site generator |
| `python3` + `pyyaml` | Doc generation script |

## Commands (run from repo root)

| Task | Command |
|------|---------|
| Run a single Mojo file | `pixi run mojo codes/two_sum.mojo` |
| Run a test file | `pixi run mojo codes/test/test_two_sum.mojo` |
| Build a binary | `pixi run mojo build codes/two_sum.mojo` |
| Regenerate docs from `.mojo` files | `python3 scripts/build_docs.py` |
| Build the mdBook site | `mdbook build` |
| Regenerate + build | `python3 scripts/build_docs.py && mdbook build` |
| Preview docs locally | `python3 scripts/build_docs.py && mdbook serve` |
| Build CUDA histogram | `make -C cuda/histogram` |

## Directory layout

- `codes/` — LeetCode-style algorithm problems, each in one `.mojo` file. Tests in `codes/test/` (one file per problem).
- `gpu/` — GPU programming examples (matmul, broadcast, layouts) with `.ipynb` notebooks.
- `mojo_kernels/` — Mojo GPU kernel examples.
- `cuda/histogram/` — Standalone CUDA example, buildable with `make` + `nvcc`.
- `scripts/build_docs.py` — Reads `categories.yml` + `.mojo` files, generates `src/` (mdBook source). `src/` is gitignored.
- `theme/custom.css` — Greenish gradient styling (committed).
- `pixi.toml` — Defines `mojo` and `python >=3.12` deps.

## Testing conventions

- Tests in `codes/test/`, import with `from <module> import *`.
- Use `def` (not `fn`) for test functions.
- Assertions from `std.testing`: `assert_equal`, `assert_true`, `assert_false`, `assert_raises`.

## Doc generation conventions

- The first `###` line becomes the page title, subsequent `###` lines become the description (joined as paragraphs). Everything after the `###` block is shown as code. This is a **repo-specific convention** — Mojo uses `#` for comments and `"""..."""` for docstrings; `###` is just `#` + `##` to the compiler and is ignored.
- Mojo module-level `"""..."""` docstrings are also supported: the first line inside the docstring is the title, subsequent lines form the description.
- When adding a new `.mojo` file, add its stem (without extension) to the appropriate category in `categories.yml`.
- Code fences in generated docs use ` ```python ` (historic workaround — mdBook's highlighter didn't support Mojo at the time).
- The site auto-deploys to GitHub Pages on push to `main` (via `.github/workflows/github-pages.yml`).

## Stale / legacy files to ignore


- `codes/generate_docs.mojo` — old Mojo-based doc generator; `scripts/build_docs.py` is the active one.

## Sparse clone

`cuda-clone.sh` checks out only the `cuda/` folder via git sparse-checkout.
