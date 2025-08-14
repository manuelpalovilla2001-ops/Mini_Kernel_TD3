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
_TASK_01_VMA        = 0x70040000;
_TASK_02_VMA        = 0x70040000;
_STACK_VMA          = 0x70060000;
_DATA_01_VMA        = 0x700A0000;
_DATA_02_VMA        = 0x700A0000;
_DATA_VMA           = 0x81000000;
_BSS_01_VMA         = 0x70100000;
_BSS_02_VMA         = 0x70100000;
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
    .boot _BOOT_VMA : AT(_BOOT_VMA) /* LMA */
    {
        . = ALIGN(4);
        __boot_start__ = .;
        *(.boot*)
        __boot_end__ = .;
    }

    .text _APP_VMA : AT( LOADADDR(.boot) + SIZEOF(.boot) ) /* LMA */
    { 
        . = ALIGN(4);
        __text_start__ = .;
        *(.text*) 
        __text_end__ = .;
    }
    __text_start_lma__ = LOADADDR(.text);

    .text_01 _TASK_01_VMA : AT( LOADADDR(.text) + SIZEOF(.text) ) /* LMA */
    { 
        . = ALIGN(4);
        __task_01_start__ = .;
        *(.text_01*) 
        __task_01_end__ = .;
    }
    __task_01_start_lma__ = LOADADDR(.text_01);

    .text_02 _TASK_02_VMA : AT( LOADADDR(.text_01) + SIZEOF(.text_01) ) /* LMA */
    { 
        . = ALIGN(4);
        __task_02_start__ = .;
        *(.text_02*) 
        __task_02_end__ = .;
    }
    __task_02_start_lma__ = LOADADDR(.text);


    .stack _STACK_VMA : AT ( LOADADDR(.text_02) + SIZEOF(.text_02)) /* LMA */    
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

        __stack_end_task02__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_task02__ = .;

        __stack_end_task01__ = .;
        . += 4K;
        . = ALIGN(4);
        __stack_start_task01__ = .;
        __stack_end_ = .;
    }

    .data_01 _DATA_01_VMA : AT( LOADADDR(.stack) + SIZEOF(.stack) ) /* LMA */
    {
        . = ALIGN(4);
        __data_01_start__ = .;
        *(.data_01*)
        __data_01_end__ = .;
    }

    __data_01_start_lma__ = LOADADDR(.data_01);

    .data_02 _DATA_02_VMA : AT( LOADADDR(.data_01) + SIZEOF(.data_01) ) /* LMA */
    {
        . = ALIGN(4);
        __data_02_start__ = .;
        *(.data_02*)
        __data_02_end__ = .;
    }

    __data_02_start_lma__ = LOADADDR(.data_02);

    .data _DATA_VMA : AT( LOADADDR(.data_02) + SIZEOF(.data_02) ) /* LMA */
    {
        . = ALIGN(4);
        __data_start__ = .;
        *(.data*)
        __data_end__ = .;
    }

    __data_start_lma__ = LOADADDR(.data);

    .bss_01 _BSS_01_VMA : AT (LOADADDR(.data) + SIZEOF(.data)) /* LMA */    
    {
        . = ALIGN(4);
        __bss_01_start__ = .;
        . += 128K;
        __bss_01_end__ = .;
    }

    .bss_02 _BSS_02_VMA : AT (LOADADDR(.bss_01) + SIZEOF(.bss_01)) /* LMA */    
    {
        . = ALIGN(4);
        __bss_02_start__ = .;
        . += 128K;
        __bss_02_end__ = .;
    }

    .bss _BSS_VMA : AT (LOADADDR(.bss_02) + SIZEOF(.bss_02)) /* LMA */    
    {
        . = ALIGN(4);
        __bss_start__ = .;
        . += 128K;
        __bss_end__ = .;
    }

    .reset _RESET_VECTOR_VMA : AT( LOADADDR(.bss) + SIZEOF(.bss) ) /* LMA */
    {
        . = ALIGN(4);
        __reset_start__ = .;
        *(.reset*) 
        __reset_end__ = .;
    } 

    __reset_start_lma__ = LOADADDR(.reset);

}