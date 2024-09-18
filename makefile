# File to make
TARGET_EXEC ?= a.out

# Compilers
AS?=as
CC?=gcc
CXX?=g++
LD?=ld

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
ALL_FLAGS := -Wall -Wextra -Wpedantic
AS_FLAGS ?=
C_FLAGS ?=
CXX_FLAGS ?= -std=c++17
LD_FLAGS ?=
DEBUG_FLAGS ?= -Og -g
RELEASE_FLAGS ?= -O3

# Target
$(BIN_DIR)/$(TARGET_EXEC): $(BIN_DIR) $(OBJS)
	$(CXX) $(ALL_FLAGS) $(LD_FLAGS) $(LIB_FLAGS) $(OBJS) $(LIB_NAMES) -o $@

#Bin Folder
$(BIN_DIR):
	$(MKDIR_P) $(BIN_DIR)

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
.PHONY: clean all debug release install uninstall

# Debug
debug:
	ALL_FLAGS := $(DEBUG_FLAGS)
	$(MAKE) $(BIN_DIR)/$(TARGET_EXEC)

# Release
release:
	ALL_FLAGS := $(RELEASE_FLAGS)
	$(MAKE) $(BIN_DIR)/$(TARGET_EXEC)

# Remove build objects
clean:
	$(RM) -rf $(TARGET_EXEC)
	$(RM) -rf $(OBJ_DIR)

# Clean and build
all:
	$(MAKE) clean
	$(MAKE) $(BIN_DIR)/$(TARGET_EXEC)

# Installation
install: $(BIN_DIR)/$(TARGET_EXEC)
	$(MKDIR_P) $(INSTALL_BIN_DIR)
	$(INSTALL_M) $(BIN_DIR)/$(TARGET_EXEC) $(INSTALL_BIN_DIR)

# Uninstallation
uninstall:
	$(RM) -f $(INSTALL_BIN_DIR)/$(TARGET_EXEC)

-include $(DEPS)

