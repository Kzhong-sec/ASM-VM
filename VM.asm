include 'byte_code.asm'

struct _VM_REG
       EDI      dd      0
       ESI      dd      0
       EBP      dd      0
       ESP      dd      0
       EBX      dd      0
       EDX      dd      0
       ECX      dd      0
       EAX      dd      0
       EFLAGS               dd      0
ends

       EDI      equ      0
       ESI      equ      1
       EBP      equ      2
       ESP      equ      3
       EBX      equ      4
       EDX      equ      5
       ECX      equ      6
       EAX      equ      7


VM_REG  _VM_REG

macro decode_reg_edx  ; this puts the address of the specified vm register inside edx,  and uses ebx.   volatile macro
; expects the enum to be pointed to be esi
{

mov ebx, VM_REG
movzx edx, byte [esi]
lea edx, [ebx + edx * 4]
}


bytecode_next_op:
        movzx     eax, byte [esi]; gets first opcode from the byte code
        jmp       dword [arr_vm_opcodes + eax * 4]



VM_ENTRY:
        mov       esi, byte_code
        jmp      bytecode_next_op



EXIT_FUNC_1:
        push 0
        call [ExitProcess]


PUSH_REG_2:
       inc esi
       decode_reg_edx
       push dword [edx]
       inc esi
       jmp   bytecode_next_op


POP_REG_2:
        inc esi
        decode_reg_edx
        pop dword [edx]
        inc esi
        jmp bytecode_next_op

MOV_REG_IMM_6:
        inc esi
        decode_reg_edx
        mov eax, dword [esi + 1]
        mov dword [edx], eax
        add esi, 5
        jmp   bytecode_next_op

ADD_REG_IMM_6:
        inc esi
        decode_reg_edx
        mov eax, dword [esi + 1]
        add dword [edx], eax
        add esi, 5
        jmp   bytecode_next_op


MOV_REG_REG_3:
        inc esi
        decode_reg_edx
        mov eax, edx
        inc esi
        decode_reg_edx
        mov edx, dword [edx]
        mov dword [eax], edx
        inc esi
        jmp   bytecode_next_op

MOV_REG_REG_DEREF_BYTE_3:
        inc esi
        decode_reg_edx
        mov eax, edx
        inc esi
        decode_reg_edx
        mov edx, dword [edx]
        movsx edx, byte [edx]
        mov dword [eax], edx
        inc esi
        jmp   bytecode_next_op


MOV_REG_REG_DEREF_DWORD_3:
        inc esi
        decode_reg_edx
        mov eax, edx
        inc esi
        decode_reg_edx
        mov edx, dword [edx]
        mov edx, dword [edx]
        mov dword [eax], edx
        inc esi
        jmp   bytecode_next_op


CMP_REG_REG_3:
        inc esi
        decode_reg_edx
        mov eax, dword [edx]
        inc esi
        decode_reg_edx
        mov edx, dword [edx]
        cmp eax, edx
        pushf
        pop eax
        mov dword [VM_REG.EFLAGS], eax
        inc esi
        jmp bytecode_next_op





JNZ_Func_5:
        movsx eax, byte [esi + 1]
        push dword [VM_REG.EFLAGS]
        popf
        jnz not_zero
        add esi, 5
        jmp bytecode_next_op

    not_zero:
        mov esi, eax
        add esi, byte_code
        jmp bytecode_next_op

JZ_Func_5:
        movsx eax, byte [esi + 1]
        push dword [VM_REG.EFLAGS]
        popf
        jz is_zero
        add esi, 5
        jmp bytecode_next_op

     is_zero:
        mov esi, eax
        add esi, byte_code
        jmp bytecode_next_op

STD_CALL_5:
       inc esi
       mov eax, dword [esi]
       mov eax, dword [eax]
       call eax
       mov dword [VM_REG.EAX], eax
       add esi, 4
       jmp bytecode_next_op

MOVSB_1:
      dst equ eax
      src equ ebx
      inc esi
      mov dst,     VM_REG.EDI
      mov dst, dword [dst]
      mov src,     VM_REG.ESI
      mov src, dword [src]
      mov ecx, VM_REG.ECX
      mov ecx, dword [ecx]

  loop_start:
      movzx edx,   byte [src]
      mov byte [dst],  dl
      inc src
      inc dst
      loop loop_start

      jmp bytecode_next_op


MOV_MEM_DWORD_REG_6 :
      inc esi
      mov eax, dword [esi]
      add esi, 4
      decode_reg_edx
      mov edx, [edx]
      mov dword [eax], edx
      inc esi
      jmp bytecode_next_op

_XOR_REG_PTR_REG_BYTE_3:
        inc esi
        decode_reg_edx
        mov eax, edx
        inc esi
        decode_reg_edx
        mov edx, dword [edx]
        mov eax, dword [eax]
        xor byte [eax], dl
        inc esi
        jmp   bytecode_next_op

arr_vm_opcodes:
        dd      EXIT_FUNC_1          ;0
        dd      PUSH_REG_2           ;1
        dd      POP_REG_2    ;2
        dd      MOV_REG_IMM_6 ;3
        dd      ADD_REG_IMM_6 ;4
        dd      MOV_REG_REG_3      ;5
        dd      MOV_REG_REG_DEREF_BYTE_3    ;6
        dd      MOV_REG_REG_DEREF_DWORD_3    ;7
        dd      CMP_REG_REG_3      ;8
        dd      JNZ_Func_5      ;9
        dd      JZ_Func_5  ;10
        dd      STD_CALL_5      ;11  ;This saves the functions output to VM.EAX. Since it is stack based. Args are passed through the native stack
        dd      MOVSB_1         ;12
        dd      MOV_MEM_DWORD_REG_6   ;13
        dd      _XOR_REG_PTR_REG_BYTE_3 ;14
