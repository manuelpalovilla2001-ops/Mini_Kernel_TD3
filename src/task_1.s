.global _task_01

.equ TASK1_RAM_INIT     ,     0x70100000
.equ TASK1_RAM_END      ,     0x7010FFFF
.equ MSJ                ,     0x55AA55AA

.code 32
.section .text_01,"ax"@progbits

_task_01:
      LDR R0,=TASK1_RAM_INIT
      LDR R1,=TASK1_RAM_END
      LDR R2,=MSJ

write_loop:
      STR R2, [R0]
      LDR R4, [R0]
      CMP R4, R2
      ADD R0, R0, #4
      CMP R0, R1
      BEQ _task_01
      B write_loop