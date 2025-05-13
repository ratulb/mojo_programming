from layout import Layout, LayoutTensor
from algorithm import vectorize
from sys import simdwidthof


fn summer[
    type: DType, layout: Layout, //, simdwidth: Int = simdwidthof[type]()
](
    tensor: LayoutTensor[type, layout, MutableAnyOrigin],
    start: Int = 0,
    end: Int = layout.size(),
) -> Scalar[type]:
    result = Scalar[type](0)

    @parameter
    fn sum[simd_width: Int](idx: Int):
        result += tensor.load[width=simd_width](0, start + idx).reduce_add()

    vectorize[sum, simdwidth](end - start)
    return result


fn main():
    from math import iota
    alias elems_count = 1 << 10
    var array = InlineArray[Scalar[DType.uint32], elems_count](fill=0)
    iota(array.unsafe_ptr(), elems_count)
    tensor = LayoutTensor[
        DType.uint32, Layout.row_major(1, elems_count), MutableAnyOrigin
    ](array.unsafe_ptr())
    #print(tensor)
    start = 1022
    end = 1024
    #result = summer[16](tensor, start, end)
    result = summer(tensor)
    print(result)
