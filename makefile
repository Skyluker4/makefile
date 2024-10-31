# File to make
TARGET_EXEC ?= a.out

# Compilers
AS ?= as
CC ?= gcc
CXX ?= g++
LD ?= ld

# Commands
MKDIR_P ?= mkdir -p
INSTALL_M ?= install -m 755

# Default installation prefix
PREFIX ?= /usr/local
INSTALL_BIN_DIR ?= $(PREFIX)/bin

# Directories
SRC_DIRS ?= src
OBJ_DIR ?= obj
BIN_DIR ?= bin

# Build type configuration
OBJ_TYPE_DIR = $(OBJ_DIR)/$(BUILD_TYPE)

# Objects
SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.cxx -or -name *.c -or -name *.s)
OBJS := $(SRCS:%=$(OBJ_TYPE_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

# Includes
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_DIRS += include
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Libraries
LIB_DIRS :=
LIB_NAMES :=
LIB_FLAGS := $(addprefix -L,$(LIB_DIRS)) $(addprefix -l,$(LIB_NAMES))

# Flags
ALL_FLAGS := -Wall -Wextra -Wpedantic
AS_FLAGS ?=
C_FLAGS ?=
CXX_FLAGS ?= -std=c++17
LD_FLAGS ?=

# Build type specific flags
DEBUG_FLAGS ?= -Og -g
RELEASE_FLAGS ?= -O3
RELEASE_LD_FLAGS := -s
DEBUG_LD_FLAGS :=

# Set flags based on BUILD_TYPE
ifeq ($(BUILD_TYPE),debug)
    ALL_FLAGS += $(DEBUG_FLAGS)
    LD_FLAGS += $(DEBUG_LD_FLAGS)
endif
ifeq ($(BUILD_TYPE),release)
    ALL_FLAGS += $(RELEASE_FLAGS)
    LD_FLAGS += $(RELEASE_LD_FLAGS)
endif

BUILD_TYPE_FILE := $(BIN_DIR)/.build_type

# Target with check_build_type as a prerequisite
$(BIN_DIR)/$(TARGET_EXEC): check_build_type $(OBJS) $(BIN_DIR)
	@if [ "$(BUILD_TYPE)" = "release" ] || [ "$(BUILD_TYPE)" = "debug" ]; then \
		echo "$(BUILD_TYPE)" > $(BUILD_TYPE_FILE); \
	else \
		$(RM) -f $(BUILD_TYPE_FILE); \
	fi
	$(CXX) $(ALL_FLAGS) $(LD_FLAGS) $(OBJS) $(LIB_FLAGS) -o $@

# Bin Folder
$(BIN_DIR):
	$(MKDIR_P) $(BIN_DIR)

# Assembly for .s
$(OBJ_TYPE_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(INC_FLAGS) $(ALL_FLAGS) $(AS_FLAGS) -c $< -o $@

# Assembly for .asm
$(OBJ_TYPE_DIR)/%.asm.o: %.asm
	$(MKDIR_P) $(dir $@)
	$(AS) $(INC_FLAGS) $(ALL_FLAGS) $(AS_FLAGS) -c $< -o $@

# C Source
$(OBJ_TYPE_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(INC_FLAGS) $(ALL_FLAGS) $(C_FLAGS) -c $< -o $@

# C++ Source for .cpp files
$(OBJ_TYPE_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(INC_FLAGS) $(ALL_FLAGS) $(CXX_FLAGS) -c $< -o $@

# C++ Source for .cxx files
$(OBJ_TYPE_DIR)/%.cxx.o: %.cxx
	$(MKDIR_P) $(dir $@)
	$(CXX) $(INC_FLAGS) $(ALL_FLAGS) $(CXX_FLAGS) -c $< -o $@

# Phonies
.PHONY: clean all debug release install uninstall

# Debug
debug:
	$(MAKE) BUILD_TYPE=debug $(BIN_DIR)/$(TARGET_EXEC)

# Release
release:
	$(MAKE) BUILD_TYPE=release $(BIN_DIR)/$(TARGET_EXEC)

# Check if build type has changed, clean binary if needed
check_build_type: clean_bin_if_needed

# Separate rule to clean only the binary file
clean_bin_if_needed:
	@if [ -f $(BUILD_TYPE_FILE) ]; then \
		if [ "$$(cat $(BUILD_TYPE_FILE))" != "$(BUILD_TYPE)" ]; then \
			echo "Switching build type, removing binary..."; \
			$(MAKE) clean_bin; \
		fi \
	fi

# Clean only the binary file
clean_bin:
	$(RM) -f $(BIN_DIR)/$(TARGET_EXEC)

clean: clean_bin
	$(RM) -rf $(BIN_DIR)
	$(RM) -rf $(OBJ_DIR)

# Clean and build
all: clean $(BIN_DIR)/$(TARGET_EXEC)

# Installation
install: $(BIN_DIR)/$(TARGET_EXEC)
	$(MKDIR_P) $(INSTALL_BIN_DIR)
	$(INSTALL_M) $(BIN_DIR)/$(TARGET_EXEC) $(INSTALL_BIN_DIR)

# Uninstallation
uninstall:
	$(RM) -f $(INSTALL_BIN_DIR)/$(TARGET_EXEC)

-include $(DEPS)
