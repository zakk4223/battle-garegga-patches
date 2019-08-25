#!/bin/sh

asl patch.s -i . -n -U -o garegga.o
p2bin garegga.o garegga.bin
/Users/zakk/rom_split.rb garegga.bin prg0.bin prg1.bin
cp prg0.bin /Users/zakk/roms/bgaregga
cp prg1.bin /Users/zakk/roms/bgaregga
