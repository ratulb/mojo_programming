#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>

// ========== OPTIMIZED KERNEL ==========
__global__ void vectorAddOptimized(float *a, float *b, float *c, int n) {
  // Use more threads per block for better occupancy
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;

// UNROLL THE LOOP for better performance
#pragma unroll 4
  for (int i = idx; i < n; i += stride) {
    c[i] = a[i] + b[i];
  }
}

// ========== ALTERNATIVE: Vectorized Loads (Float4) ==========
__global__ void vectorAddFloat4(float *a, float *b, float *c, int n) {
  int idx = (blockIdx.x * blockDim.x + threadIdx.x) * 4;
  int stride = blockDim.x * gridDim.x * 4;

  // Process 4 floats at once using float4
  for (int i = idx; i < n; i += stride) {
    float4 a4 = reinterpret_cast<float4 *>(a)[i / 4];
    float4 b4 = reinterpret_cast<float4 *>(b)[i / 4];
    float4 c4;
    c4.x = a4.x + b4.x;
    c4.y = a4.y + b4.y;
    c4.z = a4.z + b4.z;
    c4.w = a4.w + b4.w;
    reinterpret_cast<float4 *>(c)[i / 4] = c4;
  }
}

// ========== TIMING HELPER ==========
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

int main() {
  // ========== SETUP ==========
  int n = 1000000; // 1M elements
  size_t bytes = n * sizeof(float);

  // Warm-up kernel
  printf("🔄 Warming up GPU...\n");
  float *dummy_a, *dummy_b, *dummy_c;
  cudaMalloc(&dummy_a, 1024 * sizeof(float));
  cudaMalloc(&dummy_b, 1024 * sizeof(float));
  cudaMalloc(&dummy_c, 1024 * sizeof(float));
  vectorAddOptimized<<<1, 256>>>(dummy_a, dummy_b, dummy_c, 1024);
  cudaDeviceSynchronize();
  cudaFree(dummy_a);
  cudaFree(dummy_b);
  cudaFree(dummy_c);

  // ========== HOST MEMORY (with Pinned Memory) ==========
  float *h_a, *h_b, *h_c;
  cudaMallocHost(&h_a, bytes); // Pinned memory for faster transfers
  cudaMallocHost(&h_b, bytes);
  cudaMallocHost(&h_c, bytes);

  // Initialize with realistic data
  for (int i = 0; i < n; i++) {
    h_a[i] = (float)rand() / RAND_MAX;
    h_b[i] = (float)rand() / RAND_MAX;
  }

  // ========== DEVICE MEMORY ==========
  float *d_a, *d_b, *d_c;
  cudaMalloc(&d_a, bytes);
  cudaMalloc(&d_b, bytes);
  cudaMalloc(&d_c, bytes);

  // ========== TIMING START ==========
  CUDATimer timer;
  timer.begin();

  // Copy to device
  cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

  // ========== OPTIMAL KERNEL CONFIG ==========
  int threadsPerBlock = 256; // Standard for most GPUs

  // Calculate optimal blocks for occupancy
  int maxBlocksPerSM;
  cudaOccupancyMaxActiveBlocksPerMultiprocessor(
      &maxBlocksPerSM, vectorAddOptimized, threadsPerBlock, 0);

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
  printf("   SMs: %d, Max blocks/SM: %d\n", smCount, maxBlocksPerSM);
  printf("   Theoretical occupancy: %.1f%%\n",
         100.0 * blocksPerGrid * threadsPerBlock /
             (smCount * props.maxThreadsPerMultiProcessor));

  // ========== LAUNCH KERNEL ==========
  vectorAddOptimized<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, n);

  // Copy result back
  cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

  // ========== TIMING END ==========
  float ms = timer.end();
  printf("⏱️  Kernel + memory copy time: %.3f ms\n", ms);
  printf("📊 Bandwidth: %.2f GB/s\n",
         (3 * bytes) / (ms * 1e6)); // 3 arrays: a,b,c

  // ========== VERIFICATION ==========
  bool correct = true;
  for (int i = 0; i < 100; i++) {
    float expected = h_a[i] + h_b[i];
    if (fabs(h_c[i] - expected) > 1e-5) {
      printf("❌ Mismatch at %d: %f vs %f\n", i, h_c[i], expected);
      correct = false;
      break;
    }
  }
  if (correct)
    printf("✅ Results verified!\n");

  // ========== CLEANUP ==========
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);
  cudaFreeHost(h_a);
  cudaFreeHost(h_b);
  cudaFreeHost(h_c);

  return 0;
}
