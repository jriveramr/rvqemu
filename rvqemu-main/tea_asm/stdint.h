#ifndef STDINT_H
#define STDINT_H

/* Tipos enteros sin signo */
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

/* Tipos enteros con signo */
typedef signed char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;

/* Punteros a funciones */
typedef void* void_ptr;
typedef int32_t* int_ptr;

#endif /* STDINT_H */