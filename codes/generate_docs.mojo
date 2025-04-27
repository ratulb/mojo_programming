### Read the Mojo file
import sys
from pathlib import Path

alias GITHUB_REPO_URL = "https://github.com/ratulb/mojo_programming/blob/main/codes/"
alias CODES_DIR = Path("codes")
alias DOCS_DIR = Path("../docs")
alias INDEX_MD = DOCS_DIR / "index.md"


def main():
    if len(sys.argv()) != 2:
        print("Usage: mojo generate_docs.mojo <path_to_mojo_file>")
        sys.exit(-1)
    mojo_file = Path(sys.argv()[1])
    if not mojo_file.exists() and not mojo_file.is_file():
        err = mojo_file.__str__() + " does not exist."
        print(err)
        sys.exit(-1)

    ## Read the Mojo file
    lines = mojo_file.read_text().splitlines()
    comments_found = lines[0].startswith("###") and lines[1].startswith("###")
    if not comments_found:
        print(
            "Mojo file:",
            '"' + mojo_file.__str__() + '"',
            "missing expected comments.",
        )
        sys.exit(-1)
    ## Extract title and description
    title = lines[0].replace("###", "").strip()
    description = lines[1].replace("###", "").strip()

    ## Prepare .md file content
    stem = mojo_file.__str__().split("/")[-1].split(".")[0]
    md_filename = stem + ".md"
    mojo_filename = stem + ".mojo"
    md_path = DOCS_DIR / md_filename
    code_content = StringSlice("\n").join(
        lines[2:]
    )  # skip first two comment lines
    md_text = (
        StringSlice(
            "### " + title + "\n### " + description + "\n\n" + "```python\n"
        )
        + code_content
        + "\n\n```\n\n\n[Source]("
        + GITHUB_REPO_URL
        + mojo_filename
        + ")"
    )
    print(md_text)

    # Write .md file
    md_path.write_text(md_text)
    print("Generated: ", md_path.__str__())

    ## Update index.md
    update_index(title, description, md_filename)


def update_index(
    title: StringSlice, description: StringSlice, md_filename: String
):
    index_lines = INDEX_MD.read_text().splitlines()
    if not index_lines:
        print("Error: index.md is empty!")
        sys.exit(-1)

    last_line = index_lines[-1]
    if "🟢" not in last_line:
        print("Warning: last line of index.md does not match expected format.")

    # Create new entry by copying symbols from last line
    prefix = last_line.split("[")[0]
    new_entry = (
        StringSlice(prefix)
        + "["
        + title
        + "]("
        + md_filename
        + ") ➔ "
        + description
    )
    print(new_entry)

    # Append new entry
    index_lines.append(new_entry)
    INDEX_MD.write_text(StringSlice("\n").join(index_lines) + "\n")
    print("Updated: ", INDEX_MD)
    print()
    print(INDEX_MD.read_text().splitlines()[-1])
    print()
