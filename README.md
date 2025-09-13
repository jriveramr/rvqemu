# 🔐 Proyecto Individual: Implementación de Cifrado TEA (Tiny Encryption Algorithm) usando C y Ensamblador RISC-V en QEMU

Implementación del algoritmo **TEA (Tiny Encryption Algorithm)** en ensamblador **RISC-V**, 
integrado con un programa en **C** que maneja padding **PKCS#7** y pruebas de cifrado/descifrado.

## 🏗️ Arquitectura del Software

El proyecto se organiza en **capas separadas de C y ensamblador**, lo que permite mantener un diseño modular, portable y fácil de depurar.
---

### 📂 Estructura de directorios
- **Root**
  - `Dockerfile` → Entorno reproducible para compilar y ejecutar.
  - `run.sh`
    
- **`tea_asm/`** (código de bajo nivel en ensamblador con implementacion en C)
  - `build.sh`
  - `data.s` → Buffers y variables de estado.
  - `linker.ld` → Script de enlace.
  - `main.c` → Lógica principal en C (pruebas, UART, control de flujo)
  - `padding.h`, `padding.c` → Funciones de padding PKCS#7.
  - `run-qemu.sh`
  - `startup.s` → Rutinas de inicialización (stack, entorno bare-metal).
  - `stdint.h` → Tipos enteros estándar (compatibilidad C).
  - `tea.h` → Prototipos de funciones TEA exportadas a C.
  - `tea_encrypt_asm.s` → Implementación TEA (cifrado).
  - `tea_decrypt_asm.s` → Implementación TEA (descifrado).
.

---

### 🔀 Separación entre capas
- **Capa en C (alto nivel)**  
  Responsable de:
  - Interacción con el usuario.
  - Preparación de datos (ejemplo: aplicar padding PKCS#7).
  - Manejo de casos de prueba y validación de resultados.
  - Llamadas a funciones de cifrado/descifrado (en ASM).

- **Capa en ensamblador (bajo nivel)**  
  Responsable de:
  - Implementación eficiente del algoritmo TEA a nivel de instrucciones.
  - Uso directo de registros y operaciones aritméticas bit a bit.
  - Control del stack e inicialización mínima para ejecutar en bare-metal.
  - Definición de buffers y variables de estado.
---

### 📡 Interfaces utilizadas
La comunicación entre C y ensamblador se hace a través de qemu y gdb por medio de un contenedor de Ubuntu de Docker.

## ⚙️ Requisitos
Los requisitos son exactamente los mismos que en el repositorio del profesor:  
[Repositorio rvqemu en GitLab](https://gitlab.com/jgonzalez.tec/rvqemu/)

---

## 🚀 Compilación
Compilar el proyecto (ajustar rutas según entorno):
- Descargar el repositorio.
- Abrir Docker
- Abrir el terminal Ubuntu
- Navegar al directorio donde se encuentra el repositorio, nivel Root.
- chmod +x run.sh
- ./run.sh
- cd tea_asm
- chmod +x build.sh
- ./build.sh
- A partir de este punto, seguir las instrucciones que se muestran en terminal.
- Una vez iniciada la corrida, basta con usar los comandos mostrados en pantalla para asignar los breaks segun preferencia. Todo se muestra en pantalla.

Ejecucion
=== Sistema de Cifrado TEA con Padding ===
--- Caso 1: (8 bytes) ---
1. Cadena original: HOLA1234
Clave: 0x12345678 0x9ABCDEF0 0xFEDCBA98 0x76543210
2. Cadena cifrada (hex): BF 06 C0 66 0B F1 8F 95 ...
3. Cadena descifrada: HOLA1234

--- Caso 2: (n bytes) ---
1. Cadena original: Mensaje de prueba para TEA
Clave: 0x11223344 0x55667788 0x99AABBCC 0xDDEEFF00
2. Cadena cifrada (hex): A1 B2 C3 D4 ...
3. Cadena descifrada: Mensaje de prueba para TEA

## ✨ Funcionalidades implementadas

El sistema implementa un flujo completo de **cifrado y descifrado** usando el algoritmo TEA con padding PKCS#7.  
Las funcionalidades principales son:

1. **Inicialización del sistema**
   - Configuración del entorno bare-metal.
   - Definición de buffers y variables globales.
   - Preparación del stack y entorno para la ejecución en RISC-V.

2. **Entrada y salida por UART**
   - Funciones en C para imprimir caracteres, cadenas y valores en formato hexadecimal.
   - Comunicación básica con el usuario para mostrar resultados de pruebas.

3. **Manejo de cadenas de texto**
   - Cálculo seguro de longitud (`safe_strlen`).
   - Impresión de cadenas originales y claves utilizadas.

4. **Padding PKCS#7**
   - Implementado en `padding.c` / `padding.h`.
   - Añade bytes de relleno cuando la cadena no completa un múltiplo del bloque (8 bytes).
   - El padding asegura que todos los bloques sean válidos para TEA.
   - Se incluye también la funcionalidad de **unpadding** para restaurar la longitud original tras descifrar.

5. **Cifrado TEA (ensamblador)**
   - Función `tea_encrypt_asm` en `tea_encrypt_asm.s`.
   - Procesa bloques de 64 bits (8 bytes) usando una clave de 128 bits.
   - Implementación optimizada a nivel de instrucciones RISC-V.

6. **Descifrado TEA (ensamblador)**
   - Función `tea_decrypt_asm` en `tea_decrypt_asm.s`.
   - Recupera el bloque original a partir de los datos cifrados y la clave.

7. **Pruebas de validación**
   - **Caso 1:** cadena de 8 bytes (`"HOLA1234"`) para verificar cifrado básico con padding mínimo.  
   - **Caso 2:** cadena más larga (`"Mensaje de prueba para TEA"`) con múltiples bloques y padding.  
   - En cada caso se muestra:
     - Cadena original.
     - Clave utilizada.
     - Resultado cifrado en hexadecimal.
     - Cadena descifrada (tras aplicar unpadding).
   - Validación de integridad: se comprueba que la longitud original se recupera correctamente.

8. **Ejecución continua**
   - Tras completar las pruebas, el sistema entra en un bucle infinito (`while(1)` con `nop`) para evitar que el programa termine en entornos bare-metal.

## 📊 Discusión de Resultados

Los resultados obtenidos en las pruebas demuestran que la implementación cumple con los objetivos planteados:

- En el **Caso 1** (cadena de 8 bytes `"HOLA1234"`), el sistema aplicó padding correctamente, cifró el bloque mediante TEA y posteriormente lo descifró sin pérdida de información. La cadena recuperada fue idéntica a la original, lo cual valida la correcta interacción entre C y ensamblador.

- En el **Caso 2** (cadena más larga `"Mensaje de prueba para TEA"`), se verificó el procesamiento de múltiples bloques y la correcta aplicación de **padding PKCS#7**. El resultado descifrado coincidió con la cadena original, y además se recuperó exactamente la longitud inicial, confirmando que el padding no introduce errores residuales.

- En ambos casos, los datos cifrados impresos en **formato hexadecimal** muestran que el algoritmo transforma de manera efectiva la entrada en una secuencia aparentemente aleatoria, característica esencial de un cifrado robusto.

En general:
- La separación de responsabilidades (C para control y padding, ASM para el núcleo de TEA) facilitó la depuración y el análisis.  
- El flujo completo (entrada → padding → cifrado → descifrado → unpadding → salida) se ejecutó con éxito.  
- La validación de integridad asegura que no se pierde información y que el sistema puede usarse como base para cadenas de mayor tamaño o integrarse con otros módulos.

✅ En conclusión, los resultados confirman que la arquitectura propuesta es funcional y cumple con los requisitos del proyecto, logrando un cifrado y descifrado correctos con soporte de padding.


