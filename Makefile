ARCH=armv7-a
MCPU=cortex-a8

CROSS=arm-none-eabi-
CC=$(CROSS)gcc 

ech: all
	echo $(CC)

all : 
	touch d