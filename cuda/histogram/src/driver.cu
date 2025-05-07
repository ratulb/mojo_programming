#include <iostream>
#include <cuda_runtime.h>
#include "../include/kernel.cuh"

const int IMG_SIZE = 1024 * 1024;
const int HIST_SIZE = 256;

int main() {
    unsigned char* h_image = new unsigned char[IMG_SIZE];
    for (int i = 0; i < IMG_SIZE; i++)
        h_image[i] = rand() % 256;

    unsigned char* d_image;
    int* d_histogram;
    cudaMalloc(&d_image, IMG_SIZE);
    cudaMalloc(&d_histogram, HIST_SIZE * sizeof(int));
    cudaMemcpy(d_image, h_image, IMG_SIZE, cudaMemcpyHostToDevice);
    cudaMemset(d_histogram, 0, HIST_SIZE * sizeof(int));

    int threadsPerBlock = 256;
    int blocks = (IMG_SIZE + threadsPerBlock - 1) / threadsPerBlock;
    compute_histogram<<<blocks, threadsPerBlock>>>(d_image, d_histogram, IMG_SIZE);
    cudaDeviceSynchronize();

    int h_histogram[HIST_SIZE];
    cudaMemcpy(h_histogram, d_histogram, HIST_SIZE * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < 10; ++i)
        std::cout << "Bin " << i << ": " << h_histogram[i] << std::endl;

    delete[] h_image;
    cudaFree(d_image);
    cudaFree(d_histogram);
    return 0;
}

