; vvv debug vvv
fim p0 program_1 ; warning expected on this :)
jms copy_program_1

jun hlt
; ^^^ debug ^^^

jun main

hlt0: jun hlt0
hlt1: jun hlt1
hlt2: jun hlt2
hlt3: jun hlt3
hlt4: jun hlt4
hlt5: jun hlt5
hlt6: jun hlt6
hlt7: jun hlt7

main:
jun swtch
; end main

hlt: jun hlt

swtch:
; dispatch to the appropriate opcode handler
; load the current state to r0
clc
fim p0 vm_pc
src p0
rdm
; acc *= 2
ral
fim p0 0
xch r1
jun opcode_dispatch
; end swtch

; memcpy between RAM pages
; p0 = dst page addr
; p1 = src page addr
; r4 = dst page number
; r5 = src page number
; p3 = num_bytes
; Leaves you on dst page
; clobbers acc, input registers (p0, p1, p2, p3), p4
; no return values
ram_memcpy:
ram_memcpy__loop:

; low byte of acc = 0?
ram_memcpy__loop__check_low:
ld r7
jcn a ram_memcpy_loop__check_high
jun ram_memcpy__loop__copy
; high bytes of acc = 0?
ram_memcpy_loop__check_high:
ld r6
; hi and low both = 0? then we're done
jcn a ram_memcpy__done

ram_memcpy__loop__copy:
; switch to src page
xch r5
dcl
xch r5
; grab src value
src p1
rdm
; switch to dst page
xch r4
dcl
xch r4
src p0
wrm

; decrement low. If low was 0, also decrement high.
fim p4 1 ; we'll use this to decrement
ram_memcpy__loop__dec_low:
clc
ld r7
sub r9
xch r7
jcn nc ram_memcpy__inc ; if we didn't set the carry, continue to the increments
ram_memcpy__loop__dec_high:
clc
ld r6
sub r9
xch r6
jcn c ram_memcpy__done ; if we set the carry, we hit 0! yay! we're done!

ram_memcpy__inc:
; inc src
ram_memcpy__loop__inc_src_low:
ld r3
iac 
xch r3
jcn nc ram_memcpy__loop__after_inc_src
ram_memcpy__loop__inc_src_high:
ld r2
iac
xch r2
ram_memcpy__loop__after_inc_src:

; inc dst
ram_memcpy__loop__inc_dst_low:
ld r1
iac 
xch r1
jcn nc ram_memcpy__loop__after_inc_dst
ram_memcpy__loop__inc_dst_high:
ld r0
iac
xch r0
ram_memcpy__loop__after_inc_dst:

jun ram_memcpy__loop

ram_memcpy__done:
bbl 0
; end ram_memcpy


%pagealign
program_1:
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
program_2:
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
program_3:
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
program_4:
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef
%byte 0x01 0x23
%byte 0x45 0x67
%byte 0x89 0xab
%byte 0xcd 0xef

; copy a program, starting at p0 in ROM, into the current bank's bytecode buffer
; This is valid for programs 1 to 4 (for programs 5 to 8, use copy_program_2)
; src = p0
; clobbers p0, p1, p2, acc
; pseudocode:
; dst = bytecode_start
; repeat twice {
;   cnt = 0
;   do {
;     a,b = *src;
;     *dst = a;
;     dst++;
;     *dst = b;
;     dst++;
;     src++;
;   } while (++cnt != 0);
; }
copy_program_1:
; dst = bytecode_start
fim p1 bytecode_start

; vvv rep 1 vvv
; cnt = 0
fim p3 0
copy_program_1__loop_1:
; cnt = 0
; do {
; a, b = *src
fin p2 ; now r4 = a, r5 = b
; *dst = a
src p1 
ld r4
wrm
; dst++
xch r3
iac
xch r3
jcn nc copy_program_1__loop_1__inc_dst_1__after ; no carry, just go to the next
; ugh, we had a carry, let's increment high
xch r2
iac
xch r2
copy_program_1__loop_1__inc_dst_1__after:
; *dst = b
src p1
ld r5
wrm
; dst++ 
xch r3
iac
xch r3
jcn nc copy_program_1__loop_1__inc_dst_2__after ; no carry, just go to the next
; ugh, we had a carry, let's increment high
xch r2
iac
xch r2
copy_program_1__loop_1__inc_dst_2__after:
; src++
xch r1
iac
xch r1
jcn nc copy_program_1__loop_1__inc_src__after ; no carry, just go to the next
; ugh, we had a carry, let's increment high
xch r0
iac
xch r0
copy_program_1__loop_1__inc_src__after:
; while (++cnt != 0);
isz r6 copy_program_1__loop_1__end
jun copy_program_1__loop_1
copy_program_1__loop_1__end:
; ^^^ rep 1 ^^^

; vvv rep 2 vvv
; cnt = 0
fim p3 0
copy_program_1__loop_2:
; cnt = 0
; do {
; a, b = *src
fin p2 ; now r4 = a, r5 = b
; *dst = a
src p1 
ld r4
wrm
; dst++
xch r3
iac
xch r3
jcn nc copy_program_1__loop_2__inc_dst_1__after ; no carry, just go to the next
; ugh, we had a carry, let's increment high
xch r2
iac
xch r2
copy_program_1__loop_2__inc_dst_1__after:
; *dst = b
src p1
ld r5
wrm
; dst++ 
xch r3
iac
xch r3
jcn nc copy_program_1__loop_2__inc_dst_2__after ; no carry, just go to the next
; ugh, we had a carry, let's increment high
xch r2
iac
xch r2
copy_program_1__loop_2__inc_dst_2__after:
; src++
xch r1
iac
xch r1
jcn nc copy_program_1__loop_2__inc_src__after ; no carry, just go to the next
; ugh, we had a carry, let's increment high
xch r0
iac
xch r0
copy_program_1__loop_2__inc_src__after:
; while (++cnt != 0);
isz r6 copy_program_1__loop_2__end
jun copy_program_1__loop_2
copy_program_1__loop_2__end:
; ^^^ rep 2 ^^^


bbl 0
; end copy_program_1


%pagealign
; jump to the correct entry in the dispatch table
; we can do this without any fancy math on the dispatch table because we're
; P A G E A L I G N E D which is a magic incantation about how bullshit the
; addressing on the 4004 is -- because the jin below (`state_dispatch`) is on
; the same page as us, it dispatches to one of these.
; these must all, obviously, be 2-bytes long, preferably juns
opcode_dispatch_table:
dispatch_entry_0:  jun hlt0 ; 
dispatch_entry_1:  jun hlt1 ;
dispatch_entry_2:  jun hlt2 ;
dispatch_entry_3:  jun hlt3 ;
dispatch_entry_4:  jun hlt4 ;
dispatch_entry_5:  jun hlt5 ;
dispatch_entry_6:  jun hlt6 ;
dispatch_entry_7:  jun hlt7 ;
; dispatch to the appropriate jump table 
opcode_dispatch: jin p0


; ======= DATA TYPES =======
; enum OPCODE
%let OPCODE_FAIL = 0
%let OPCODE_ROL = 1
%let OPCODE_LD = 2
%let OPCODE_XORI = 3
%let OPCODE_STRI = 4
%let OPCODE_RST = 5
%let OPCODE_LDM = 6
%let OPCODE_ADD = 7


; ======= MEMORY LAYOUT ======= 
; Each RAM bank looks roughly the same. Here's space to assign all locations:
%let bytecode_start = 0 ; important that this is page aligned
; all things in this range are bytecode
%let bytecode_end = 63
; 64    = 
; 65    = 
; 66    = 
; 67    = 
; 68    = 
; 69    = 
; 70    = 
; 71    = 
; 72    = 
; 73    = 
; 74    = 
; 75    = 
; 76    = 
; 77    = 
; 78    = 
; 79    = 
; 80    = 
; 81    = 
; 82    = 
; 83    = 
; 84    = 
; 85    = 
; 86    = 
; 87    = 
; 88    = 
; 89    = 
; 90    = 
; 91    = 
; 92    = 
; 93    = 
; 94    = 
; 95    = 
; 96    = 
; 97    = 
; 98    = 
; 99    = 
; 100   = 
; 101   = 
; 102   = 
; 103   = 
; 104   = 
; 105   = 
; 106   = 
; 107   = 
; 108   = 
; 109   = 
; 110   = 
; 111   = 
; 112   = 
; 113   = 
; 114   = 
; 115   = 
; 116   = 
; 117   = 
; 118   = 
; 119   = 
; 120   = 
; 121   = 
; 122   = 
; 123   = 
; 124   = 
; 125   = 
; 126   = 
; 127   = 
; 128   = 
; 129   = 
; 130   = 
; 131   = 
; 132   = 
; 133   = 
; 134   = 
; 135   = 
; 136   = 
; 137   = 
; 138   = 
; 139   = 
; 140   = 
; 141   = 
; 142   = 
; 143   = 
; 144   = 
; 145   = 
; 146   = 
; 147   = 
; 148   = 
; 149   = 
; 150   = 
; 151   = 
; 152   = 
; 153   = 
; 154   = 
; 155   = 
; 156   = 
; 157   = 
; 158   = 
; 159   = 
; 160   = 
; 161   = 
; 162   = 
; 163   = 
; 164   = 
; 165   = 
; 166   = 
; 167   = 
; 168   = 
; 169   = 
; 170   = 
; 171   = 
; 172   = 
; 173   = 
%let vm_pc = 174
%let vm_r0 = 175
%let vm_r1 = 176
%let vm_r2 = 177
%let vm_r3 = 178
%let vm_r4 = 179
%let vm_r5 = 180
%let vm_r6 = 181
%let vm_r7 = 182
%let vm_r8 = 183
%let vm_r9 = 184
%let vm_r10 = 185
%let vm_r11 = 186
%let vm_r12 = 187
%let vm_r13 = 188
%let vm_r14 = 189
%let vm_r15 = 190
; 191   = 
; 192   = 
; 193   = 
; 194   = 
; 195   = 
; 196   = 
; 197   = 
; 198   = 
; 199   = 
; 200   = 
; 201   = 
; 202   = 
; 203   = 
; 204   = 
; 205   = 
; 206   = 
; 207   = 
; 208   = 
; 209   = 
; 210   = 
; 211   = 
; 212   = 
; 213   = 
; 214   = 
; 215   = 
; 216   = 
; 217   = 
; 218   = 
; 219   = 
; 220   = 
; 221   = 
; 222   = 
; 223   = 
; 224   = 
; 225   = 
; 226   = 
; 227   = 
; 228   = 
; 229   = 
; 230   = 
; 231   = 
; 232   = 
; 233   = 
; 234   = 
; 235   = 
; 236   = 
; 237   = 
; 238   = 
; 239   = 
; 240   = 
; 241   = 
; 242   = 
; 243   = 
; 244   = 
; 245   = 
; 246   = 
; 247   = 
; 248   = 
; 249   = 
; 250   = 
; 251   = 
; 252   = 
; 253   = 
; 254   = 
; 255   = 
