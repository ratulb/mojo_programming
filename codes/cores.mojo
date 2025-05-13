### Check device core
### Check physical and logical cores of the device

from sys import num_physical_cores, num_logical_cores

fn main():
    print("    Physical Cores : ", num_physical_cores())
    print("    Logical Cores  : ", num_logical_cores())
