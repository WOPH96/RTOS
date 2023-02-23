ARCH = armv7-a
MCPU = cortex-a8
MACHINE = realview-pb-a8

TARGET = rvpb

COMPILER = arm-none-eabi-
CC = $(COMPILER)gcc
AS = $(COMPILER)as
LD = $(COMPILER)ld
OC = $(COMPILER)objcopy
OD = $(COMPILER)objdump
GDB = $(COMPILER)gdb

LINKER_SCRIPT = ./navilos.ld
MAP_FILE = build/navilos.map

# wildcard parttern - 패턴과 일치하는 것을 불러오는 데 사용한다 
# patsubst pattern,replacement,text - text 중에서 패턴과 일치하는 것을 대치한다 
ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS)) # 위에 사용된 *과 같은 의미

C_SRCS = $(notdir $(wildcard boot/*.c))
C_SRCS += $(notdir $(wildcard hal/$(TARGET)/*.c))
C_OBJS = $(patsubst boot/%.c, build/%.o, $(C_SRCS))

VPATH = boot \
		 hal/$(TARGET)

INC_DIRS = include

CFLAGS = -c -g -std=c11

navilos = build/navilos.axf
navilos_bin = build/navilos.bin

# 충돌 방지용 mention 
# e.g. : clean이라는 파일이 있어도 make clean 시 문제 없게
.PHONY = all clean run debug gdb dump hex

# left - Target (빌드 하려는 대상) : right - Dependencies (나열된 Dependencies를 먼저 만들고 빌드 Target을 생성함)
#	Recipe (빌드 내용)
# make 'Target' 식으로 호출
# make만 호출 시, 맨 위의 Target이 호출됨 

all : $(navilos)

# @을 붙이면 출력을 감춤
clean:
	@rm -fr build

# $(navilos)를 빌드한 뒤 동작함
run : $(navilos)
	qemu-system-arm -M $(MACHINE) -kernel $(navilos)

# $(navilos)를 빌드한 뒤 동작함
debug : $(navilos)
	qemu-system-arm -M $(MACHINE) -kernel $(navilos) -S -gdb tcp::1234,ipv4

gdb :
	$(GDB)

dump : $(navilos)
	$(OD) -D $(navilos)

hex : $(navilos_bin)
	@hexdump $(navilos_bin)
	

# $(navilos)= navilos.axf 를 빌드
# 의존성이 전부 충족되어야 빌드가능
# C_OBJS = C_SRCS 으로부터 생성 
# ASM_OBJS = ASM_SRCS --> from boot/%.S to build/%.o 
$(navilos) : $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(navilos) $(ASM_OBJS) $(C_OBJS) -Map=$(MAP_FILE)
	$(OC) -O binary $(navilos) $(navilos_bin)

# ASM SRCS가 존재해야 함
# $@ : 현재 타겟의 이름
# $< : 의존 파일 목록의 첫 번째 파일
# $^ : 의존 파일 목럭 전체
$(ASM_OBJS) : $(ASM_SRCS)
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -I $(INC_DIRS) -c -g -o $@ $< 

$(C_OBJS) : $(C_SRCS)
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -I $(INC_DIRS) -c -g -o $@ $<