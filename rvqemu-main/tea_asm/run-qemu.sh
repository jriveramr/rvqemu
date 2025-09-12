#!/bin/bash
# Run QEMU with GDB server for TEA encryption/decryption example
echo ""
echo "Inicializando QEMU con GDB servidor en puerto 1234..."
echo ""
echo "En otra terminal:"
echo "docker exec -it rvqemu /bin/bash"
echo "cd examples/tea_asm"
echo "gdb-multiarch tea_test.elf"
echo "Luego en GDB: target remote :1234"
echo ""
echo "Comandos GDB utiles para el debugging de TEA:"
echo "  break _start (opcional)"
echo "  break main             - Break inicial"
echo "  break tea_encrypt_asm  - Break antes de encriptar"  
echo "  break tea_decrypt_asm  - Break tras encriptar" 
echo "  continue" 
echo ""
echo "  x/2xw $a0       -Ver contenido del bloque en Risc-V" 
echo "  x/2xw &bloque1  -Ver contenido del bloque en C" 
qemu-system-riscv32 \
    -machine virt \
    -nographic \
    -bios none \
    -kernel tea_test.elf \
    -S \
    -gdb tcp::1234