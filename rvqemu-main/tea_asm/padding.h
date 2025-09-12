#ifndef PADDING_H
#define PADDING_H

#include "stdint.h"

// =============================================================================
// Constantes para padding
// =============================================================================
#define BLOCK_SIZE 8  // Tamaño de bloque TEA: 64 bits = 8 bytes

// =============================================================================
// Declaraciones de funciones de padding PKCS#7
// =============================================================================

/**
 * Aplica padding PKCS#7 a un buffer de datos
 * @param data Puntero a los datos de entrada
 * @param data_len Longitud actual de los datos en bytes
 * @param padded_data Puntero donde se almacenarán los datos con padding
 * @return Longitud total después del padding (múltiplo de BLOCK_SIZE)
 */
uint32_t pkcs7_pad(const uint8_t* data, uint32_t data_len, uint8_t* padded_data);

/**
 * Remueve padding PKCS#7 de un buffer de datos
 * @param padded_data Puntero a los datos con padding
 * @param padded_len Longitud de los datos con padding en bytes
 * @param unpadded_data Puntero donde se almacenarán los datos sin padding
 * @return Longitud de los datos originales sin padding, o 0 si el padding es inválido
 */
uint32_t pkcs7_unpad(const uint8_t* padded_data, uint32_t padded_len, uint8_t* unpadded_data);

/**
 * Calcula el tamaño necesario después de aplicar padding PKCS#7
 * @param data_len Longitud original de los datos en bytes
 * @return Longitud total requerida después del padding
 */
uint32_t calculate_padded_length(uint32_t data_len);

/**
 * Verifica si el padding PKCS#7 es válido
 * @param data Puntero a los datos con padding
 * @param data_len Longitud de los datos con padding en bytes
 * @return 1 si el padding es válido, 0 si es inválido
 */
int is_valid_padding(const uint8_t* data, uint32_t data_len);

#endif /* PADDING_H */