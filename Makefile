ARCH = armv7-a
MCPU = cortex-a8

COMPILER = arm-none-eabi-
CC = $(COMPILER)gcc
AS = $(COMPILER)as
LD = $(COMPILER)ld
OC = $(COMPILER)objcopy

LINKER_SCRIPT = ./navilos.ld

ASM_SRCS = $(wildcard boot/*.S)
