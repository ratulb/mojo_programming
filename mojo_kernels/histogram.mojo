### Histogram
### Program to compute histogram of a 1D array

from gpu.host import DeviceContext, HostBuffer, DeviceBuffer
from gpu import thread_idx, block_idx, block_dim
import random
from math import ceildiv
from memory import UnsafePointer
from layout import Layout, LayoutTensor
from os import Atomic
from os.atomic import Consistency

alias dtype = DType.int64
# How many numbers to bin? 2 ^ 20 (default)
alias ELEMS_COUNT = 1 << 20
# How many bins?
alias NUM_BINS = 10
# Num threads per block
alias THREADS = 256
# Total numbers blocks in the grid
alias BLOCKS = ceildiv(ELEMS_COUNT, THREADS)

# Max value of any binned element
alias MAX_ELEM = 101
alias MIN_ELEM = 1

alias BIN_WIDTH = (MAX_ELEM - MIN_ELEM + 1) // NUM_BINS
alias input_layout = Layout.row_major(ELEMS_COUNT)


fn histogram(
    input: LayoutTensor[dtype, input_layout, MutableAnyOrigin],
    output: UnsafePointer[Scalar[dtype]],
    total_elems: Int,
):
    var tid = block_idx.x * block_dim.x + thread_idx.x

    if tid < total_elems:
        var elem = input[tid]
        bin_index = bin_index(elem[0])
        # _ = Atomic.fetch_add[ordering= Consistency.MONOTONIC](output + bin_index, 1)
        _ = Atomic.fetch_add(output + bin_index, 1)


# Initialize the input buffer with values in the range 0 to 100
fn fill_buffer(buffer: HostBuffer[dtype]):
    # Randomize
    random.seed()
    for i in range(len(buffer)):
        buffer[i] = random.random_ui64(MIN_ELEM, MAX_ELEM).cast[dtype]()[0]


# Find the bin index given a number
@always_inline
fn bin_index(elem: Int64) -> Int:
    bin_index = Int((elem - MIN_ELEM) // BIN_WIDTH)
    if bin_index >= NUM_BINS:
        bin_index = NUM_BINS - 1
    elif bin_index < 0:
        bin_index = 0
    return bin_index


fn main():
    try:
        ctx = DeviceContext()

        elements = ctx.enqueue_create_buffer[dtype](ELEMS_COUNT)
        bins = ctx.enqueue_create_buffer[dtype](NUM_BINS).enqueue_fill(0)

        with elements.map_to_host() as host_elements:
            fill_buffer(host_elements)

        input_tensor = LayoutTensor[dtype, input_layout, MutableAnyOrigin](
            elements
        )
        # output_tensor = LayoutTensor[mut=True, dtype, output_layout](bins)

        ctx.enqueue_function[histogram](
            input_tensor,
            bins.unsafe_ptr(),
            ELEMS_COUNT,
            grid_dim=BLOCKS,
            block_dim=THREADS,
        )

        ctx.synchronize()

        with bins.map_to_host() as bins_host:
            print(bins_host)

        print(ctx.name())
    except e:
        print("Prininting here: ", e)
