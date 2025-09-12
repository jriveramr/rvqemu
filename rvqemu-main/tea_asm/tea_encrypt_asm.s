# =============================================================================
# tea_encrypt_asm - Cifrado TEA en RISC-V Assembly
# Implementación modular optimizada para integración con C
# =============================================================================

.section .text
.globl tea_encrypt_asm

# =============================================================================
# tea_encrypt_asm - Función de cifrado TEA
# Parámetros: 
#   a0 = puntero a bloque (2 words - 64 bits) [v0, v1]
#   a1 = puntero a clave (4 words - 128 bits) [k0, k1, k2, k3]
# Convención RISC-V: Preserva registros s0-s11, ra
# =============================================================================

tea_encrypt_asm:
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
    
    # --- Cargar bloque a cifrar ---
    lw s0, 0(a0)    # s0 = v0 (parte baja del bloque)
    lw s1, 4(a0)    # s1 = v1 (parte alta del bloque)
    
    # --- Cargar clave de cifrado ---
    lw s2, 0(a1)    # s2 = k0
    lw s3, 4(a1)    # s3 = k1
    lw s4, 8(a1)    # s4 = k2
    lw s5, 12(a1)   # s5 = k3
    
    # --- Inicializar variables del algoritmo ---
    li s6, 0        # s6 = sum = 0
    li t0, 0x9E3779B9  # t0 = delta (constante TEA)
    li t1, 32       # t1 = contador de rondas (NUM_ROUNDS = 32)

# --- Bucle principal de cifrado (32 rondas) ---
tea_encrypt_loop:
    # sum += delta
    add s6, s6, t0
    
    # v0 += ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1)
    slli t2, s1, 4      # t2 = v1 << 4
    add t2, t2, s2      # t2 += k0
    add t3, s1, s6      # t3 = v1 + sum
    srli t4, s1, 5      # t4 = v1 >> 5
    add t4, t4, s3      # t4 += k1
    xor t5, t2, t3      # t5 = (v1<<4 + k0) ^ (v1 + sum)
    xor t5, t5, t4      # t5 ^= (v1>>5 + k1)
    add s0, s0, t5      # v0 += t5
    
    # v1 += ((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3)
    slli t2, s0, 4      # t2 = v0 << 4
    add t2, t2, s4      # t2 += k2
    add t3, s0, s6      # t3 = v0 + sum
    srli t4, s0, 5      # t4 = v0 >> 5
    add t4, t4, s5      # t4 += k3
    xor t5, t2, t3      # t5 = (v0<<4 + k2) ^ (v0 + sum)
    xor t5, t5, t4      # t5 ^= (v0>>5 + k3)
    add s1, s1, t5      # v1 += t5
    
    # --- Decrementar contador y verificar si continuar ---
    addi t1, t1, -1
    bnez t1, tea_encrypt_loop
    
    # --- Guardar resultado cifrado en memoria ---
    sw s0, 0(a0)    # Almacenar v0 cifrado
    sw s1, 4(a0)    # Almacenar v1 cifrado
    
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
# Fin de tea_encrypt_asm
# =============================================================================