# =============================================================================
# data.s - Stack y buffers para integración C-ASM
# AHORA solo contiene espacio para stack y buffers, NO datos de prueba
# =============================================================================

.section .bss

# =============================================================================
# Stack space (4KB) - ESENCIAL para funciones C y ASM
# =============================================================================
.align 4
_stack_bottom:
    .space 4096       # 4KB de espacio para stack
_stack_top:           # Top del stack (crece hacia abajo)

# =============================================================================
# Buffers para comunicación entre C y ASM
# =============================================================================
.align 4
_tea_buffer_in:
    .space 8          # Buffer de entrada para TEA (64 bits)

.align 4  
_tea_buffer_out:
    .space 8          # Buffer de salida para TEA (64 bits)

.align 4
_tea_key_buffer:
    .space 16         # Buffer para clave TEA (128 bits)

# =============================================================================
# Variables de estado (opcionales, para debugging)
# =============================================================================
.align 4
_tea_encrypt_count:
    .space 4          # Contador de operaciones de cifrado

.align 4
_tea_decrypt_count:
    .space 4          # Contador de operaciones de descifrado