BUILD_HARNESS_PATH ?= $(shell 'pwd')
OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
SELF ?= make

include $(BUILD_HARNESS_PATH)/Makefile.*
include $(BUILD_HARNESS_PATH)/modules/*/*
