# File to make
TARGET_EXEC ?= a.out

# Compilers
AS=as
CC=gcc
CXX=g++
LD=ld

# Directories
SRC_DIRS ?= src
OBJ_DIR ?= obj
BIN_DIR ?= bin

# Objects
SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.cxx -or -name *.c -or -name *.s)
OBJS := $(SRCS:%=$(OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

# Includes
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_DIRS += include
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Libraries
LIB_DIRS :=
LIB_NAMES :=
LIB_FLAGS := $(addprefix -L,$(LIB_DIRS))

# Flags
ALL_FLAGS := -Wall -Wextra -Wpedantic -Wabi
AS_FLAGS ?=
C_FLAGS ?=
CXX_FLAGS ?= -std=c++17
LD_FLAGS ?=

# Target
$(BIN_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CXX) $(ALL_FLAGS) $(LD_FLAGS) $(LIB_FLAGS) $(OBJS) $(LIB_NAMES) -o $@

# Assembly
$(OBJ_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(INC_FLAGS) $(ALL_FLAGS) $(AS_FLAGS) -c $< -o $@

# C Source
$(OBJ_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(INC_FLAGS) $(ALL_FLAGS) $(C_FLAGS) -c $< -o $@

# C++ Source
$(OBJ_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(INC_FLAGS) $(ALL_FLAGS) $(CXX_FLAGS) -c $< -o $@

# Phonies
.PHONY: clean all debug release

# Debug
debug:
	ALL_FLAGS := -Og -g
	$(MAKE) $(BIN_DIR)/$(TARGET_EXEC)

# Release
release:
	ALL_FLAGS := -O2
	$(MAKE) $(BIN_DIR)/$(TARGET_EXEC)

# Remove build objects
clean:
	$(RM) -rf $(TARGET_EXEC)
	$(RM) -rf $(OBJ_DIR)

# Clean and build
all:
	$(MAKE) clean
	$(MAKE) $(BIN_DIR)/$(TARGET_EXEC)

-include $(DEPS)

# Easy commands
MKDIR_P ?= mkdir -p

