import sys
from pathlib import Path
GITHUB_REPO_URL = "https://github.com/ratulb/mojo_programming"
CODES_DIR = Path("codes")
DOCS_DIR = Path("docs")
INDEX_MD = DOCS_DIR / "index.md"

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 scripts/generate_docs.py <path_to_mojo_file>")
        sys.exit(1)

    mojo_path = Path(sys.argv[1])
    if not mojo_path.exists():
        print(f"Error: {mojo_path} does not exist.")
        sys.exit(1)

    # Read the Mojo file
    lines = mojo_path.read_text(encoding="utf-8").splitlines()

    # Extract title and description
    title = lines[0].replace("###", "").strip()
    description = lines[1].replace("###", "").strip()

    # Prepare .md file content
    md_filename = mojo_path.stem + ".md"
    mojo_filename = mojo_path.stem + ".md"
    md_path = DOCS_DIR / md_filename
    code_content = "\n".join(lines[2:])  # skip first two comment lines
    md_text = f"""### {title}
### {description}


```python
{code_content}

```

[Source]({GITHUB_REPO_URL}/blob/main/codes/{mojo_filename})

"""


    # Write .md file
    print(md_text)
    md_path.write_text(md_text, encoding="utf-8")
    print(f"Generated {md_path}")

    # Update index.md
    #update_index(title, description, md_filename)
    # Update index.md
    update_index(title, description, md_filename)

def update_index(title, description, md_filename): 
    index_lines = INDEX_MD.read_text(encoding="utf-8").splitlines()  
    if not index_lines:
        print("Error: index.md is empty!")
        sys.exit(1)

    last_line = index_lines[-1]
    if "🟢" not in last_line:
        print("Warning: last line of index.md does not match expected format.")

    # Create new entry by copying symbols from last line
    prefix = last_line.split('[')[0]
    new_entry = f"{prefix}[ {title}]({md_filename}) ➔ {description}"

    # Append new entry
    index_lines.append(new_entry)
    INDEX_MD.write_text("\n".join(index_lines) + "\n", encoding="utf-8")
    print(f"Updated {INDEX_MD}")


main()
