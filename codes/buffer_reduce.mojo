from buffer import NDBuffer
from algorithm import vectorize
from sys import simdwidthof


fn summer[
    type: DType, //, simdwidth: Int = simdwidthof[type]()
](buffer: NDBuffer[type=type, rank=1]) -> Scalar[type]:
    result = Scalar[type](0)

    @parameter
    fn sum[simd_width: Int](idx: Int):
        result += buffer.load[width=simd_width](idx).reduce_add()

    vectorize[sum, simdwidth](len(buffer))
    return result


from collections import InlineArray
from math import iota


fn main() raises:
    alias elem_count = 30
    var array = InlineArray[Scalar[DType.float64], elem_count](
        uninitialized=True
    )
    iota(array.unsafe_ptr(), elem_count)

    var buf = NDBuffer[DType.float64, 1, _, elem_count](array)

    result = summer(buf)
    print(result)
