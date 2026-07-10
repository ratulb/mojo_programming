# AGENTS.md

⚠️ **Historical learning repo.** Originally used the legacy `magic`/`mojoproject.toml` system (max-nightly channel). Now uses **pixi** for Mojo tooling. Old `magic` commands will not work.

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
| Run a single Mojo file | `pixi run mojo -I . codes/two_sum.mojo` |
| Run a test file | `pixi run mojo -I . codes/test/test_two_sum.mojo` |
| Build a binary | `pixi run mojo build codes/two_sum.mojo` |
| Run the two_sum example (pixi task) | `pixi run run` |
| Build docs (pixi task) | `pixi run build-docs` |
| Build the mdBook site | `mdbook build` |
| Preview docs locally | `python3 scripts/build_docs.py && mdbook serve` |
| Build CUDA histogram | `make -C cuda/histogram` |

## Directory layout

- `codes/` — LeetCode-style algorithm problems, each in one `.mojo` file. Tests in `codes/test/` (one file per problem).
- `gpu/` — GPU programming examples (matmul, broadcast, layouts) with `.mojo` + `.ipynb` files.
- `mojo_kernels/` — Mojo GPU kernel examples (`.mojo` + `.ipynb`).
- `cuda/histogram/` — Standalone CUDA example, buildable with `make` + `nvcc`.
- `scripts/build_docs.py` — Reads `categories.yml` + `.mojo` files, generates `src/` (mdBook source). `src/` is gitignored.
- `utils.mojo` — `Timer` RAII struct (prints nanoseconds via `global_perf_counter_ns`), usable via `from utils import Timer`.
- `theme/custom.css` — Greenish gradient styling (committed).
- `pixi.toml` — Defines `mojo` and `python >=3.12` deps. Channels: `https://conda.modular.com/max/`, `conda-forge`.

## pixi tasks

Defined in `pixi.toml`:
- `run` — runs `mojo codes/two_sum.mojo`
- `build-docs` — runs `python scripts/build_docs.py && mdbook build`

## Testing conventions

- Tests in `codes/test/`, import with `from <module> import *`.
- Use `def` (not `fn`) for test functions.
- Assertions from `std.testing`: `assert_equal`, `assert_true`, `assert_false`, `assert_raises`.

## Doc generation conventions

- `scripts/build_docs.py` reads `categories.yml` and `.mojo` files, writes `src/` (mdBook source). Run before `mdbook build`.
- Mojo module-level `"""..."""` docstrings: first non-empty line is the page title, subsequent lines form the description.
- `###` comment lines (ignored by Mojo compiler as `#` + `##`) also work as title/description markers — historic convention.
- When adding a new `.mojo` file, add its stem (without extension) to the appropriate category in `categories.yml`.
- Code fences in generated docs use ` ```python ` (historic workaround — mdBook lacked Mojo highlighting at the time).
- Site auto-deploys to GitHub Pages on push to `main` (`.github/workflows/github-pages.yml`).

## Stale / legacy files to ignore

- `codes/generate_docs.mojo` — old Mojo-based doc generator; `scripts/build_docs.py` is the active one.
- `codes/README.md` — describes the old `generate_docs` command; irrelevant to current workflow.

## Sparse clone

`cuda-clone.sh` checks out only the `cuda/` folder via git sparse-checkout.
