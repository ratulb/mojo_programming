### Timer utility
### A simple RAII / context-manager timer that prints elapsed wall-clock time in nanoseconds.

from std.time import global_perf_counter_ns


# Timer struct used via Python-style `with` blocks.
#
# Records the time at `__enter__` and prints the elapsed duration at `__exit__`.
# The label prefix is a templated `StringSlice` to avoid allocation.
#
# Usage:
#   with Timer("My computation: "):
#       do_something()
#   # Prints: "My computation:  12345000 nanoseconds"
#
@fieldwise_init
struct Timer[origin: Origin, //](ImplicitlyCopyable):
    var start_time: UInt64
    var prefix: StringSlice[Self.origin]

    def __init__(out self, prefix: StringSlice[Self.origin]):
        self.start_time = 0
        self.prefix = prefix

    def __enter__(mut self) -> Self:
        self.start_time = global_perf_counter_ns()
        return self

    def __exit__(mut self):
        elapsed_time_ms = global_perf_counter_ns() - self.start_time
        print(self.prefix, elapsed_time_ms, "nanoseconds")
