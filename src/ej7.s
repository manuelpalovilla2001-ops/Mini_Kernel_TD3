.extern __boot_start__
.extern __boot_end__

.extern __text_start__
.extern __text_end__
.extern __text_start_lma__

.extern __task_01_start__
.extern __task_01_end__
.extern __task_01_start_lma__

.extern __task_02_start__
.extern __task_02_end__
.extern __task_02_start_lma__

.extern __stack_start_svc__
.extern __stack_end_svc__

.extern __stack_start_sys__
.extern __stack_end_sys__

.extern __stack_end_irq__
.extern __stack_start_irq__

.extern __stack_end_und__
.extern __stack_start_und__

.extern __stack_end_fiq__
.extern __stack_start_fiq__

.extern __stack_end_abort__
.extern __stack_start_abort__

.extern __stack_end_task01__
.extern __stack_start_task01__

.extern __stack_end_task02__
.extern __stack_start_task02__

.extern __data_01_start__
.extern __data_01_end__
.extern __data_01_start_lma__

.extern __data_02_start__
.extern __data_02_end__
.extern __data_02_start_lma__

.extern __data_start__
.extern __data_end__
.extern __data_start_lma__

.extern __bss_01_start__
.extern __bss_01_end__

.extern __bss_02_start__
.extern __bss_02_end__

.extern __bss_start__
.extern __bss_end__

.extern __reset_start__
.extern __reset_end__
.extern __reset_start_lma__

.extern __stack_start_svc__
.extern __stack_start_sys__
.extern __stack_start_irq__
.extern __stack_start_fiq__
.extern __stack_start_abort__
.extern __stack_start_und__
.extern __stack_end_
.extern __stack_start_
.global _start
.extern _task_01
.extern _task_02

/***********Modo del Core (Excepciones)************/
.equ MODE_SVC    , 0b10011
.equ MODE_SYS    , 0b11111
.equ MODE_IRQ    , 0b10010
.equ MODE_FIQ    , 0b10001
.equ MODE_ABORT  , 0b10111
.equ MODE_UND    , 0b11011
/**************************************************/

/***********Direcciones de registros GIC***********/
.equ GICC0_ADDR, 0x1E000000
.equ GICD0_ADDR, 0x1E001000
.equ GICC1_ADDR, 0x1E010000
.equ GICD1_ADDR, 0x1E011000
.equ GICC2_ADDR, 0x1E020000
.equ GICD2_ADDR, 0x1E021000
.equ GICC3_ADDR, 0x1E030000
.equ GICD3_ADDR, 0x1E031000
/**************************************************/

/***********Paginacion*****************************/
.equ L1_TABLE_BASE            , 0x82000000
.equ L1_TABLE_BASE_01         , 0x82004000
.equ L1_TABLE_BASE_02         , 0x82008000
.equ L2_TABLE_BASE_01         , L1_TABLE_BASE_02 + 0x4000       /* 0x000 RV */
.equ L2_TABLE_BASE_02         , L2_TABLE_BASE_01 + 0x400        /* 0x700 KERNEL */
.equ L2_TABLE_BASE_03         , L2_TABLE_BASE_02 + 0x400        /* 0x700 TASK_DATA01*/
.equ L2_TABLE_BASE_04         , L2_TABLE_BASE_03 + 0x400        /* 0x701 BSS01*/
.equ L2_TABLE_BASE_05         , L2_TABLE_BASE_04 + 0x400        /* 0x700 TASK_DATA02*/
.equ L2_TABLE_BASE_06         , L2_TABLE_BASE_05 + 0x400        /* 0x701 BSS02*/
.equ L2_TABLE_BASE_07         , L2_TABLE_BASE_06 + 0x400        /* 0x810 KERNEL */
.equ L2_TABLE_BASE_08         , L2_TABLE_BASE_07 + 0x400        /* 0x820 KERNEL */
.equ L2_TABLE_BASE_TIMER      , L2_TABLE_BASE_08 + 0x400        /* 0x100 KERNEL */
.equ L2_TABLE_BASE_GIC        , L2_TABLE_BASE_TIMER + 0x400     /* 0x1E0 KERNEL */
.equ LONG_TABLES              , (L2_TABLE_BASE_GIC + 0x400) - L1_TABLE_BASE
/***********Traducciones Kernel********************/
.equ DIR_FISICA_RV            , 0x00000000 /* 0x000 00 000 */
.equ DIR_FISICA_BOOT          , 0x70010000 /* 0x700 10 000 */
.equ DIR_FISICA_APP           , 0x70030000 /* 0x700 30 000 */
.equ DIR_FISICA_STACK         , 0x80100000 /* 0x700 60 000 */
.equ DIR_FISICA_DATA          , 0x81000000 /* 0x810 00 000 */
.equ DIR_FISICA_BSS           , 0x82000000 /* 0x820 00 000 */ /*128K*/
.equ DIR_FISICA_TIMER_BASE    , 0x10011000
.equ DIR_FISICA_TIMER_END     , 0x1001A000
.equ DIR_FISICA_GIC_BASE      , 0x1E000000
.equ DIR_FISICA_GIC_END       , 0x1E020000
/***********Traducciones Tareas********************/
.equ DIR_FISICA_TASK_01       , 0x80010000 /* 0x700 40 000 */
.equ DIR_FISICA_TASK_02       , 0x80020000 /* 0x700 40 000 */
.equ DIR_FISICA_DATA_01       , 0x80200000 /* 0x700 A0 000 */
.equ DIR_FISICA_DATA_02       , 0x80210000 /* 0x700 A0 000 */
.equ DIR_FISICA_BSS_01        , 0x80300000 /* 0x701 00 000 */
.equ DIR_FISICA_BSS_02        , 0x80310000 /* 0x701 00 000 */
/**************************************************/
.equ TIMER_BASE_01  , 0x10011000 /* interrupt ID #36 */
.equ TIMER_BASE_23  , 0x10012000 /* interrupt ID #37 */
.equ TIMER_BASE_45  , 0x10018000 /* interrupt ID #73 */
.equ TIMER_BASE_67  , 0x10019000 /* interrupt ID #74 */
/***********Defines********************************/
.equ INV    ,     0x494E56
.equ MEM    ,     0x4D454D
.equ CPSR_INIT          ,     0x60000153
/**************************************************/
.code 32
.section .data
cont_timer: .word 0

pcb_task1:                          /* PCB */
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
    .word _task_01                  /* PC */
    .word 0                         /* LR */
    .word __stack_start_task01__    /* SP */
    .word 1                         /* ASID */
    .word CPSR_INIT                 /* CPSR */
    .word L1_TABLE_BASE_01          /* TTBR */

pcb_task2:                          /* PCB */
    .word 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9
    .word _task_02                  /* PC */
    .word 0                         /* LR */
    .word __stack_start_task02__    /* SP */
    .word 2                         /* ASID */
    .word CPSR_INIT                 /* CPSR */
    .word L1_TABLE_BASE_02          /* TTBR */

pcb_task3:                          /* PCB */
    .word 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10
    .word _task_03                  /* PC */
    .word 0                         /* LR */
    .word __stack_start_svc__       /* SP */
    .word 3                         /* ASID */
    .word CPSR_INIT                 /* CPSR */
    .word L1_TABLE_BASE             /* TTBR */

.code 32
.section .boot,"ax"@progbits

_start:
      MSR CPSR_c, #MODE_SVC
      LDR SP, =__stack_start_svc__

      MSR CPSR_c, #MODE_SYS
      LDR SP, =__stack_start_sys__

      MSR CPSR_c, #MODE_IRQ
      LDR SP, =__stack_start_irq__

      MSR CPSR_c, #MODE_FIQ
      LDR SP, =__stack_start_fiq__

      MSR CPSR_c, #MODE_ABORT
      LDR SP, =__stack_start_abort__

      MSR CPSR_c, #MODE_UND
      LDR SP, =__stack_start_und__

      CPSID aif, #MODE_SVC         /* Volver al modo SVC para continuar en _start */

      LDR R0,=__text_start_lma__
      LDR R1,=__text_start__
      LDR R2,=__text_end__
      LDR R3,=DIR_FISICA_APP
      SUB R2, R2, R1                /* Tamaño de la section */
      LSR R2, R2, #2                /* Cantidad de words a copiar */
      BL loop_copy

      LDR R0,=__task_01_start_lma__
      LDR R1,=__task_01_start__
      LDR R2,=__task_01_end__
      LDR R3,=DIR_FISICA_TASK_01
      SUB R2, R2, R1
      LSR R2, R2, #2
      BL loop_copy

      LDR R0,=__task_02_start_lma__
      LDR R1,=__task_02_start__
      LDR R2,=__task_02_end__
      LDR R3,=DIR_FISICA_TASK_02
      SUB R2, R2, R1
      LSR R2, R2, #2
      BL loop_copy

      LDR R0,=__reset_start_lma__
      LDR R1,=__reset_start__
      LDR R2,=__reset_end__
      LDR R3,=DIR_FISICA_RV
      SUB R2, R2, R1
      LSR R2, R2, #2
      BL loop_copy

      LDR R0,=__data_01_start_lma__
      LDR R1,=__data_01_start__
      LDR R2,=__data_01_end__
      LDR R3,=DIR_FISICA_DATA_01
      SUB R2, R2, R1
      LSR R2, R2, #2
      BL loop_copy

      LDR R0,=__data_02_start_lma__
      LDR R1,=__data_02_start__
      LDR R2,=__data_02_end__
      LDR R3,=DIR_FISICA_DATA_02
      SUB R2, R2, R1
      LSR R2, R2, #2
      BL loop_copy

      LDR R0,=__data_start_lma__
      LDR R1,=__data_start__
      LDR R2,=__data_end__
      LDR R3,=DIR_FISICA_DATA
      SUB R2, R2, R1
      LSR R2, R2, #2
      BL loop_copy
      
      BL _pag_init

      LDR R0, =L1_TABLE_BASE        /* Cargar TTBR0 con dirección base */
      MCR p15, 0, R0, c2, c0, 0     /* Escribir en TTBR0 */

      LDR R0, =0x55555555
      MCR p15, 0, R0, c3, c0, 0     /* Escribir en DACR */

      MRC p15, 0, R1, c1, c0, 0     /* Leer el SCTLR */
      ORR R1, R1, #0x1              /* Habilitar MMU */
      MCR p15, 0, R1, c1, c0, 0     /* Escribir de nuevo SCTLR */

      BL _timer0_init

      BL _gic_init

      CPSIE i

      B _main

_pag_init:
      MOV R7, LR
      LDR R2, =LONG_TABLES
      LDR R3, =L1_TABLE_BASE
      MOV R0, #0

loop_clear:
      STRB R0, [R3], #1
      SUBS R2, #1
      BNE loop_clear

      /***********Traducciones Kernel********************/
      LDR R0, =L1_TABLE_BASE + 0x000*4 /* RV */
      LDR R1, =L2_TABLE_BASE_01 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x700*4 /* BOOT, APP, STACK */
      LDR R1, =L2_TABLE_BASE_02 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x810*4 /* DATA */
      LDR R1, =L2_TABLE_BASE_07 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x820*4 /* BSS */
      LDR R1, =L2_TABLE_BASE_08 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x100*4 /* TIMER */
      LDR R1, =L2_TABLE_BASE_TIMER + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x1E0*4 /* GIC */
      LDR R1, =L2_TABLE_BASE_GIC + 1
      STR R1, [R0]

      /***********Traducciones Tarea1********************/
      LDR R0, =L1_TABLE_BASE_01 + 0x000*4 /* RV */
      LDR R1, =L2_TABLE_BASE_01 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_01 + 0x810*4 /* DATA */
      LDR R1, =L2_TABLE_BASE_07 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_01 + 0x700*4 /* TASK01, DATA01, APP */
      LDR R1, =L2_TABLE_BASE_03 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_01 + 0x820*4 /* BSS */
      LDR R1, =L2_TABLE_BASE_08 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_01 + 0x100*4 /* TIMER */
      LDR R1, =L2_TABLE_BASE_TIMER + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_01 + 0x1E0*4 /* GIC */
      LDR R1, =L2_TABLE_BASE_GIC + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_01 + 0x701*4 /* BSS01 */
      LDR R1, =L2_TABLE_BASE_04 + 1
      STR R1, [R0]

      /***********Traducciones Tarea2********************/
      LDR R0, =L1_TABLE_BASE_02 + 0x000*4 /* RV */
      LDR R1, =L2_TABLE_BASE_01 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_02 + 0x810*4 /* DATA */
      LDR R1, =L2_TABLE_BASE_07 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_02 + 0x700*4 /* TASK02, DATA02, APP , STACK*/
      LDR R1, =L2_TABLE_BASE_05 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_02 + 0x820*4 /* BSS */
      LDR R1, =L2_TABLE_BASE_08 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_02 + 0x100*4 /* TIMER */
      LDR R1, =L2_TABLE_BASE_TIMER + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_02 + 0x1E0*4 /* GIC */
      LDR R1, =L2_TABLE_BASE_GIC + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE_02 + 0x701*4 /* BSS02 */
      LDR R1, =L2_TABLE_BASE_06 + 1
      STR R1, [R0]
      /**************************************************/
      LDR R3, =__reset_end__
      LDR R1, =__reset_start__
      SUB R3, R3, R1          /* R3 = size */
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12         /* R3 = numero de paginas */

      LDR R0, =L2_TABLE_BASE_01     /* puntero a tabla de 2do nivel */
      LDR R1, =__reset_start__      /* direccion virtual inicial */
      LDR R2, =DIR_FISICA_RV        /* direccion fisica inicial */
      MOV R5, #0x31
      BL pag_map

      LDR R3, =__boot_end__
      LDR R1, =__boot_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_02
      LDR R1, =__boot_start__
      LDR R2, =DIR_FISICA_BOOT
      MOV R5, #0x31
      BL pag_map

      /* TAREA 01 */
      LDR R3, =__task_01_end__
      LDR R1, =__task_01_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_03
      LDR R1, =__task_01_start__
      LDR R2, =DIR_FISICA_TASK_01
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__stack_end_
      LDR R1, =__stack_start_
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_03
      LDR R1, =__stack_start_
      LDR R2, =DIR_FISICA_STACK
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__data_01_end__
      LDR R1, =__data_01_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_03
      LDR R1, =__data_01_start__
      LDR R2, =DIR_FISICA_DATA_01
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__text_end__
      LDR R1, =__text_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_03
      LDR R1, =__text_start__
      LDR R2, =DIR_FISICA_APP
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__bss_01_end__
      LDR R1, =__bss_01_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_04
      LDR R1, =__bss_01_start__
      LDR R2, =DIR_FISICA_BSS_01
      MOV R5, #0x831
      BL pag_map

      /* TAREA 02 */
      LDR R3, =__task_02_end__
      LDR R1, =__task_02_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_05
      LDR R1, =__task_02_start__
      LDR R2, =DIR_FISICA_TASK_02
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__stack_end_
      LDR R1, =__stack_start_
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_05
      LDR R1, =__stack_start_
      LDR R2, =DIR_FISICA_STACK
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__data_02_end__
      LDR R1, =__data_02_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_05
      LDR R1, =__data_02_start__
      LDR R2, =DIR_FISICA_DATA_01
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__text_end__
      LDR R1, =__text_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_05
      LDR R1, =__text_start__
      LDR R2, =DIR_FISICA_APP
      MOV R5, #0x831
      BL pag_map

      LDR R3, =__bss_02_end__
      LDR R1, =__bss_02_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_06
      LDR R1, =__bss_02_start__
      LDR R2, =DIR_FISICA_BSS_02
      MOV R5, #0x831
      BL pag_map
      /* ------ */

      LDR R3, =__text_end__
      LDR R1, =__text_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_02
      LDR R1, =__text_start__
      LDR R2, =DIR_FISICA_APP
      MOV R5, #0x31
      BL pag_map

      LDR R3, =__stack_end_
      LDR R1, =__stack_start_
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_02
      LDR R1, =__stack_start_
      LDR R2, =DIR_FISICA_STACK
      MOV R5, #0x31
      BL pag_map

      LDR R3, =__data_end__
      LDR R1, =__data_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_07
      LDR R1, =__data_start__
      LDR R2, =DIR_FISICA_DATA
      MOV R5, #0x31
      BL pag_map

      LDR R3, =__bss_end__
      LDR R1, =__bss_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_08
      LDR R1, =__bss_start__
      LDR R2, =DIR_FISICA_BSS
      MOV R5, #0x31
      BL pag_map

      LDR R3, =DIR_FISICA_TIMER_END
      LDR R1, =DIR_FISICA_TIMER_BASE
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_TIMER
      LDR R1, =DIR_FISICA_TIMER_BASE      /* Son iguales porque son Identi Map */
      LDR R2, =DIR_FISICA_TIMER_BASE
      MOV R5, #0x31
      BL pag_map

      LDR R3, =DIR_FISICA_GIC_END
      LDR R1, =DIR_FISICA_GIC_BASE
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_GIC
      LDR R1, =DIR_FISICA_GIC_BASE
      LDR R2, =DIR_FISICA_GIC_BASE
      MOV R5, #0x31
      BL pag_map

      MOV LR, R7

      BX LR

/* 
 * R0 = direccion base tabla segundo nivel
 * R1 = direccion virtual base
 * R2 = direccion fisica base
 * R3 = numero de paginas
 */
pag_map:
      CMP R3, #0
      BXEQ LR
      LSR R8, R1, #12   /* R8 valor de entrada de la tabla 2 */ /*Desplaza R1 12 bits a la derecha, los bits de R1[19:12] quedan en R8[7:0] */
      AND R8, R8, #0xFF /* Solo se mantienen los bits en el rango [7:0] */
      LSL R8, R8, #2
      ADD R0, R0, R8

      /* AP = 010: RW PL1, R0 PL0; bits [1:0] = 0b10 */
      MOV R4, R2
      ORR R4, R4, R5 //ORR R4, R4, 0x22

loop_table_l2:
      STR R4, [R0], #4     /* escribir descriptor y avanzar 4 bytes */

      ADD R4, R4, #0x1000  /* próxima dirección física */

      SUBS R3, R3, #1
      BXEQ LR
      B loop_table_l2

/*
* R0=origen
* R1=destino
* R2=count
*/
loop_copy:
      CMP R2, #0
      BEQ return_copy
      LDR R4, [R0], #4        /* carga el valor de la direccion de memoria de R0 en el regitro R4, post-incrementa R0 */
      STR R4, [R3], #4        /* almacena el valor encontrado en R4 en la direccion de memoria encontrada en R3, post-incrementa R3 */
      SUBS R2, R2, #1         /* R2 = R2 - 1, la S actualiza los flags */
      BNE loop_copy           /* B salto Condicional (Not Equal), salto si la resta no da 0 */

return_copy:
      BX LR

.code 32
.section .reset,"ax"@progbits
      LDR PC, salto_reset           /* carga la dirección de memoria de _handler_reset a través de la etiqueta salto_reset en PC */
      LDR PC, salto_und
      LDR PC, salto_svc
      LDR PC, salto_prefetch_abort
      LDR PC, salto_data_abort
      LDR PC, salto_reserved
      LDR PC, salto_irq
      LDR PC, salto_fiq

salto_reset:            .word _handler_reset
salto_und:              .word _handler_und
salto_svc:              .word _handler_svc
salto_prefetch_abort:   .word _handler_prefetch_abort
salto_data_abort:       .word _handler_data_abort
salto_reserved:         .word _handler_reserved
salto_irq:              .word _handler_irq
salto_fiq:              .word _handler_fiq

.code 32
.section .text

_gic_init:
    LDR R0, =GICC0_ADDR
    LDR R1, =GICD0_ADDR

    /* GICC0->PMR = 0x000000F0 */
    MOV R2, #0xF0
    STR R2, [R0, #0x04]       /* almacena el valor encontrado en R2 en la direccion de memoria [R0 + 4], Registro base sin modificar*/

    /* GICD0->ISENABLER[1] |= 0x00000010 */
    LDR R3, [R1, #0x104]      /* carga el valor de la direccion de memoria [R1 + 104] y lo almacena en R3*/
    ORR R3, R3, #0x10         /* R3 = R3 OR 0x1000 */
    STR R3, [R1, #0x104]      /* Guardamos el resultado en GICD0->ISENABLER[1] */

    /* GICD0->ISENABLER[1] |= 0x00001000 */
    LDR R3, [R1, #0x104]
    ORR R3, R3, #0x1000
    STR R3, [R1, #0x104]

    /* GICC0->CTLR = 0x00000001 */
    MOV R2, #1
    STR R2, [R0, #0x00]

    /* GICD0->CTLR = 0x00000001 */
    STR R2, [R1, #0x00]

    BX LR

_timer0_init:
    LDR R1, =TIMER_BASE_01
    MOV R0, #10000
    STR R0, [R1]              /* Base + 0x00: TimerLoad */
    ADD R1, R1, #8            /* Base + 0x00: TimerControl */
    MOV R0, #0b11100010       
    STR R0, [R1]
    BX LR

_handler_reset:
b .

_handler_fiq:
b .

_handler_und:
      PUSH {R0-R9,R11,R12, LR}

      MOV R0, #0              /* Cargo en R0 el valor 0 que representa a andeq r0, r0, r0 */
      SUB R1, LR, #4          /* El LR en modo _und guarda la direccion de retorno despues de la excepcion (PC + 4) */
      STR R0, [R1]            /* almacena el valor encontrado en R0 (0x00) en la direccion de memoria encontrada en R1 */

      LDR R10, =INV

      POP {R0-R9,R11,R12, LR}
      SUBS PC, LR, #4         /* _S restaura los flags y el modo */

_handler_svc:
      PUSH {R4, LR}
      SUB R4, LR, #4          /* El LR en modo _svc o _swi guarda la direccion de retorno despues de la excepcion (PC + 4) */
      LDRB R4, [R4]           /* carga el valor del byte menos significativo encontrado en R4 en la direccion de memoria de R4 */
      CMP R4, #0
      BEQ _svc_suma
      CMP R4, #1
      BEQ _svc_resta

      B _svc_exit

_svc_suma:
    ADDS R0, R0, R2      // R0 = R0 + R2 (parte baja), actualiza flags
    ADC  R1, R1, R3      // R1 = R1 + R3 + carry (parte alta)
    B _svc_exit

_svc_resta:
    SUBS R0, R0, R2      // R0 = R0 - R2 (parte baja), actualiza flags
    SBC  R1, R1, R3      // R1 = R1 - R3 - borrow (parte alta)
    B _svc_exit

_svc_exit:
      POP {R4, LR}
      MOVS PC, LR

_handler_prefetch_abort:
      PUSH {R0-R9,R11,R12, LR}

      LDR R10, =MEM

      POP {R0-R9,R11,R12, LR}
      SUBS PC, LR, #4   

_handler_data_abort:
      PUSH {R0-R9,R11,R12, LR}

      LDR R10, =MEM

      POP {R0-R9,R11,R12, LR}
      SUBS PC, LR, #8   

_handler_reserved:
b .

_handler_irq:
      SUB LR, LR, #4
      PUSH {R0-R12, LR}             /* PILA: LR' R12' R11' ... R1' R0' */
                                    /* RECORDATORIO: La pila crece hacia abajo */
      LDR R1, =GICC0_ADDR
      ADD R1, R1, #12         

      LDR R2, [R1]                  /* Leo el valor del ID de la IT */

      CMP R2, #36
      BEQ _irq_timer

      B _irq_exit

_irq_timer:
      LDR R1,=cont_timer      /* carga la dirección de la variable cont_timer en R1 */
      LDR R10, [R1]           /* cargo en R10 el valor almacenado en la dirección de memoria apuntada por R1 */
      ADD R10, R10, #1        /* guardo el valor de R10 en la dirección de memoria apuntada por R1 */
      STR R10, [R1]           

      BL _scheduler

      LDR R1, =TIMER_BASE_01
      ADD R1, R1, #0x0C             /* TimerIntClr: Reconoce la interrupcion enviada. */

      MOV r0, #1
      STR r0, [R1]                  /* Limpiamos el flag escribiendo 1 */

      LDR R1, =GICC0_ADDR
      ADD R1, R1, #16               /* Apunta a GICC_EOIR */

      MOV r0, #36
      STR r0, [R1]                  /* Indico que la IT con ID #36 ha terminado */

      B _irq_exit

_irq_exit:
      POP {R0-R12, LR}
      MOVS PC, LR

_scheduler:
      CMP R10, #1             /* Paso de task3 a task1 */
      LDREQ R0, =pcb_task3
      BEQ _save_context

      CMP R10, #2             /* Paso de task1 a task2 */
      LDREQ R0, =pcb_task1
      BEQ _save_context

      CMP R10, #3            /* Paso de task2 a task3 */
      LDREQ R0, =pcb_task2
      BEQ _save_context

      CMP R10, #10
      MOVEQ R10, #0
      STREQ R10, [R1]

      BX LR

_save_context:
      POP {R1-R12}            /* Traigo los registros R0' a R11' desde la pila */
      STMIA R0!, {R1 - R12}   /* Almaceno en R1 a R12, con post-incremento */
      POP {R1,R2}             /* Traigo el registro R12' y LR (PC_TASK) desde la pila */
      STMIA R0!, {R1,R2}      /* Almaceno en R1, con post-incremento */
      MSR CPSR_c, #MODE_SVC
      STR LR, [R0], #4        /* Almaceno LR (LR_SCH) en la dirección R0, post-incremento */
      STR SP, [R0], #4        /* Almaceno SP en la dirección R0, post-incremento */
      MSR CPSR_c, #MODE_IRQ
      ADD R0, #4              /* Me salto el ASID */
      MRS R1, SPSR            /* Lee el SPSR y lo almacena en R1 */
      STR R1, [R0], #4        /* Almaceno R1 en la dirección R0, post-incremento */
      ADD R0, #4

      LDR R1,=cont_timer
      LDR R10, [R1]

      CMP R10, #1             /* Paso de task3 a task1 */
      LDR R0, =pcb_task1
      BEQ _switch_context

      CMP R10, #2             /* Paso de task1 a task2 */
      LDR R0, =pcb_task2
      BEQ _switch_context

      CMP R10, #3             /* Paso de task2 a task3 */
      LDR R0, =pcb_task3
      BEQ _switch_context

_switch_context:
      ADD R0, #52             /* Me muevo al PC de PCB */
      LDR R4, [R0]            /* Guardo en R4 mi PC de PCB*/
      PUSH {R4}               /* Lo envio al inicio de mi stack para respetar el orden */
      LDMDB R0!, {R1-R12}     /* pre-decremento, almaceno en R0 */
      PUSH {R1-R12}           /* Push respetando el orden, queda LR(PC_TASK) R12' R11' ... R1' */
      LDR R4, [R0, #-4]!      /* pre-decremento, almaceno en R4 */
      PUSH {R4}               /* Push respetando el orden, queda LR(PC_TASK) R12' R11' ... R0' */

      ADD R0, #56             /* Me muevo al LR_PCB */
      MSR CPSR_c, #MODE_SVC
      LDR LR, [R0], #4        /* Carga el valor desde la dir en R0 (LR_PCB) y lo almacena en LR, post-incremento */
      LDR SP, [R0], #4
      MSR CPSR_c, #MODE_IRQ
      ADD R0, #4              /* Me salto el ASID */
      LDR R1, [R0]            /* Guardo el CPSR y lo almacena en R1 */
      MSR SPSR, R1            /* Cargo el SPSR con el valor de R1 */

      LDR R5, [R0, #-4]!      /* pre-decremento, almaceno en R5 el ASID*/
      LDR R7, [R0, #8]!       /* pre-incremento, almaceno en R7 el TTBR*/

      MOV R1, #0
      MCR p15, 0, R1, c13, c0, 1
      ISB
      MCR p15, 0, R7, c2, c0, 0     /* TTBR0 <= R7 */
      ISB
      MCR p15, 0, R5, c13, c0, 1    /* CONTEXTIDR <= R5 (ASID/PROCID) */
      BX LR

_main:
      .word 0xFFFFFFFF
      CPSIE i

      LDR R0, =pcb_task1
      LDR R0, =pcb_task2
      LDR R0, =pcb_task3

      MOV  R0, #3
      MOV  R1, #4
      MOV  R2, #5
      MOV  R3, #6

      WFI

_task_03:
      WFI
      B _task_03
