# Gravity paths
GRAVITY_PATH = vendor/gravity
GRAVITY_SRC_PATH = $(GRAVITY_PATH)/src
GRAVITY_BUILD_PATH = $(GRAVITY_PATH)/build

# Gravity build configuration: static library in release mode
GRAVITY_BUILD_TYPE = Release
GRAVITY_API_TARGET = gravityapi_s
GRAVITY_LIB_PATH = $(GRAVITY_BUILD_PATH)/lib/lib$(GRAVITY_API_TARGET).a


# Compiler
CC = clang
CC_STANDARD = c23
CC_OPT_FLAGS = -Os
CC_WARNING_FLAGS = -Wall -Wextra -pedantic
CC_INCLUDE_FLAGS = \
	-I$(GRAVITY_SRC_PATH)/compiler \
	-I$(GRAVITY_SRC_PATH)/optionals \
	-I$(GRAVITY_SRC_PATH)/runtime \
	-I$(GRAVITY_SRC_PATH)/shared \
	-I$(GRAVITY_SRC_PATH)/utils

# Compiler flags
CFLAGS = -std=$(CC_STANDARD) $(CC_OPT_FLAGS) $(CC_WARNING_FLAGS) $(CC_INCLUDE_FLAGS)


# system libraries (like math) have to be last to correctly perform static linking!
LDFLAGS = -static $(GRAVITY_LIB_PATH) -lm

# Source files
SRC = src/sample.c

# Output executable
OUTPUT = bin/gravityz

# Build targets
.PHONY: all
all: $(OUTPUT)

$(GRAVITY_LIB_PATH):
	git submodule update --init --recursive
	mkdir -p $(GRAVITY_BUILD_PATH)
	cd $(GRAVITY_BUILD_PATH); cmake -DCMAKE_BUILD_TYPE=$(GRAVITY_BUILD_TYPE) ..
	cd $(GRAVITY_BUILD_PATH); make -j $(nproc) $(GRAVITY_API_TARGET)

# Link the object files to create the executable
$(OUTPUT): $(GRAVITY_LIB_PATH) $(SRC)
	mkdir -p bin
	$(CC) $(CFLAGS) $(SRC) -o $(OUTPUT) $(LDFLAGS)

# Clean target to remove the executable
clean:
	rm -rf bin
	rm -rf $(GRAVITY_PATH)/build
