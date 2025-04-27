#!/usr/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <mojo file name> "
  exit 1
fi
FILENAME=$1 
python3 scripts/generate_docs.py ${FILENAME}
