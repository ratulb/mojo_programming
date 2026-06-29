#!/usr/bin/env python3
"""Generate mdBook site content from Mojo source files.

Reads categories.yml, scans .mojo files, and produces:
  - src/SUMMARY.md           — mdBook table of contents
  - src/*.md                 — per-file documentation pages
  - src/introduction.md      — landing page
  - theme/custom.css         — gradient styling (written once)

Run from project root:  python3 scripts/build_docs.py
Then:                    mdbook build
"""

import shutil
import filecmp
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parent.parent
CATEGORIES_FILE = ROOT / "categories.yml"
SRC_DIR = ROOT / "src"
THEME_CSS_PATH = ROOT / "theme" / "custom.css"
GITHUB_REPO = "https://github.com/ratulb/mojo_programming"
MOJO_DIRS = ["codes", "gpu", "mojo_kernels", "."]


def load_categories():
    with open(CATEGORIES_FILE) as f:
        return yaml.safe_load(f) or {}


def find_mojo_file(stem):
    for d in MOJO_DIRS:
        p = ROOT / d / f"{stem}.mojo"
        if p.exists():
            return p
    return None


def read_mojo_title(filepath):
    with open(filepath) as f:
        first_lines = [next(f, "") for _ in range(5)]
    for line in first_lines:
        s = line.strip()
        if s.startswith("###"):
            candidate = s.replace("###", "").strip()
            if len(candidate) <= 55:
                return candidate
            break
    stem = filepath.stem
    return stem.replace("_", " ").replace("-", " ").title()


def read_mojo_description(filepath):
    extras = []
    with open(filepath) as f:
        for line in f:
            if line.strip().startswith("###"):
                extras.append(line.strip().replace("###", "").strip())
    return extras[1] if len(extras) > 1 else ""


def strip_initial_hash3(lines):
    start = 0
    while start < len(lines) and lines[start].strip().startswith("###"):
        start += 1
    return lines[start:]


def mojo_to_src_rel(mojo_path):
    """Convert a .mojo path to its relative path under src/."""
    rel = mojo_path.relative_to(ROOT)
    return f"{rel.parent}/{rel.stem}.md"


def generate_md_content(mojo_path):
    title = read_mojo_title(mojo_path)
    desc = read_mojo_description(mojo_path)
    rel_path = mojo_path.relative_to(ROOT)
    github_url = f"{GITHUB_REPO}/blob/main/{rel_path}"

    with open(mojo_path) as f:
        source_lines = f.readlines()
    code = "".join(strip_initial_hash3(source_lines)).strip()

    lines = [f"# {title}"]
    if desc:
        lines.extend(["", desc])
    lines.extend([
        "",
        "```python",
        code,
        "```",
        "",
        f"[View source on GitHub]({github_url})",
        "",
    ])
    return "\n".join(lines)


def generate_introduction(categories):
    lines = ["# Mojo 🔥 Programming", ""]
    lines.append(
        "> CPU & GPU algorithm implementations in the "
        "[Mojo](https://www.modular.com/mojo) programming language."
    )
    lines.extend(["", "---", ""])
    lines.append("## Categories")
    lines.append("")
    for cat_name, files in categories.items():
        if not files:
            continue
        count = len(files)
        lines.append(f"- **{cat_name}** — {count} problem{'s' if count > 1 else ''}")
    lines.extend(["", "---", ""])
    lines.append(
        f"Full source on [GitHub]({GITHUB_REPO})"
    )
    return "\n".join(lines) + "\n"


def generate_summary(categories):
    lines = ["# Summary", "", "- [Home](./introduction.md)"]
    for cat_name, files in categories.items():
        if not files:
            continue
        children = []
        for stem in files:
            mojo_path = find_mojo_file(stem)
            if mojo_path:
                title = read_mojo_title(mojo_path)
                md_rel = mojo_to_src_rel(mojo_path)
                children.append((title, md_rel))
            else:
                md_path = ROOT / f"{stem}.md"
                if md_path.exists():
                    title = stem.replace("_", " ").replace("-", " ").title()
                    children.append((title, f"{stem}.md"))
        if not children:
            continue

        # Use first child as the parent page link
        first_title, first_rel = children[0]
        lines.append(f"- [{cat_name}]({first_rel})")
        for child_title, child_rel in children:
            indent = "  "
            if child_rel == first_rel:
                continue
            lines.append(f"{indent}- [{child_title}]({child_rel})")
    return "\n".join(lines) + "\n"


CSS_CONTENT = """\
:root {
  --bg-gradient: linear-gradient(120deg, #0650b1, rgb(0, 128, 0));
}
html {
  background: var(--bg-gradient) !important;
  background-attachment: fixed !important;
}
.page-wrapper {
  background: transparent !important;
}
.sidebar {
  background: transparent !important;
}
#menu-bar {
  background: transparent !important;
  border-block-end-color: transparent !important;
  box-shadow: none !important;
}
.content {
  background-color: var(--bg);
}
.menu-title {
  color: #e6edf3 !important;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3) !important;
}
.sidebar a,
.sidebar .chapter li a {
  color: #d4d4d8 !important;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3) !important;
}
.sidebar .chapter li a.active {
  color: #93c5fd !important;
}
.menu-bar,
.menu-bar:visited,
.menu-bar .icon-button,
.menu-bar a i {
  color: #d4d4d8 !important;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3) !important;
}
.menu-bar i:hover,
.menu-bar .icon-button:hover {
  color: #ffffff !important;
}
.nav-chapters,
.nav-chapters:visited,
.mobile-nav-chapters,
.mobile-nav-chapters:visited {
  color: #d4d4d8 !important;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3) !important;
}
.nav-chapters:hover {
  background: transparent !important;
  color: #ffffff !important;
}
.mobile-nav-chapters {
  background: rgba(0,0,0,0.3) !important;
}
.theme-popup {
  background: rgba(0,0,0,0.85) !important;
  border-color: rgba(255,255,255,0.15) !important;
}
.theme-popup .theme:hover {
  background: rgba(255,255,255,0.1) !important;
}
.sidebar .sidebar-resize-handle .sidebar-resize-indicator {
  background: rgba(255,255,255,0.3) !important;
}
.sidebar::-webkit-scrollbar {
  background: transparent !important;
}
.sidebar::-webkit-scrollbar-thumb {
  background: rgba(255,255,255,0.2) !important;
}
#searchbar {
  background: rgba(0,0,0,0.4) !important;
  border-color: rgba(255,255,255,0.15) !important;
  color: #e6edf3 !important;
}
.searchresults-header {
  color: #d4d4d8 !important;
}
ul#searchresults li.focus {
  background-color: rgba(255,255,255,0.1) !important;
}
"""


def main():
    categories = load_categories()

    if SRC_DIR.exists():
        shutil.rmtree(SRC_DIR)
    SRC_DIR.mkdir()
    for d in MOJO_DIRS:
        if d != ".":
            (SRC_DIR / d).mkdir(parents=True, exist_ok=True)

    for cat_name, files in categories.items():
        for stem in files:
            mojo_path = find_mojo_file(stem)
            if mojo_path:
                md_rel = mojo_to_src_rel(mojo_path)
                md_path = SRC_DIR / md_rel
                md_path.parent.mkdir(parents=True, exist_ok=True)
                md_path.write_text(generate_md_content(mojo_path))
                print(f"  ✓  {md_rel}")
            else:
                md_path = ROOT / f"{stem}.md"
                if md_path.exists():
                    dest = SRC_DIR / f"{stem}.md"
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(md_path, dest)
                    print(f"  ✓  {stem}.md (copied)")
                else:
                    print(f"  !  {stem}.mojo not found — skipping")

    (SRC_DIR / "introduction.md").write_text(generate_introduction(categories))
    print(f"  ✓  src/introduction.md")

    (SRC_DIR / "SUMMARY.md").write_text(generate_summary(categories))
    print(f"  ✓  src/SUMMARY.md")

    if not THEME_CSS_PATH.exists():
        THEME_CSS_PATH.parent.mkdir(parents=True, exist_ok=True)
        THEME_CSS_PATH.write_text(CSS_CONTENT)
        print(f"  ✓  theme/custom.css (written)")
    else:
        print(f"  -  theme/custom.css (already exists — left unchanged)")


if __name__ == "__main__":
    main()
