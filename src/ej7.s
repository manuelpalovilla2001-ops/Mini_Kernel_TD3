.extern __boot_start__
.extern __boot_end__

.extern __text_start__
.extern __text_end__
.extern __text_start_lma__

.extern __data_start__
.extern __data_end__
.extern __data_start_lma__

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

.extern __data_start__
.extern __data_end__

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
.equ L2_TABLE_BASE_01         , L1_TABLE_BASE + 0x4000           /* 0x000 */
.equ L2_TABLE_BASE_02         , L2_TABLE_BASE_01 + 0x400        /* 0x700 */
.equ L2_TABLE_BASE_03         , L2_TABLE_BASE_02 + 0x400        /* 0x810 */
.equ L2_TABLE_BASE_04         , L2_TABLE_BASE_03 + 0x400        /* 0x820 */
.equ L2_TABLE_BASE_TIMER      , L2_TABLE_BASE_04 + 0x400        /* 0x100 */
.equ L2_TABLE_BASE_GIC        , L2_TABLE_BASE_TIMER + 0x400     /* 0x1E0 */
.equ LONG_TABLES              , (L2_TABLE_BASE_GIC + 0x400) - L1_TABLE_BASE

.equ DIR_FISICA_RV            , 0x00000000
.equ DIR_FISICA_BOOT          , 0x70010000
.equ DIR_FISICA_APP           , 0x70030000
.equ DIR_FISICA_STACK         , 0x70060000
.equ DIR_FISICA_DATA          , 0x81000000
.equ DIR_FISICA_BSS           , 0x82000000 /*128K*/
.equ DIR_FISICA_TIMER_BASE    , 0x10011000
.equ DIR_FISICA_TIMER_END     , 0x1001A000
.equ DIR_FISICA_GIC_BASE      , 0x1E000000
.equ DIR_FISICA_GIC_END       , 0x1E020000

/**************************************************/
.equ TIMER_BASE_01  , 0x10011000 /* interrupt ID #36 */
.equ TIMER_BASE_23  , 0x10012000 /* interrupt ID #37 */
.equ TIMER_BASE_45  , 0x10018000 /* interrupt ID #73 */
.equ TIMER_BASE_67  , 0x10019000 /* interrupt ID #74 */

.equ INV    ,     0x494E56
.equ MEM    ,     0x4D454D

//.code 32
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

      LDR R0,=__reset_start_lma__
      LDR R1,=__reset_start__
      LDR R2,=__reset_end__
      LDR R3,=DIR_FISICA_RV
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
      ORR R0, R0, #0x1              /* Añadir bit C = 1 (Inner Non-cacheable) */
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

      LDR R0, =L1_TABLE_BASE + 0x000*4 /* direccion de la entrada 0x000 en la tabla de nivel 1 */
      LDR R1, =L2_TABLE_BASE_01 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x700*4 /* direccion de la entrada 0x700 en la tabla de nivel 1 */
      LDR R1, =L2_TABLE_BASE_02 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x810*4 /* direccion de la entrada 0x810 en la tabla de nivel 1 */
      LDR R1, =L2_TABLE_BASE_03 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x820*4 /* direccion de la entrada 0x820 en la tabla de nivel 1 */
      LDR R1, =L2_TABLE_BASE_04 + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x100*4 /* direccion de la entrada 0x100 en la tabla de nivel 1 */
      LDR R1, =L2_TABLE_BASE_TIMER + 1
      STR R1, [R0]

      LDR R0, =L1_TABLE_BASE + 0x1E0*4 /* direccion de la entrada 0x1E0 en la tabla de nivel 1 */
      LDR R1, =L2_TABLE_BASE_GIC + 1
      STR R1, [R0]

      LDR R3, =__reset_end__
      LDR R1, =__reset_start__
      SUB R3, R3, R1          /* R3 = size */
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12         /* R3 = numero de paginas */

      LDR R0, =L2_TABLE_BASE_01     /* puntero a tabla de 2do nivel */
      LDR R1, =__reset_start__      /* direccion virtual inicial */
      LDR R2, =DIR_FISICA_RV        /* direccion fisica inicial */
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
      BL pag_map

      LDR R3, =__text_end__
      LDR R1, =__text_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_02
      LDR R1, =__text_start__
      LDR R2, =DIR_FISICA_APP
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
      BL pag_map

      LDR R3, =__data_end__ + 0x1000
      LDR R1, =__data_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_03
      LDR R1, =__data_start__
      LDR R2, =DIR_FISICA_DATA
      BL pag_map

      LDR R3, =__bss_end__
      LDR R1, =__bss_start__
      SUB R3, R3, R1
      MOV R2, #0xFFF
      ADD R3, R3, R2
      LSR R3, R3, #12

      LDR R0, =L2_TABLE_BASE_04
      LDR R1, =__bss_start__
      LDR R2, =DIR_FISICA_BSS
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
      ORR R4, R4, #0x22

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
      PUSH {R0-R9,R11,R12, LR}

      LDR R1, =GICC0_ADDR
      ADD R1, R1, #12         

      LDR R2, [R1]                  /* Leo el valor del ID de la IT */

      CMP R2, #36
      BEQ _irq_timer

      B _irq_exit

_irq_timer:
      ADD R10, R10, #1

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
      POP {R0-R9,R11,R12, LR}
      SUBS PC, LR, #4

_handler_fiq:
b .

_main:
      .word 0xFFFFFFFF

      // SUMA: [R1, R0] + [R3, R2]
      MOV  R0, #0x02
      MOV  R1, #0x01
      MVN  R2, #0x00        /* R2 = 0xFFFFFFFF */
      MOV  R3, #0x00

      SVC #0

      // Resultado queda en R1,R0 = 0x00000002_00000001

      // RESTA: [R1, R0] - [R3, R2]
      MOV  R0, #0x00
      MOV  R1, #0x02
      MVN  R2, #0x00        /* R2 = 0xFFFFFFFF */
      MOV  R3, #0x01

      SVC #1

      // Resultado Queda en R1,R0: 0x00000000_00000001

      MOV R10, #0

      //BL _timer0_init

      wfi
