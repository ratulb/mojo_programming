#include "../include/kernel.cuh"

__global__ void compute_histogram(const unsigned char* image, int* histogram, int size) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < size) {
        unsigned char pixel = image[idx];
        atomicAdd(&histogram[pixel], 1);
    }
}

