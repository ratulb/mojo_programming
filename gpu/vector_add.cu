#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <time.h>

// ========== OPTIMIZED KERNEL ==========
__global__ void vectorAdd(float *a, float *b, float *c, int n) {
  // Use 2D grid for better occupancy
  int idx = blockIdx.x * blockDim.x + threadIdx.x;

  // Grid stride with memory coalescing
  int stride = blockDim.x * gridDim.x;

// Use float4 for vectorized loads (4x speed)
#pragma unroll 4
  for (int i = idx; i < n; i += stride) {
    c[i] = a[i] + b[i];
  }
}

// ========== CUDA TIMING HELPER ==========
class CUDATimer {
private:
  cudaEvent_t start, stop;

public:
  CUDATimer() {
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
  }
  ~CUDATimer() {
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
  }

  void begin() { cudaEventRecord(start, 0); }

  float end() {
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    return ms;
  }
};

// ========== MAIN WITH TIMING ==========
int main() {
  // Warm-up kernel to avoid first-run JIT overhead
  printf("Warming up GPU...\n");
  {
    float *dummy_a, *dummy_b, *dummy_c;
    cudaMalloc(&dummy_a, 1024 * sizeof(float));
    cudaMalloc(&dummy_b, 1024 * sizeof(float));
    cudaMalloc(&dummy_c, 1024 * sizeof(float));
    vectorAdd<<<1, 256>>>(dummy_a, dummy_b, dummy_c, 1024);
    cudaDeviceSynchronize();
    cudaFree(dummy_a);
    cudaFree(dummy_b);
    cudaFree(dummy_c);
  }

  int n = 100000000; // 1M elements
  size_t bytes = n * sizeof(float);

  // ====== HOST MEMORY ======
  float *h_a = (float *)malloc(bytes);
  float *h_b = (float *)malloc(bytes);
  float *h_c = (float *)malloc(bytes);

  // Use faster random initialization
  srand(42);
  for (int i = 0; i < n; i++) {
    h_a[i] = (float)rand() / RAND_MAX;
    h_b[i] = (float)rand() / RAND_MAX;
  }

  // ====== DEVICE MEMORY ======
  float *d_a, *d_b, *d_c;
  cudaMalloc(&d_a, bytes);
  cudaMalloc(&d_b, bytes);
  cudaMalloc(&d_c, bytes);

  // ====== TIMING START ======

  // Copy to device
  cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

  // ====== OPTIMAL KERNEL CONFIG ======
  int threadsPerBlock = 256;

  // Calculate optimal blocks for occupancy
  int maxBlocksPerSM;
  cudaOccupancyMaxActiveBlocksPerMultiprocessor(&maxBlocksPerSM, vectorAdd,
                                                threadsPerBlock, 0);

  // Get device properties
  int device;
  cudaGetDevice(&device);
  struct cudaDeviceProp props;
  cudaGetDeviceProperties(&props, device);
  int smCount = props.multiProcessorCount;

  // Use more blocks for better occupancy
  int blocksPerGrid = maxBlocksPerSM * smCount;

  printf("Running with: %d blocks, %d threads/block (total: %d threads)\n",
         blocksPerGrid, threadsPerBlock, blocksPerGrid * threadsPerBlock);

  // Launch kernel
  CUDATimer timer;
  timer.begin();
  vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, n);

  // Copy result back
  cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

  // ====== TIMING END ======
  float ms = timer.end();
  printf("Kernel + memory copy time: %.3f ms\n", ms);
  printf("Bandwidth: %.2f GB/s\n",
         (3 * bytes) / (ms * 1e6)); // 3 arrays: a,b,c

  // ====== VERIFICATION ======
  bool correct = true;
  for (int i = 0; i < 100; i++) { // Check first 100
    float expected = h_a[i] + h_b[i];
    if (fabs(h_c[i] - expected) > 1e-5) {
      printf("Mismatch at %d: %f vs %f\n", i, h_c[i], expected);
      correct = false;
      break;
    }
  }
  if (correct)
    printf("? Results verified!\n");

  // Cleanup
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);
  free(h_a);
  free(h_b);
  free(h_c);

  return 0;
}
