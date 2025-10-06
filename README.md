Mini Kernel diseñado para la materia Técnicas Digitales III.
---
Este proyecto implementa un mini kernel en lenguaje ensamblador ARM, diseñado para correr sobre un procesador ARMv7-A.  
El propósito es comprender y demostrar el funcionamiento básico de un sistema operativo a bajo nivel, utilizando manejo de memoria, inicialización del sistema, excepciones, interrupciones, multitarea y planificación (scheduling).

El programa cuenta con:  
- Inicialización del procesador y stacks.
- Copia las secciones .text, .data, .bss, y las tareas (task_01, task_02, etc.) desde memoria física a sus direcciones virtuales definidas.
- Inicialización de la MMU y paginación.
- Configuración del GIC y del Timer.
- Manejo de interrupciones y excepciones.
- Scheduler con manejo de PCB (Process Control Block).
  - Se realiza context switching completo: guarda y restaura registros, LR, SP, SPSR y tablas de traducción.
