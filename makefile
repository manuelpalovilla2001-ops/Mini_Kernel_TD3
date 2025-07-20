#CHAIN=arm-none-eabi
CHAIN     = arm-linux-gnueabihf
AS        = $(CHAIN)-as
CC        = $(CHAIN)-gcc
LD        = $(CHAIN)-ld
OBJCOPY   = $(CHAIN)-objcopy
OBJDUMP   = $(CHAIN)-objdump
READELF   = $(CHAIN)-readelf

CFLAGS    = -std=gnu99 -Wall -mcpu=cortex-a8 -O0 -g

OBJ       = obj/
BIN       = bin/
INC       = inc/
SRC       = src/
LST       = lst/

NAME      = mi_ej7
ENTRY_S   = ej7.s
LINKER    = memmap.ld

SRCS_S    = #Añadir .s que uso
SRCS_C    = #Añadir .c que uso

ENTRY_O   = $(OBJ)$(ENTRY_S:.s=.o)
OBJS_S    = $(patsubst %.s,$(OBJ)%.o,$(SRCS_S))
OBJS_C    = $(patsubst %.c,$(OBJ)%.o,$(SRCS_C))
OBJS      = $(ENTRY_O) $(OBJS_S) $(OBJS_C)

ELF       = $(OBJ)$(NAME).elf
BINFILE   = $(BIN)$(NAME).bin
MAPFILE   = $(LST)$(NAME).map
ELFTXT    = $(LST)$(NAME)_elf.txt
LSTFILE   = $(LST)$(NAME).lst

all: $(BINFILE) $(ELF)

$(BINFILE): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): $(OBJS)
	@echo "Linkeando ..."
	mkdir -p $(OBJ) $(LST)
	$(LD) -g -T $(LINKER) $(OBJS) -o $@ -Map $(MAPFILE)
	@echo "Linkeo finalizado!"
	@echo "Generando mapa y símbolos"
	$(READELF) -a $@ > $(ELFTXT)
	$(OBJDUMP) -D $@ > $(LSTFILE)

$(OBJ)%.o: $(SRC)%.s
	@echo ""
	mkdir -p $(BIN) $(OBJ) $(LST)
	@echo "Ensamblando $< ..."
	$(AS) $< -g -o $@ -a > $(LST)$*.lst

$(OBJ)%.o: $(SRC)%.c
	@echo ""
	mkdir -p $(BIN) $(OBJ) $(LST)
	@echo "Compilando $< ..."
	$(CC) -g $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ)*.o $(OBJ)*.elf $(BIN)*.bin $(LST)*.lst $(LST)*.txt $(LST)*.map .gdbinit_tmp

run:
	qemu-system-arm -M realview-pb-a8 -m 512M -no-reboot -nographic \
	-monitor telnet:127.0.0.1:1234,server,nowait -S -gdb tcp::2159 \
	-kernel $(BINFILE)

debug:
	@echo "target remote localhost:2159" > .gdbinit_tmp
	@echo "file $(ELF)" >> .gdbinit_tmp
	ddd --debugger gdb-multiarch -x .gdbinit_tmp


.PHONY: all clean run debug
