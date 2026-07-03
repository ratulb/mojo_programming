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


def parse_mojo_headers(filepath):
    """Extract (title, description, header_line_count) from a .mojo file.

    Reads a Mojo module-level docstring (triple quotes):
      - first non-empty line inside is the title
      - remaining lines form the description
    Returns (title, description, header_line_count). header_line_count is the
    number of lines consumed by the docstring block.
    """
    with open(filepath) as f:
        raw_lines = f.readlines()

    if not raw_lines or not raw_lines[0].strip().startswith('"""'):
        return ("", "", 0)

    doc_lines = []
    i = 1  # skip opening """
    if len(raw_lines[0].strip()) > 3:
        # title on same line as opening """
        rest = raw_lines[0].strip()[3:]
        if rest.endswith('"""'):
            rest = rest[:-3]
        if rest:
            doc_lines.append(rest)
        # if it also closed on the same line, we're done
        if raw_lines[0].strip().endswith('"""'):
            return _docstring_result(doc_lines, 1)
    elif raw_lines[0].strip() == '"""':
        pass  # opening on its own line
    else:
        return ("", "", 0)

    for j in range(i, len(raw_lines)):
        s = raw_lines[j].strip()
        if s == '"""':
            return _docstring_result(doc_lines, j + 1)
        doc_lines.append(raw_lines[j].rstrip())

    return _docstring_result(doc_lines, len(raw_lines))


def _docstring_result(lines, line_count):
    """Split docstring lines into (title, description, line_count).

    First non-empty line is the title; the rest is the description.
    """
    title = ""
    desc_lines = []
    for l in lines:
        if not title:
            stripped = l.strip()
            if stripped:
                title = stripped
            else:
                desc_lines.append(l)
        else:
            desc_lines.append(l)
    desc = "\n".join(desc_lines).strip()
    return (title, desc, line_count)


def read_mojo_title(filepath):
    """Wrapper for backward compatibility. Returns the title from a .mojo file."""
    title, _, _ = parse_mojo_headers(filepath)
    if title:
        return title
    stem = filepath.stem
    return stem.replace("_", " ").replace("-", " ").title()


def read_mojo_description(filepath):
    """Wrapper for backward compatibility. Returns the description."""
    _, desc, _ = parse_mojo_headers(filepath)
    return desc


def mojo_to_src_rel(mojo_path):
    """Convert a .mojo path to its relative path under src/."""
    rel = mojo_path.relative_to(ROOT)
    return f"{rel.parent}/{rel.stem}.md"


def generate_md_content(mojo_path):
    title, desc, header_count = parse_mojo_headers(mojo_path)
    if not title:
        title = mojo_path.stem.replace("_", " ").replace("-", " ").title()
    rel_path = mojo_path.relative_to(ROOT)
    github_url = f"{GITHUB_REPO}/blob/main/{rel_path}"

    with open(mojo_path) as f:
        source_lines = f.readlines()
    code = "".join(source_lines[header_count:]).strip()

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

        lines.append(f"- [{cat_name}]()")
        for child_title, child_rel in children:
            lines.append(f"  - [{child_title}]({child_rel})")
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
