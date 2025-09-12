# =============================================================================
# startup.s - Punto de entrada mínimo para integración C-ASM
# Ahora solo inicializa el stack y llama a main() de C
# =============================================================================

.section .text
.globl _start

# --- Punto de Entrada ---
_start:
    # --- INICIALIZAR STACK (CRÍTICO) ---
    la sp, _stack_top
    
    # --- LLAMAR A MAIN() DE C ---
    call main
    
    # --- SI MAIN RETORNA (no debería), LOOP INFINITO ---
    j .

# =============================================================================
# Inclusión de archivos externos (SOLO funciones ASM, sin datos)
# =============================================================================
#.include "tea_encrypt_asm.s"
#.include "tea_decrypt_asm.s"

# =============================================================================
# Fin de startup.s
# =============================================================================