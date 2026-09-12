# Default compiler and simulator
IVERILOG = iverilog
VVP      = vvp
VVP_FLAGS = -g2012

# Directories
RTL_DIR   = rtl
SIM_DIR   = sim
BUILD_DIR = build

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: clean