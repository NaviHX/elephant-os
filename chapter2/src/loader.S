%include "boot.inc"
section LOADER vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

; GDT数据结构
GDT_BASE:   dd 0x00000000
            dd 0x00000000
GDT_DESC:   dd 0x0000ffff
            dd DESC_CODE_HIGH4
DATA_STACK_DESC:    dd  0x0000ffff
                    dd DESC_DATA_HIGH4
VIDEO_DESC: dd 0x80000007
            dd DESC_VIDEO_HIGH4
GDT_SIZE equ $-GDT_BASE
GDT_LIMIT equ GDT_SIZE-1
times 60 dq 0

SELECTOR_CODE equ (0x0001<<3)+TI_GDT+RPL0
SELECTOR_DATA equ (0x0002<<3)+TI_GDT+RPL0
SELECTOR_VIDEO equ (0x0003<<3)+TI_GDT+RPL0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

loadermsg db 'loader in real'
loader_start:
    ; 使用0x10中断0x13功能打印字符串
    mov sp, LOADER_BASE_ADDR
    mov bp, loadermsg
    mov cx, 15
    mov ax, 0x1301
    mov bx, 0x001f
    mov dx, 0x1800
    int 0x10

    ; 打开A20地址线
    in al, 0x92
    or al, 0000_0010b
    out 0x92, al

    ; 加载GDT
    lgdt [gdt_ptr]

    ; PE位置1
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    ; 刷新流水线
    jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    ; 第二行输出一个P
    mov byte [gs: 160], 'P'
    mov byte [gs: 161], 0x0f

    jmp $
