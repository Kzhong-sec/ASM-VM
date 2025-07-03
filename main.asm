
format PE GUI 4.0
entry start

include "win32a.inc"
include "VM.asm"


section '.text' code readable executable


  start:
        call   VM_ENTRY


section '.data' data readable writeable
    ; XOR encrypted "Hello from allocated memory!" with key 0x42

    enc_msg db 10, 39, 46, 46, 45, 98, 36, 48, 45, 47, 98, 35, 46, 46, 45, 33, 35, 54, 39, 38, 98, 47, 39, 47, 45, 48, 59, 99
    alloc_mem  dd       0
    title db 'VM Message',0



section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
          user,'USER32.DLL'

  import kernel32,\
       VirtualAlloc, 'VirtualAlloc',\
       ExitProcess,  'ExitProcess'


  import user,\
         MessageBoxA,'MessageBoxA',\
         EndDialog,'EndDialog'



