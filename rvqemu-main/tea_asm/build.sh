#!/usr/bin/bash
# Build script for TEA encryption/decryption example with C integration
echo ""
echo "Building TEA C+ASM..."
echo ""
# Compilar todos los archivos por separado
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g -c main.c -o main.o
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g -c padding.c -o padding.o
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g -c startup.s -o startup.o
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g -c tea_encrypt_asm.s -o tea_encrypt_asm.o
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g -c tea_decrypt_asm.s -o tea_decrypt_asm.o
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g -c data.s -o data.o

# Enlazar todos los objetos juntos
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g \
    main.o padding.o startup.o tea_encrypt_asm.o tea_decrypt_asm.o data.o \
    -T linker.ld \
    -o tea_test.elf

# Verificar si el build fue exitoso
if [ $? -eq 0 ]; then
    echo ""
    echo "Build exitosa: tea_test.elf creado"
    echo ""
    echo "Para correr y debuggear:"
    echo "chmod +x run-qemu.sh"
    echo "./run-qemu.sh"
    echo ""
else
    echo "Build fallida"
    exit 1
fi

# Opcional: Limpiar archivos objeto (descomentar si se desea)
# rm -f *.o