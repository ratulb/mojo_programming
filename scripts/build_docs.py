#!/usr/bin/env python3
"""Generate MkDocs site content from Mojo source files.

Reads categories.yml, scans .mojo files, and produces:
  - site_source/*.md      — per-file documentation pages
  - site_source/index.md  — landing page with hero + card grid
  - mkdocs.yml            — MkDocs config with full nav tree

Run from project root:  python3 scripts/build_docs.py
"""

import shutil
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parent.parent
CATEGORIES_FILE = ROOT / "categories.yml"
SITE_SOURCE = ROOT / "site_source"
GITHUB_REPO = "https://github.com/ratulb/mojo_programming"
MOJO_DIRS = ["codes", "gpu_puzzles", "mojo_kernels"]


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
    """Short title for nav / heading.
    
    Uses the first ### line only if it's a concise title (≤55 chars).
    Otherwise falls back to humanized filename.
    """
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
    """Longer description for page body — second ### line, or empty if only one."""
    extras = []
    with open(filepath) as f:
        for line in f:
            if line.strip().startswith("###"):
                extras.append(line.strip().replace("###", "").strip())
    return extras[1] if len(extras) > 1 else ""


def strip_initial_hash3(lines):
    """Remove consecutive ###-prefixed lines from the beginning."""
    start = 0
    while start < len(lines) and lines[start].strip().startswith("###"):
        start += 1
    return lines[start:]


def mojo_to_md_rel(mojo_path):
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
        "```mojo",
        code,
        "```",
        "",
        f"[View source on GitHub]({github_url})",
        "",
    ])
    return "\n".join(lines)


def generate_index_page(categories):
    cards = []
    for cat_name, files in categories.items():
        if not files:
            continue
        first = files[0]
        mojo_path = find_mojo_file(first)
        if not mojo_path:
            continue
        first_md = mojo_to_md_rel(mojo_path)
        count = len(files)
        first_url = first_md.replace(".md", "/")
        cards.append(
            f"-   **{cat_name}**\n"
            f"\n"
            f"    ---\n"
            f"\n"
            f"    {count} problem{'s' if count > 1 else ''}\n"
            f"\n"
            f"    [Browse]({first_url})\n"
            f"\n"
        )
    return (
        f"# Mojo 🔥 Programming\n\n"
        f"> CPU & GPU algorithm implementations in the "
        f"[Mojo](https://www.modular.com/mojo) programming language.\n\n"
        f"[![GitHub](https://img.shields.io/badge/GitHub-ratulb/mojo__programming-181717?logo=github)]"
        f"({GITHUB_REPO})\n\n"
        f"---\n\n"
        f"<div class=\"grid cards\" markdown>\n\n"
        f"{''.join(cards)}"
        f"</div>\n"
    )


def generate_nav(categories):
    nav = [{"Home": "index.md"}]
    for cat_name, files in categories.items():
        children = []
        for stem in files:
            mojo_path = find_mojo_file(stem)
            if not mojo_path:
                continue
            title = read_mojo_title(mojo_path)
            md_rel = mojo_to_md_rel(mojo_path)
            children.append({title: md_rel})
        if children:
            nav.append({cat_name: children})
    return nav


def main():
    categories = load_categories()

    if SITE_SOURCE.exists():
        shutil.rmtree(SITE_SOURCE)
    for d in MOJO_DIRS:
        (SITE_SOURCE / d).mkdir(parents=True)

    for cat_name, files in categories.items():
        for stem in files:
            mojo_path = find_mojo_file(stem)
            if not mojo_path:
                print(f"  !  {stem}.mojo not found — skipping")
                continue
            md_rel = mojo_to_md_rel(mojo_path)
            md_path = SITE_SOURCE / md_rel
            md_path.parent.mkdir(parents=True, exist_ok=True)
            md_path.write_text(generate_md_content(mojo_path))
            print(f"  ✓  {md_rel}")

    (SITE_SOURCE / "index.md").write_text(generate_index_page(categories))
    print(f"  ✓  site_source/index.md")

    (SITE_SOURCE / "extra.css").write_text(
        ".md-nav--primary .md-nav__item--section .md-nav__list {\n"
        "  padding-left: 1.6rem;\n"
        "}\n"
        "[data-md-color-scheme=\"default\"] {\n"
        "  --md-default-fg-color: #333;\n"
        "  --md-default-bg-color: #f5f5f7;\n"
        "  --md-primary-fg-color: #1a1a2e;\n"
        "  --md-primary-bg-color: #ffffff;\n"
        "  --md-accent-fg-color: #60a5fa;\n"
        "  --md-typeset-a-color: #60a5fa;\n"
        "  --md-code-bg-color: #e8e8ee;\n"
        "  --md-code-fg-color: #1a1a2e;\n"
        "}\n"
        "h1, h2, h3, h4, h5, h6 {\n"
        "  color: #1a1a2e !important;\n"
        "}\n"
        ".md-typeset .grid.cards > ul > li {\n"
        "  background-color: #ffffff;\n"
        "  border: 1px solid #e0e0e0;\n"
        "  border-radius: 8px;\n"
        "}\n"
        ".md-typeset .grid.cards hr + * {\n"
        "  color: #60a5fa;\n"
        "  font-weight: bold;\n"
        "}\n"
        ".md-typeset,\n"
        ".md-nav {\n"
        "  font-size: 16px;\n"
        "  line-height: 1.7;\n"
        "}\n"
        "@media screen and (min-width: 76.25em) {\n"
        "  .md-typeset,\n"
        "  .md-nav {\n"
        "  font-size: 18px;\n"
        "  }\n"
        "  .md-grid {\n"
        "    max-width: 1400px !important;\n"
        "    padding-left: 1.6rem;\n"
        "  }\n"
        "  .md-content__inner.md-typeset {\n"
        "    margin-right: 0;\n"
        "  }\n"
        "}\n"
    )
    print(f"  ✓  site_source/extra.css")

    nav = generate_nav(categories)
    config = {
        "site_name": "Mojo Programming",
        "site_description": "CPU & GPU algorithm implementations in the Mojo programming language",
        "repo_url": GITHUB_REPO,
        "repo_name": "ratulb/mojo_programming",
        "theme": {
            "name": "material",
            "palette": [
                {
                    "scheme": "default",
                    "primary": "custom",
                    "accent": "custom",
                },
            ],
            "font": {
                "text": "Inter",
                "code": "JetBrains Mono",
            },
            "features": [
                "navigation.sections",
                "navigation.expand",
                "navigation.top",
                "content.code.copy",
            ],
        },
        "extra_css": ["extra.css"],
        "markdown_extensions": [
            "attr_list",
            "md_in_html",
            "pymdownx.highlight",
            "pymdownx.superfences",
            "admonition",
            "pymdownx.details",
            "pymdownx.tabbed",
        ],
        "plugins": ["search"],
        "nav": nav,
        "docs_dir": "site_source",
        "site_dir": "site",
    }
    with open(ROOT / "mkdocs.yml", "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
    print(f"  ✓  mkdocs.yml")


if __name__ == "__main__":
    main()
