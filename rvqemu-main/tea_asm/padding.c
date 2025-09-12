#include "padding.h"
#include "stdint.h"

// =============================================================================
// Funciones de padding PKCS#7
// =============================================================================

uint32_t pkcs7_pad(const uint8_t* data, uint32_t data_len, uint8_t* padded_data) {
    // Calcular bytes de padding necesarios
    uint32_t padding_bytes = BLOCK_SIZE - (data_len % BLOCK_SIZE);
    if (padding_bytes == 0) {
        padding_bytes = BLOCK_SIZE;  // Si ya es múltiplo, agregar bloque completo
    }
    
    // Copiar datos originales
    for (uint32_t i = 0; i < data_len; i++) {
        padded_data[i] = data[i];
    }
    
    // Añadir bytes de padding
    for (uint32_t i = data_len; i < data_len + padding_bytes; i++) {
        padded_data[i] = (uint8_t)padding_bytes;
    }
    
    return data_len + padding_bytes;
}

uint32_t pkcs7_unpad(const uint8_t* padded_data, uint32_t padded_len, uint8_t* unpadded_data) {
    // Verificar que la longitud sea múltiplo del tamaño de bloque
    if (padded_len % BLOCK_SIZE != 0 || padded_len == 0) {
        return 0;  // Longitud inválida
    }
    
    // Obtener el último byte (valor de padding)
    uint8_t padding_value = padded_data[padded_len - 1];
    
    // Verificar que el valor de padding sea válido (1 a BLOCK_SIZE)
    if (padding_value == 0 || padding_value > BLOCK_SIZE) {
        return 0;  // Valor de padding inválido
    }
    
    // Verificar que todos los bytes de padding sean correctos
    for (uint32_t i = padded_len - padding_value; i < padded_len; i++) {
        if (padded_data[i] != padding_value) {
            return 0;  // Padding inconsistente
        }
    }
    
    // Calcular longitud sin padding
    uint32_t unpadded_len = padded_len - padding_value;
    
    // Copiar datos sin padding
    for (uint32_t i = 0; i < unpadded_len; i++) {
        unpadded_data[i] = padded_data[i];
    }
    
    return unpadded_len;
}

uint32_t calculate_padded_length(uint32_t data_len) {
    uint32_t padding_bytes = BLOCK_SIZE - (data_len % BLOCK_SIZE);
    if (padding_bytes == 0) {
        padding_bytes = BLOCK_SIZE;
    }
    return data_len + padding_bytes;
}

int is_valid_padding(const uint8_t* data, uint32_t data_len) {
    // Verificar longitud múltiplo de bloque
    if (data_len % BLOCK_SIZE != 0 || data_len == 0) {
        return 0;
    }
    
    uint8_t padding_value = data[data_len - 1];
    
    // Verificar rango válido
    if (padding_value == 0 || padding_value > BLOCK_SIZE) {
        return 0;
    }
    
    // Verificar bytes de padding
    for (uint32_t i = data_len - padding_value; i < data_len; i++) {
        if (data[i] != padding_value) {
            return 0;
        }
    }
    
    return 1;
}