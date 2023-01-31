ARCH = armv7-a
MCPU = cortex-a8
MACHINE = realview-pb-a8

COMPILER = arm-none-eabi-
CC = $(COMPILER)gcc
AS = $(COMPILER)as
LD = $(COMPILER)ld
OC = $(COMPILER)objcopy
GDB = $(COMPILER)gdb

LINKER_SCRIPT = ./navilos.ld

# wildcard parttern - 패턴과 일치하는 것을 불러오는 데 사용한다 
ASM_SRCS = $(wildcard boot/*.S)
# patsubst pattern,replacement,text - text 중에서 패턴과 일치하는 것을 대치한다 
ASM_OBJS = $(patsubst boot/%.S, build/%.o, $(ASM_SRCS)) # 위에 사용된 *과 같은 의미

navilos = build/navilos.axf
navilos_bin = build/navilos.bin

# 충돌 방지용 mention 
# e.g. : clean이라는 파일이 있어도 make clean 시 문제 없게
.PHONY = all clean run debug gdb 

# left - Target (빌드 하려는 대상) : right - Dependencies (나열된 Dependencies를 먼저 만들고 빌드 Target을 생성함)
#	Recipe (빌드 내용)

all: $(navilos)

clean:
	@rm -fr build

# $(navilos)를 빌드한 뒤 동작함
run: $(navilos)
	qemu-system-arm -M $(MACHINE) -kernel $(navilos)

# $(navilos)를 빌드한 뒤 동작함
debug: $(navilos)
	qemu-system-arm -M $(MACHINE) -kernel $(navilos) -S -gdb tcp::1234,ipv4

gdb :
	$(GDB)

# $(navilos)를 빌드한 뒤 동작함
# ASM_OBJS = ASM_SRCS --> from boot/%.S to build/%.o 
$(navilos): $(ASM_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(navilos) $(ASM_OBJS)
	$(OC) -O binary $(navilos) $(navilos_bin)

# ASM SRCS가 존재해야 함
# $@ : 현재 타겟의 이름
# $< : 의존 파일 목록의 첫 번째 파일
# $^ : 의존 파일 목럭 전체
$(ASM_OBJS) : $(ASM_SRCS)
	mkdir -p $(shell dirname $@)
	$(AS) -march=$(ARCH) -mcpu=$(MCPU) -g -o $@ $<
