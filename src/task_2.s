.global _task_02

.equ TASK2_RAM_INIT     ,     0x70100000
.equ TASK2_RAM_END      ,     0x7010FFFF

.code 32
.section .text_02,"ax"@progbits
_task_02:
      LDR R0,=TASK2_RAM_INIT
      LDR R1,=TASK2_RAM_END

reverse_loop:
      LDR R2, [R0]
      MVN R2, R2    /* Invierte los bits, es como hacer un negado */
      STR R2, [R0]
      ADD R0, R0, #4
      CMP R0, R1
      BEQ _task_02
      B reverse_loop