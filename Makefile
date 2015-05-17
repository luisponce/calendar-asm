EXECUTABLE=calendar # nombre del ejecutable a generar

## CONFIG:
NASM=nasm 	# por defecto en /usr/bin/nasm
LD=ld		# por defecto en /usr/bin/ld
FORMAT=elf  # formato de ensamblado; vea: `$nasm -hf`
ARCH=x86_64 # arquitectura de ensamblado
EMULATOR=elf_i386 # emulador de linkeado

# Folder donde se guardan los binarios
BIN=bin

## ARGS:
LD_ARGS=-m $(EMULATOR) -o $(EXECUTABLE) -A $(ARCH)
NASM_ARGS=-f $(FORMAT)

all: assembly copy

assembly: calendar.o
	$(LD) $(LD_ARGS) calendar.o

calendar.o: calendar.asm
	$(NASM) $(NASM_ARGS) calendar.asm

copy: 
	@if [ ! -d $(BIN) ]; \
		then \
		mkdir $(BIN); \
	fi;
		
	@mv *.o $(BIN)
	@mv $(EXECUTABLE) $(BIN)
	@echo "DONE"
	@echo "Para ejecutar:"
	@echo " :: > $(BIN)/$(EXECUTABLE)"

clean:
	rm -rf $(BIN)
	rm -f *o
	rm -f $(EXECUTABLE)
	@echo "DONE"

