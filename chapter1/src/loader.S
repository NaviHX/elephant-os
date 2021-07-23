%include "boot.inc"
section LOADER vstart=LOADER_BASE_ADDR
    ; 输出"LOADER"
    mov byte [gs: 0x00], 'L'
    mov byte [gs: 0x01], 0x0f

    mov byte [gs: 0x02], 'O'
    mov byte [gs: 0x03], 0x0f

    mov byte [gs: 0x04], 'A'
    mov byte [gs: 0x05], 0x0f

    mov byte [gs: 0x06], 'D'
    mov byte [gs: 0x07], 0x0f

    mov byte [gs: 0x08], 'E'
    mov byte [gs: 0x09], 0x0f

    mov byte [gs: 0x0A], 'R'
    mov byte [gs: 0x0B], 0x0f

    jmp $
