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
; dispatch to the appropriate state handler
; load the current state to r0
clc
fim p0 state
src p0
rdm
; acc *= 2
ral
fim p0 0
xch r1
jun state_dispatch

%pagealign
; jump to the correct entry in the dispatch table
; we can do this without any fancy math on the dispatch table because we're
; P A G E A L I G N E D which is a magic incantation about how bullshit the
; addressing on the 4004 is -- because the jin below (`state_dispatch`) is on
; the same page as us, it dispatches to one of these.
; these must all, obviously, be 2-bytes long, preferably juns
state_dispatch_table:
dispatch_entry_0:  jun hlt0
dispatch_entry_1:  jun hlt1
dispatch_entry_2:  jun hlt2
dispatch_entry_3:  jun hlt3
dispatch_entry_4:  jun hlt4
dispatch_entry_5:  jun hlt5
dispatch_entry_6:  jun hlt6
dispatch_entry_7:  jun hlt7
; dispatch to the appropriate jump table 
state_dispatch: jin p0


; ======= MEMORY LAYOUT ======= 
; Each RAM bank looks roughly the same. Here's space to assign all locations:
; 0     = state (valid values = 0 to 8, inclusive)
%let state = 0
; 1     = 
; 2     = 
; 3     = 
; 4     = 
; 5     = 
; 6     = 
; 7     = 
; 8     = 
; 9     = 
; 10    = 
; 11    = 
; 12    = 
; 13    = 
; 14    = 
; 15    = 
; 16    = 
; 17    = 
; 18    = 
; 19    = 
; 20    = 
; 21    = 
; 22    = 
; 23    = 
; 24    = 
; 25    = 
; 26    = 
; 27    = 
; 28    = 
; 29    = 
; 30    = 
; 31    = 
; 32    = 
; 33    = 
; 34    = 
; 35    = 
; 36    = 
; 37    = 
; 38    = 
; 39    = 
; 40    = 
; 41    = 
; 42    = 
; 43    = 
; 44    = 
; 45    = 
; 46    = 
; 47    = 
; 48    = 
; 49    = 
; 50    = 
; 51    = 
; 52    = 
; 53    = 
; 54    = 
; 55    = 
; 56    = 
; 57    = 
; 58    = 
; 59    = 
; 60    = 
; 61    = 
; 62    = 
; 63    = 
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
; 174   = 
; 175   = 
; 176   = 
; 177   = 
; 178   = 
; 179   = 
; 180   = 
; 181   = 
; 182   = 
; 183   = 
; 184   = 
; 185   = 
; 186   = 
; 187   = 
; 188   = 
; 189   = 
; 190   = 
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
