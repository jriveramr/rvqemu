#ifndef TEA_H
#define TEA_H

#include "stdint.h"

// =============================================================================
// Declaraciones de funciones de ensamblador
// =============================================================================

/**
 * Función de cifrado TEA implementada en ensamblador RISC-V
 * @param block Puntero al bloque de 64 bits (2 words) a cifrar/descifrar
 * @param key Puntero a la clave de 128 bits (4 words)
 */
extern void tea_encrypt_asm(uint32_t* block, const uint32_t* key);

/**
 * Función de descifrado TEA implementada en ensamblador RISC-V  
 * @param block Puntero al bloque de 64 bits (2 words) a cifrar/descifrar
 * @param key Puntero a la clave de 128 bits (4 words)
 */
extern void tea_decrypt_asm(uint32_t* block, const uint32_t* key);

// =============================================================================
// Constantes TEA
// =============================================================================

#define TEA_BLOCK_SIZE 8      // 64 bits en bytes
#define TEA_KEY_SIZE 16       // 128 bits en bytes
#define TEA_DELTA 0x9E3779B9  // Constante delta
#define TEA_ROUNDS 32         // Número de rondas

// =============================================================================
// Estructuras para manejo de datos (opcional, para futura expansión)
// =============================================================================

typedef struct {
    uint32_t data[2];  // Bloque de 64 bits
} tea_block_t;

typedef struct {
    uint32_t key[4];   // Clave de 128 bits
} tea_key_t;

#endif /* TEA_H */