# =============================================================================
# tea_decrypt_asm - Descifrado TEA en RISC-V Assembly  
# Implementación modular optimizada para integración con C
# =============================================================================

.section .text
.globl tea_decrypt_asm

# =============================================================================
# tea_decrypt_asm - Función de descifrado TEA
# Parámetros:
#   a0 = puntero a bloque cifrado (2 words - 64 bits) [v0, v1]
#   a1 = puntero a clave (4 words - 128 bits) [k0, k1, k2, k3]
# Convención RISC-V: Preserva registros s0-s11, ra
# =============================================================================

tea_decrypt_asm:
    # --- Preservar registros (convención RISC-V) ---
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)
    
    # --- Cargar bloque a descifrar ---
    lw s0, 0(a0)    # s0 = v0 (parte baja del bloque cifrado)
    lw s1, 4(a0)    # s1 = v1 (parte alta del bloque cifrado)
    
    # --- Cargar clave de descifrado ---
    lw s2, 0(a1)    # s2 = k0
    lw s3, 4(a1)    # s3 = k1
    lw s4, 8(a1)    # s4 = k2
    lw s5, 12(a1)   # s5 = k3
    
    # --- Inicializar sum = delta * 32 ---
    li s6, 0x9E3779B9  # s6 = delta
    slli s6, s6, 5     # delta * 32 = 0xC6EF3720
    li t1, 32          # t1 = contador de rondas (NUM_ROUNDS = 32)

# --- Bucle principal de descifrado (32 rondas) ---
tea_decrypt_loop:
    # v1 -= ((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3)
    slli t2, s0, 4      # t2 = v0 << 4
    add t2, t2, s4      # t2 += k2
    add t3, s0, s6      # t3 = v0 + sum
    srli t4, s0, 5      # t4 = v0 >> 5
    add t4, t4, s5      # t4 += k3
    xor t5, t2, t3      # t5 = (v0<<4 + k2) ^ (v0 + sum)
    xor t5, t5, t4      # t5 ^= (v0>>5 + k3)
    sub s1, s1, t5      # v1 -= t5
    
    # v0 -= ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1)
    slli t2, s1, 4      # t2 = v1 << 4
    add t2, t2, s2      # t2 += k0
    add t3, s1, s6      # t3 = v1 + sum
    srli t4, s1, 5      # t4 = v1 >> 5
    add t4, t4, s3      # t4 += k1
    xor t5, t2, t3      # t5 = (v1<<4 + k0) ^ (v1 + sum)
    xor t5, t5, t4      # t5 ^= (v1>>5 + k1)
    sub s0, s0, t5      # v0 -= t5
    
    # sum -= delta
    li t0, 0x9E3779B9   # t0 = delta
    sub s6, s6, t0      # sum -= delta
    
    # --- Decrementar contador y verificar si continuar ---
    addi t1, t1, -1
    bnez t1, tea_decrypt_loop
    
    # --- Guardar resultado descifrado en memoria ---
    sw s0, 0(a0)    # Almacenar v0 descifrado
    sw s1, 4(a0)    # Almacenar v1 descifrado
    
    # --- Restaurar registros y retornar ---
    lw s6, 0(sp)
    lw s5, 4(sp)
    lw s4, 8(sp)
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

# =============================================================================
# Fin de tea_decrypt_asm
# =============================================================================