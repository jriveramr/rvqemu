/* =============================================================================
 * linker.ld - Script de enlazado para proyecto TEA modular RISC-V
 * Define la disposición de memoria para múltiples archivos ensamblador
 * =============================================================================
 */

ENTRY(_start)  /* Punto de entrada definido en startup.s */

/* Definición de la memoria del sistema QEMU virt */
MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128K  /* Memoria principal */
}

SECTIONS {
    /* =========================================================================
     * Sección de código (.text) - Dirección de inicio 0x80000000
     * ========================================================================= */
    . = 0x80000000;    /* QEMU virt machine reset vector */
    
    .text : {
        /* Asegurar que startup.s va primero (contiene _start) */
        *startup.o(.text*)
        
        /* Luego el resto del código en cualquier orden */
        *(.text*)
        
        /* Mantener las funciones en el orden apropiado */
        KEEP(*(.text.tea_encrypt_asm))
        KEEP(*(.text.tea_decrypt_asm))
    } > RAM

    /* =========================================================================
     * Sección de datos inicializados (.data)
     * ========================================================================= */
    .data : {
        /* Asegurar que data.s se procese temprano para variables globales */
        *data.o(.data*)
        
        /* Resto de datos */
        *(.data*)
        *(.sdata*)
    } > RAM

    /* =========================================================================
     * Sección de datos de solo lectura (.rodata)
     * ========================================================================= */
    .rodata : {
        *(.rodata*)
        *(.rodata.*)
    } > RAM

    /* =========================================================================
     * Sección BSS - Variables no inicializadas (.bss)
     * ========================================================================= */
    .bss : {
        /* Stack space definido en data.s */
        *data.o(.bss*)
        
        /* Resto de BSS */
        *(.bss*)
        *(.sbss*)
        
        /* Asegurar alineación para stack */
        . = ALIGN(8);
    } > RAM

    /* =========================================================================
     * Stack configuration - CRÍTICO para funciones
     * ========================================================================= */
    . = ALIGN(8);
    _stack_bottom = .;     /* Base del stack (definido en data.s) */
    _stack_top = . + 0x1000;  /* 4KB stack (crece hacia abajo) */

    /* =========================================================================
     * Symbolos para debugging y referencia
     * ========================================================================= */
    /* Direcciones de las funciones TEA para debugging */
    _tea_encrypt_start = ADDR(.text) + SIZEOF(.text) - 0x100;
    _tea_decrypt_start = ADDR(.text) + SIZEOF(.text) - 0x200;
    
    /* Direcciones de datos importantes */
    _data_start = ADDR(.data);
    _data_end = ADDR(.data) + SIZEOF(.data);
    _bss_start = ADDR(.bss);
    _bss_end = ADDR(.bss) + SIZEOF(.bss);
    
    /* Punto final del programa */
    _end = .;
    
    /* =========================================================================
     * Información de depuración (para GDB)
     * ========================================================================= */
    .debug_info 0 : { *(.debug_info) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_aranges 0 : { *(.debug_aranges) }
    .debug_line 0 : { *(.debug_line) }
    .debug_str 0 : { *(.debug_str) }
    .debug_frame 0 : { *(.debug_frame) }
    .debug_loc 0 : { *(.debug_loc) }
}

/* =============================================================================
 * Reglas de asignación para archivos específicos
 * ============================================================================= */
/* Asegurar que startup.o se enlace primero */
PROVIDE(_start = DEFINED(_start) ? _start : 0x80000000);

/* Symbolos para el stack */
PROVIDE(__stack_bottom = _stack_bottom);
PROVIDE(__stack_top = _stack_top);
PROVIDE(__stack_size = _stack_top - _stack_bottom);