chal.rom: asm/* chal/*
	./asm/assemble.py ./chal/main.s ./chal.rom

emu/emu: emu/*.cpp
	$(MAKE) -C emu

run: chal.rom emu/emu
	./emu/emu ./chal.rom
