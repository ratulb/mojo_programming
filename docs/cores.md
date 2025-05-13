### Check device core
### Check physical and logical cores of the device

```python

from sys import num_physical_cores, num_logical_cores

fn main():
    print("    Physical Cores : ", num_physical_cores())
    print("    Logical Cores  : ", num_logical_cores())

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/cores.mojo)