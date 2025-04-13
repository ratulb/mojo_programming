# Mojo 🔥 Programming

Welcome to the **Mojo Programming** repository!  
This repo contains programming problems and solutions implemented using the **[Mojo](https://www.modular.com/mojo)** language.

---
## 📌 Running mojo in google colab
Run the following commands in notebook cells.

Install magic:
```bash
!curl -ssL https://magic.modular.com/ | bash
```
---

## 📌 Issues & Fixes

If running Mojo on Ubuntu gives an error like:

> **No suitable compiler found** or similar build issues,

Run the following commands to install the necessary dependencies:

```bash
sudo apt update
sudo apt install -y build-essential
```

> **/usr/bin/ld: cannot find -lz: No such file or directory**

> **/usr/bin/ld: cannot find -ltinfo: No such file or directory**

Means the linker (ld) is unable to find two required libraries:

* -lz → the zlib compression library

* -ltinfo → the termcap/info library, part of ncurses

Run the following commands to install the necessary dependencies:

```bash
sudo apt-get update
sudo apt-get install zlib1g-dev libtinfo-dev
```
* zlib1g-dev: Provides libz.so
* libtinfo-dev: Provides libtinfo.so (used for terminal interfaces)

Upadate PATH:

```python
import os
os.environ['PATH'] += ':/root/.modular/bin'
```
---
Create a example mojo project:
```bash
!magic init example --format mojoproject
```
---
Go inside project folder:
```bash
%cd example/
```
Create a sample hello.mojo file:

```bash
%%bash
cat > hello.mojo <<EOF
fn main():
  print("Hello word from mojo!")
EOF
```
----
Run the mojo program:
```bash
!magic run mojo hello.mojo
```
---
Build and run the binary if you want:
```bash
!magic run mojo build hello.mojo
!./hello
```
