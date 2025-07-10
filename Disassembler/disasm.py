import idaapi

BYTECODE_BASE =  0x0401000
BYTECODE_END = 0x00401089

visited_addrs = set()
ea_and_instructions = []

EA = 0

INSN = 1

VM_OPCODES = {
    0:  "EXIT_PROCESS_1",
    1:  "PUSH_VM_REG",
    2:  "POP_VM_REG",
    3:  "MOV_VM_REG_IMM",
    4:  "ADD_VM_REG_IMM",
    5:  "MOV_VM_REG_VM_REG",
    6:  "MOV_VM_REG_VM_REG_DEREF_BYTE",
    7:  "MOV_VM_REG_VM_REG_DEREF_DWORD",
    8:  "CMP_VM_REG_VM_REG",
    9:  "JNZ",
    10: "JZ",
    11: "STD_CALL",
    12: "MOVSB_R1_R0",
    13: "MOV_MEM_REG",
    14: "XOR_DEREF_VM_REG_VM_REG"
}

TAB = "\t\t\t\t\t\t"

def disasm(cip):
    if cip not in range(BYTECODE_BASE, BYTECODE_END):
        ea_and_instructions.append((cip, f"Error occurred at {hex(cip)}, cip outside code"))
        return
    
    if cip in visited_addrs:
        return
    
    visited_addrs.add(cip)

    opdcode_byte = idaapi.get_byte(cip)
    insn = hex(cip)
    insn += "\t" + VM_OPCODES.get(opdcode_byte, f"ERROR ---> Unknown instruction opcode encountered at {hex(cip)}")
    
    match opdcode_byte:
        case 0:
            ea_and_instructions.append((cip, insn))
            return
        
        case 1:
            reg_enum = idaapi.get_byte(cip + 1)
            vm_reg = decode_vm_reg(reg_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{vm_reg}"))
            disasm(cip + 2)
            return
        
        case 2:
            reg_enum = idaapi.get_byte(cip + 1)
            vm_reg = decode_vm_reg(reg_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{vm_reg}"))
            disasm(cip + 2)
            return
        
        case 3:
            reg_enum = idaapi.get_byte(cip + 1)
            vm_reg = decode_vm_reg(reg_enum)
            imm32 = hex(idaapi.get_dword(cip + 2))
            ea_and_instructions.append((cip, f"{insn}{TAB}{vm_reg}, {imm32}"))
            disasm(cip + 6)
            return
        
        case 4:
            reg_enum = idaapi.get_byte(cip + 1)
            vm_reg = decode_vm_reg(reg_enum)
            imm32 = hex(idaapi.get_dword(cip + 2))
            ea_and_instructions.append((cip, f"{insn}{TAB}{vm_reg}, {imm32}"))
            disasm(cip + 6)
            return
        
        case 5:
            reg1_enum = idaapi.get_byte(cip + 1)
            reg2_enum = idaapi.get_byte(cip + 2)
            reg1 = decode_vm_reg(reg1_enum)
            reg2 = decode_vm_reg(reg2_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{reg1}, {reg2}"))
            disasm(cip + 3)
            return
        
        case 6:
            reg1_enum = idaapi.get_byte(cip + 1)
            reg2_enum = idaapi.get_byte(cip + 2)
            reg1 = decode_vm_reg(reg1_enum)
            reg2 = decode_vm_reg(reg2_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{reg1}, {reg2}"))
            disasm(cip + 3)
            return

        case 7:
            reg1_enum = idaapi.get_byte(cip + 1)
            reg2_enum = idaapi.get_byte(cip + 2)
            reg1 = decode_vm_reg(reg1_enum)
            reg2 = decode_vm_reg(reg2_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{reg1}, {reg2}"))
            disasm(cip + 3)
            return
        
        case 8:
            reg1_enum = idaapi.get_byte(cip + 1)
            reg2_enum = idaapi.get_byte(cip + 2)
            reg1 = decode_vm_reg(reg1_enum)
            reg2 = decode_vm_reg(reg2_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{reg1}, {reg2}"))
            disasm(cip + 3)
            return
        
        case 9:
            dst = idaapi.get_dword(cip + 1)
            dst += BYTECODE_BASE
            ea_and_instructions.append((cip, f"{insn}{TAB}{hex(dst)}"))
            disasm(cip + 5)
            disasm(dst)
            return

        case 10:
            dst = idaapi.get_dword(cip + 1)
            dst += BYTECODE_BASE
            ea_and_instructions.append((cip, f"{insn}{TAB}{hex(dst)}"))
            disasm(cip + 5)
            disasm(dst)
            return

        case 11:
            func = idaapi.get_dword(cip + 1)
            func = idaapi.get_name(func)
            ea_and_instructions.append((cip, f"{insn}{TAB}{func}"))
            disasm(cip + 5)
            return
        
        case 12:
            ea_and_instructions.append((cip, f"{insn}"))
            disasm(cip + 1)
            return
        
        case 13:
            mem_addr = hex(idaapi.get_dword(cip + 1))
            reg2_enum = idaapi.get_byte(cip + 5)
            reg2 = decode_vm_reg(reg2_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{mem_addr}, {reg2}"))
            disasm(cip + 6)
            return

        case 14:
            reg1_enum = idaapi.get_byte(cip + 1)
            reg2_enum = idaapi.get_byte(cip + 2)
            reg1 = decode_vm_reg(reg1_enum)
            reg2 = decode_vm_reg(reg2_enum)
            ea_and_instructions.append((cip, f"{insn}{TAB}{reg1}, {reg2}"))
            disasm(cip + 3)
            return

def decode_vm_reg(reg_enum):
    VM_REGS = """
    VM_R0_DST
    VM_R1_SRC
    VM_R2
    VM_R3
    VM_R4
    VM_R5
    VM_R6_COUNT
    VM_R7_STD_CALL_OUTPUT
    VM_EFLAGS
    """
    match reg_enum:
        case 0:
            return "VM_R0_DST"
        case 1:
            return "VM_R1_SRC"
        case 2:
            return "VM_R2"
        case 3:
            return "VM_R3"
        case 4:
            return "VM_R4"
        case 5:
            return "VM_R5"
        case 6:
            return "VM_R6_COUNT"
        case 7: 
            return "VM_R7_STD_CALL_OUTPUT"
        case 8:
            return "VM_EFLAGS"
        case _:
            return f"Error: unkown reg enum encountered --> {hex(reg_enum)}"
        




def main():
    disasm(BYTECODE_BASE)
    ea_and_instructions.sort(key=lambda x: x[0])

    for _, instruction in ea_and_instructions:
        print(instruction)

main()