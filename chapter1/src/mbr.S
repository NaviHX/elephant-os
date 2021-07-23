%include "boot.inc"
section MBR vstart=0x7c00
    ; 初始化段寄存器
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800 ; 使用文本模式的显存，将gs作为显存的段寄存器
    mov gs, ax

    ; 上卷屏幕
    mov ax, 0x600  ; ah: 中断功能号 al: 上卷行数, 0表示全部
    mov bx, 0x700  ; bh: 上卷行属性
    mov cx, 0x0    ; (cl, ch): 左上角坐标
    mov dx, 0x184f ; (dl, dh): 右下角坐标
    int 0x10

    ; 获取光标位置
    mov ah, 3 ; 中断功能号 
    mov bh, 0 ; 页号
    int 0x10

    ; 输出"MBR"
    mov byte [gs: 0x00], 'M'
    mov byte [gs: 0x01], 0xA4

    mov byte [gs: 0x02], 'B'
    mov byte [gs: 0x03], 0xA4

    mov byte [gs: 0x04], 'R'
    mov byte [gs: 0x05], 0xA4

    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cx, 0x1
    call read_disk

    jmp LOADER_BASE_ADDR ; 将控制权交给loader

read_disk:
    ; eax: LBA扇区地址(从0开始)
    ; bx : 写入的内存地址
    ; cx : 扇区数

    mov esi, eax
    mov di, cx

    ; 写入扇区数
    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi

    ; 写入LBA地址
    mov dx, 0x1f3
    out dx, al

    mov dx, 0x1f4
    shr eax, 8
    out dx, al

    mov dx, 0x1f5
    shr eax, 8
    out dx, al

    mov dx, 0x1f6
    shr eax, 8
    and al, 0xf
    or al,0xe0    ; 启用LBA,主盘
    out dx, al

    ; 写入读指令
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Polling查询硬盘状态
    .not_ready:
        nop          ; 空操作，等待一段时间
        in al, dx    ; 读取硬盘状态
        and al, 0x88 ; 获取硬盘状态码的第三位和第七位，第三位表示已准备好数据，第七位表示硬盘忙
        cmp al, 0x08 ; 检查第三位
        jnz .not_ready

    ; 读取数据
    mov ax, di  ; di中为备份的cx值，扇区数
    mov dx, 256
    mul dx
    mov cx, ax  ; cx寄存器控制循环次数，每次读两个字节，共读出di*512字节，所以共需读出di*256次 

    mov dx, 0x1f0
    .read_data:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop .read_data
        ret

    times 510-($-$$) db 0    ; 以0x00填充整个扇区剩余的部分
    db 0x55, 0xaa            ; 魔数, 表示这个扇区存储MBR主引导记录
