/* 
    Definiciones necesarias: formato de salida, arquitectura y punto de entrada
*/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

/* 
    Definiciones de simbolos necesarios
*/

_RESET_VECTOR_VMA   = 0x00000000;
_BOOT_VMA           = 0x70010000;
_APP_VMA            = 0x70030000;
_STACK_VMA          = 0x70060000;
_DATA_VMA           = 0x81000000;
_BSS_VMA            = 0x82000000;

/* 
    Definición del mapa de memoria
    En este caso no definimos un largo, ya que vamos a ensamblar una tras otra
*/

/* 
    Definición de las secciones
*/

SECTIONS
{
    . =_BOOT_VMA; /* VMA */
    .boot : AT(_BOOT_VMA) /* LMA */
    {
        . = ALIGN(4);
        __boot_start__ = .;
        *(.boot*)
        __boot_end__ = .;
    }

    . =_APP_VMA; /* VMA */
    .text : AT( LOADADDR(.boot) + SIZEOF(.boot) ) /* LMA */
    { 
        . = ALIGN(4);
        __text_start__ = .;
        *(.text*) 
        __text_end__ = .;
    }
    __text_start_lma__ = LOADADDR(.text);

    . =_STACK_VMA; /* VMA */
    .stack : AT ( LOADADDR(.text) + SIZEOF(.text)) /* LMA */    
    {
        __stack_start_ = .;
        __stack_end_svc__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_svc__ = .;

        __stack_end_sys__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_sys__ = .;

        __stack_end_irq__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_irq__ = .;

        __stack_end_fiq__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_fiq__ = .;

        __stack_end_abort__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_abort__ = .;

        __stack_end_und__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_und__ = .;
        __stack_end_ = .;
    }

    . =_DATA_VMA; /* VMA */
    .data : AT( LOADADDR(.stack) + SIZEOF(.stack) ) /* LMA */
    {
        . = ALIGN(4);
        __data_start__ = .;
        *(.data*)
        __data_end__ = .;
    }

    __data_start_lma__ = LOADADDR(.data);

    . =_BSS_VMA; /* VMA */
    .bss : AT (LOADADDR(.data) + SIZEOF(.data)) /* LMA */    
    {
        . = ALIGN(4);
        __bss_start__ = .;
        . += 128K;
        __bss_end__ = .;
    }

    . =_RESET_VECTOR_VMA; /* VMA */
    .reset : AT( LOADADDR(.bss) + SIZEOF(.bss) ) /* LMA */
    {
        . = ALIGN(4);
        __reset_start__ = .;
        *(.reset*) 
        __reset_end__ = .;
    } 

    __reset_start_lma__ = LOADADDR(.reset);

}