// =============================================================================
// main.c - Programa principal para sistema de cifrado TEA
// Integración C con funciones en ensamblador RISC-V
// =============================================================================

#include "stdint.h"
#include "tea.h"
#include "padding.h"

// =============================================================================
// Funciones básicas de I/O (para bare-metal RISC-V)
// =============================================================================

#define UART_BASE 0x10000000

void print_char(char c) {
    volatile char *uart = (volatile char*)UART_BASE;
    *uart = c;
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_hex(uint32_t value) {
    const char hex_digits[] = "0123456789ABCDEF";
    print_char('0');
    print_char('x');
    for (int i = 7; i >= 0; i--) {
        uint8_t nibble = (value >> (i * 4)) & 0xF;
        print_char(hex_digits[nibble]);
    }
}

void print_hex_data(const uint8_t* data, uint32_t len) {
    for (uint32_t i = 0; i < len; i++) {
        if (i > 0 && i % 8 == 0) print_string("\n        ");
        print_hex(data[i]);
        print_string(" ");
    }
}

uint32_t safe_strlen(const char* str) {
    uint32_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

// =============================================================================
// Función principal con padding implementado
// =============================================================================

void main() {
    print_string("\n=== Sistema de Cifrado TEA con Padding ===\n");
    
    // =========================================================================
    // CASO 1: Cadena corta que necesita padding
    // =========================================================================
    print_string("\n--- Caso 1: (8 bytes)---\n");
    
    uint8_t cadena1[] = "HOLA1234";  //8 bytes
    uint32_t clave1[] = {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210};

    print_string("1. Cadena original: ");
    print_string((char*)cadena1);
    print_string("\nClave: ");
    for (int i = 0; i < 4; i++) {
        print_hex(clave1[i]);
        print_string(" ");
    }

    // Aplicar padding
    uint8_t padded1[BLOCK_SIZE];
    uint32_t padded_len1 = pkcs7_pad(cadena1, 8, padded1);
    
    // Cifrar cada bloque (en este caso solo 1 bloque)
    uint32_t* bloque1 = (uint32_t*)padded1;
    
    //Cifrado
    tea_encrypt_asm(bloque1, clave1);
    
    print_string("\n2. Cadena cifrada:\n");
    for (uint32_t i = 0; i < padded_len1; i++) {
    const char hex_digits[] = "0123456789ABCDEF";
    uint8_t val = padded1[i];
    print_char(hex_digits[(val >> 4) & 0xF]);
    print_char(hex_digits[val & 0xF]);
    print_char(' ');
    if ((i + 1) % 8 == 0) print_string("| ");
}
    
    //Descifrado
    tea_decrypt_asm(bloque1, clave1);
    
    // Remover padding
    uint8_t unpadded1[BLOCK_SIZE];
    uint32_t unpadded_len1 = pkcs7_unpad(padded1, padded_len1, unpadded1);
    unpadded1[unpadded_len1] = '\0';

    print_string("\n3. Cadena descifrada: ");
    print_string((char*)unpadded1);
    print_string("\n");
    // =========================================================================
    // CASO 2: Cadena que ocupa exactamente un bloque
    // =========================================================================
    print_string("\n--- Caso 2: (n bytes) ---\n");
    
    uint8_t cadena2[] = "Mensaje de prueba para TEA";  // longitud variable con padding
    uint32_t clave2[] = {0x11223344, 0x55667788, 0x99AABBCC, 0xDDEEFF00};

    print_string("1. Cadena original: ");
    print_string((char*)cadena2);
    print_string("\nClave: ");
    for (int i = 0; i < 4; i++) {
        print_hex(clave2[i]);
        print_string(" ");
    }

    print_string("\n\n A partir de este punto la cantidad de breaks dependerá de");
    print_string("\n la longitud de cadena ingresada.");
    print_string("\n (8 breaks en total para caso inicial)\n");

    uint32_t original_len2 = safe_strlen((char*)cadena2);
    uint8_t padded2[BLOCK_SIZE * 4]; // por seguridad, hasta 4 bloques
    uint32_t padded_len2 = pkcs7_pad(cadena2, original_len2, padded2);
    

    // --- Cifrado bloque por bloque ---
    for (uint32_t i = 0; i < padded_len2; i += BLOCK_SIZE) {
        tea_encrypt_asm((uint32_t*)(padded2 + i), clave2);
    }

    // --- Imprimir en hex legible ---
    print_string("\n2. Cadena cifrada:\n");
    for (uint32_t i = 0; i < padded_len2; i++) {
        const char hex_digits[] = "0123456789ABCDEF";
        uint8_t val = padded2[i];
        print_char(hex_digits[(val >> 4) & 0xF]);
        print_char(hex_digits[val & 0xF]);
        print_char(' ');
        if ((i + 1) % 8 == 0) print_string("| ");
    }

    // --- Descifrado bloque por bloque ---
    for (uint32_t i = 0; i < padded_len2; i += BLOCK_SIZE) {
        tea_decrypt_asm((uint32_t*)(padded2 + i), clave2);
    }

    uint8_t unpadded2[BLOCK_SIZE * 4];
    uint32_t unpadded_len2 = pkcs7_unpad(padded2, padded_len2, unpadded2);
    unpadded2[unpadded_len2] = '\0';

    print_string("\n\n3. Cadena descifrada: ");
    print_string((char*)unpadded2);
    print_string("\n");

    // Verificar integridad
    if (unpadded_len2 == original_len2) {
        print_string("\n✓ Longitud original recuperada correctamente\n");
    } else {
        print_string("\n✗ Error en la recuperación de longitud\n");
    }
    
    // =========================================================================
    // Resultados finales
    // =========================================================================
    print_string("=== Pruebas de padding completadas ===\n");
    
    while (1) {
        asm volatile ("nop");
    }
}