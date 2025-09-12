# 🔐 Proyecto TEA (Tiny Encryption Algorithm) en RISC-V

Implementación del algoritmo **TEA (Tiny Encryption Algorithm)** en ensamblador **RISC-V**, 
integrado con un programa en **C** que maneja padding **PKCS#7** y pruebas de cifrado/descifrado.

---

## 📂 Estructura del proyecto
- `main.c` → Programa principal en C (manejo de cadenas, padding, I/O por UART).
- `tea.s` → Implementación en ensamblador RISC-V del cifrado y descifrado TEA.
- `padding.c` / `padding.h` → Implementación del padding PKCS#7.
- `tea.h` → Prototipos de funciones TEA.

---

## ⚙️ Requisitos
- Compilador **RISC-V GCC** (ejemplo: `riscv64-unknown-elf-gcc`).
- Entorno de emulación, por ejemplo:
  - [cpulator](https://cpulator.01xz.net/)  
  - QEMU para RISC-V.

---

## 🚀 Compilación
Compilar el proyecto (ajustar rutas según entorno):

```bash
riscv64-unknown-elf-gcc -o tea main.c padding.c tea.s
