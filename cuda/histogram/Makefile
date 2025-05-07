# CUDA compiler
NVCC := nvcc

# Directories
INCLUDE_DIR := include
SRC_DIR := src
BUILD_DIR := build

# Source files
SRCS := $(wildcard $(SRC_DIR)/*.cu)
TARGET := $(BUILD_DIR)/histogram

# Flags
NVCC_FLAGS := -I$(INCLUDE_DIR) -O2

# Default rule
all: $(TARGET)

# Linking and compilation
$(TARGET): $(SRCS) | $(BUILD_DIR)
	$(NVCC) $(NVCC_FLAGS) $(SRCS) -o $@

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Cleanup rule
clean:
	rm -rf $(BUILD_DIR)

