macro EXIT
{
db      0
}


macro PUSH_REG  reg_enum
{
db      1
db      reg_enum
}

macro   POP_REG reg_enum
{
db      2
db      reg_enum
}

macro   MOV_REG_IMM     reg_enum,     imm
{
db      3
db      reg_enum
dd      imm
}

macro   ADD_REG_IMM     reg_enum,     imm
{
db      4
db      reg_enum
dd      imm
}

macro   MOV_REG_REG     reg1,    reg2
{
db      5
db      reg1
db      reg2
}


macro   MOV_REG_REG_DEREF_BYTE  reg1,    reg2
{
db      6
db      reg1
db      reg2
}

macro   MOV_REG_REG_DEREF_DWORD  reg1,    reg2
{
db      7
db      reg1
db      reg2
}

macro   CMP_REG_REG     reg1,    reg2
{
db      8
db      reg1
db      reg2
}

macro   JNZ     dst
{
db      9
dd      dst - byte_code
}

macro   JZ     dst
{
db      10
dd      dst - byte_code
}

macro   STD_CALL        func
{
db      11
dd      func
}

macro   MOVSB
{
db      12
}

macro MOV_MEM_DWORD_REG       mem,    reg_enum
{
db      13
dd      mem
db      reg_enum
}

macro XOR_REG_PTR_REG_BYTE_3       reg1,    reg2
{
db      14
db      reg1
db      reg2
}




       EDI      equ      0
       ESI      equ      1
       EBP      equ      2
       ESP      equ      3
       EBX      equ      4
       EDX      equ      5
       ECX      equ      6
       EAX      equ      7



xor_key equ 0x42
msg_len equ 28

byte_code:
        MOV_REG_IMM EAX, PAGE_READWRITE
        PUSH_REG EAX
        MOV_REG_IMM EDI, MEM_COMMIT
        PUSH_REG EDI
        MOV_REG_IMM ESI, msg_len + 1
        PUSH_REG ESI
        MOV_REG_IMM ESI, 0
        PUSH_REG ESI
        STD_CALL VirtualAlloc

        MOV_MEM_DWORD_REG alloc_mem, EAX ; storing output in global, and making sure allocation succeeded
        MOV_REG_IMM ESI, 0
        CMP_REG_REG EAX, ESI
        JZ exit

        MOV_REG_REG EDI, EAX      ; Copying the encrypted message into allocated memory
        MOV_REG_IMM ESI, enc_msg
        MOV_REG_IMM ECX, msg_len
        MOVSB

        MOV_REG_IMM EBP, 0
   xor_loop_start:
        MOV_REG_IMM EBX, xor_key
        XOR_REG_PTR_REG_BYTE_3 EAX, EBX
        ADD_REG_IMM ECX, -1
        CMP_REG_REG ECX, EBP
        ADD_REG_IMM EAX, 1
        JNZ xor_loop_start

        PUSH_REG EBP    ; 0
        MOV_REG_IMM EAX, title  ; 'VM Message'
        PUSH_REG EAX
        MOV_REG_IMM EAX, alloc_mem
        MOV_REG_REG_DEREF_DWORD EBX, EAX
        PUSH_REG EBX    ; alloced_mem pointer
        PUSH_REG EBP   ; 0
        STD_CALL MessageBoxA




exit:
   EXIT

        ; loop start
