SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

APP ?= ej7

CURRENT_DIR := $(shell pwd)
OBJ = obj
BIN = bin
INC = inc
SRC = src
LST = lst

MEMMAP_FILE = memmap.ld

SRCFILES = $(shell find $(SRC) -name '*.c' -o -name '*.s')
OBJFILES = $(patsubst $(SRC)/%, $(OBJ)/%, $(SRCFILES:.c=.o))
OBJFILES := $(patsubst $(SRC)/%, $(OBJ)/%, $(OBJFILES:.s=.o))

GDBINIT_LOCAL := .gdbinit
GDBINIT_GLOBAL_DIR := $(HOME)/.config/gdb
GDBINIT_GLOBAL := $(GDBINIT_GLOBAL_DIR)/gdbinit

BINFILE = $(APP).bin
TARGET = $(BIN)/$(BINFILE)
TARGET_ELF = $(OBJ)/$(APP).elf

CHAIN=arm-linux-gnueabihf
CFLAGS=-std=gnu99 -Wall -mcpu=cortex-a8
AFLAGS=--gdwarf-2
LDFLAGS=

VME=qemu-system-arm

BOARD=realview-pb-a8
PORT=1234
VMFLAGS= -M $(BOARD) -m 512M -no-reboot -nographic -monitor telnet:127.0.0.1:$(PORT),server,nowait
TCP_PORT=2159

CC=ddd
CCFLGS=--debugger

MSG_COMMIT ?= "Actualización desde Makefile"
REMOTE ?= origin
BRANCH ?= main

.PHONY: all clean rebuild run debug folder_tree help \
        git-init git-add git-commit git-push git-all \
        git-restore git-discard

all: $(TARGET) $(GDBINIT_LOCAL)
	@echo "Compilación finalizada. Listo para ejecutar o depurar."

$(TARGET): $(TARGET_ELF)
	@echo ""
	@echo "Generando binario..."
	$(CHAIN)-objcopy -O binary $< $@
	@echo "Binario generado en $(TARGET)"

$(TARGET_ELF): $(OBJFILES)| $(BIN) $(LST)
	@echo ""
	@echo "Linkeando ... "
	$(CHAIN)-ld -T $(MEMMAP_FILE) $(LDFLAGS) $^ -o $@ -Map $(LST)/$(APP).map
	@echo "Linkeo finalizado!!"
	@echo ""
	@echo "Generando archivos de información: mapa de memoria y simbolos"
	readelf -a $@  > $(LST)/$(APP)_readelf.txt
	$(CHAIN)-objdump -D $@  > $(LST)/$(APP).lst

$(OBJ)/%.o: $(SRC)/%.c | $(OBJ) $(LST)
	@echo ""
	mkdir -p $(dir $@)
	@echo "Compilando (C) $(notdir $<)..."
	$(CHAIN)-gcc $(CFLAGS) -g -c -O0 $< -o $@
	@echo "Ensamblado finalizado!!"

$(OBJ)/%.o: $(SRC)/%.s | $(OBJ) $(LST)
	@echo ""
	@echo "Compilando (ASM) $(notdir $<)..."
	$(CHAIN)-as $(AFLAGS) $< -g -o $@ -a > $(LST)/$(basename $(notdir $<)).lst
	@echo "Compilado finalizado!!"

$(OBJ) $(BIN) $(LST):
	mkdir -p $@

$(GDBINIT_LOCAL):
	@echo "creando .gdbinit local..."
	echo "target remote localhost:$(TCP_PORT)" > $(GDBINIT_LOCAL)
	@echo ""
	@echo "Anadiendo .gdbinit al path seguro..."
	mkdir -p $(GDBINIT_GLOBAL_DIR)
	echo "add-auto-load-safe-path $(CURRENT_DIR)/$(GDBINIT_LOCAL)" > $(GDBINIT_GLOBAL)
	@echo ""

clean:
	rm -rf $(OBJ) $(BIN) $(LST) $(GDBINIT_LOCAL)

rebuild: clean all

folder_tree:
	mkdir -p $(SRC) $(INC)
	@echo "Estructura de directorios creada."

run:
	$(VME) $(VMFLAGS) -S -gdb tcp::$(TCP_PORT) -kernel $(TARGET)

debug:
	$(CC) $(CCFLGS) gdb-multiarch $(TARGET_ELF)

dist: clean
	tar czf $(APP)-$(VERSION).tar.gz $(SRC) $(INC) Makefile README.md

git-init:
	git init
	@echo "Repositorio Git inicializado."

git-add:
	git add .
	@echo "Todos los cambios añadidos al área de staging."

git-commit:
	git commit -m $(MSG_COMMIT)
	@echo "Commit realizado con mensaje: $(MSG_COMMIT)"

git-push:
	git push $(REMOTE) $(BRANCH)
	@echo "Cambios enviados al remoto '$(REMOTE)' en la rama '$(BRANCH)'."

git-restore:
	git restore .

git-discard:
	git restore :/

git-all: git-add git-commit git-push
	@echo "Git: add → commit → push completado."
