  .include "variables.asm"
  .include "constants.asm"

  .org $F000

;$F000 - GOOD
;Start of RESET

RESET:
  SEI ; Disable IRQ
  CLD ; Disable Decimal Mode
  LDA #$00 ; Turns PPU Off
  STA PPUCTRL
  LDX #$FF ; Sets Stack Pointer
  TXS

;$F00A - GOOD
;Waits For CPU x2

  LDA #$00
  STA $FFF0 ; UNKNOWN REGISTER
  JSR cpu_wait
  STA $FFF1 ; UNKNOWN REGISTER
  JSR cpu_wait
  STA $FFF0 ; UNKNOWN REGISTER
  JMP vblank_wait

;$F01E - GOOD
;CPU Wait Subroutine (Generates 9475 CPU Cycles)

cpu_wait:
  LDX #$60
  LDY #$08
cpu_wait_loop:
  DEX
  BNE cpu_wait_loop
  DEY
  BNE cpu_wait_loop

  RTS

;$F029 - GOOD
;Waits For Vblank

vblank_wait:
  LDX #$0A
label_00:
  LDA PPUSTATUS
  BPL label_00
  DEX
  BNE label_00

;$F033 - GOOD
;Sets Stack Pointer

  LDX #$FF
  TXS

;$F036 - GOOD
;Clears $0700-$07FF With #$00

  LDA #$07
  STA <tmp_01
  LDA #$00
  STA <tmp_00
  TAY
label_01:
  STA [tmp_00], Y
  INY
  BNE label_01
  DEC <tmp_01
  BPL label_01

;$F048 - GOOD
;Sets PPUMASK and PPUCTRL

  LDA #$06 ;Allows Sprites & Background In Leftmost 8 Pixels
  STA <ppumask
  STA PPUMASK

  LDA #$80 ; Turns On NMI
  STA <ppuctrl
  STA PPUCTRL 

;$F056

  DEC variable_2B
  JMP label_23

;$F05C - GOOD
;Reads Controllers 01 & 02

read_controllers:
  LDA #$01 ; Latch Controllers
  STA CTRL_SHIFT
  LDA #$00
  STA CTRL_SHIFT

  LDY #$08 ; Read Controller 01
read_controller_01_loop:
  LDA CTRL_01
  ROR A
  ROL <controller_01
  DEY
  BNE read_controller_01_loop

  LDY #$08 ; Read Controller 02
read_controller_02_loop:
  LDA CTRL_02
  ROR A
  ROL <controller_02
  DEY
  BNE read_controller_02_loop

  RTS

;$F07D - GOOD
;Start of NMI

NMI:
  PHA
  TXA
  PHA
  TYA
  PHA
  LDA <variable_0C
  BNE label_02
  JSR sprite_dma
  JSR subroutine_03

;$F08C - GOOD
;Sets Scroll

  LDA scroll_x ; Set Scroll Y
  STA PPUSCROLL
  LDA scroll_y ; Set Scroll Y
  STA PPUSCROLL

;$F098

  LDA <ppuctrl
  STA PPUCTRL
label_02:
  LDA #$01
  STA variable_49

;$F0A2 - GOOD
;Restores Registers

  PLA
  TAY
  PLA
  TAX
  PLA

;$F0A7 - GOOD
;Returns From Interrupt

  RTI

;$F0A8

subroutine_00:
  STX <variable_17
  STY <variable_18
  JSR subroutine_06
  LDY #$00
  LDA [variable_39], Y
  STA <variable_0D
  INY
  LDA [variable_39], Y
  STA <variable_0E
  LDA variable_39
  CLC
  ADC #$02
  STA variable_39
  LDA variable_3A
  ADC #$00
  STA variable_3A
  LDA #$00
  STA <variable_16
label_03:
  LDA #$00
  STA <variable_15
label_04:
  JSR subroutine_01
  INC <variable_15
  LDA <variable_15
  CMP <variable_0D
  BNE label_04
  INC <variable_16
  LDA <variable_16
  CMP <variable_0E
  BNE label_03

  RTS

;$F0E7

subroutine_01:
  LDA <variable_16
  LDX <variable_0D
  JSR subroutine_02
  CLC
  ADC <variable_15
  STA variable_40
  LSR A
  TAY
  LDA [variable_39], Y
  STA <variable_04
  LDA variable_40
  AND #$01
  BEQ label_05
  LDA <variable_04
  AND #$0F
  JMP label_06
label_05:
  LDA <variable_04
  LSR A
  LSR A
  LSR A
  LSR A
label_06:
  STA <variable_19
  LDA <variable_17
  CLC
  ADC <variable_15
  SEC
  SBC #$04
  STA <variable_1E
  LDA <variable_18
  CLC
  ADC <variable_16
  STA <variable_1F
  LDA <variable_1F
  ASL A
  ASL A
  ASL A
  STA <variable_20
  LDA #$00
  ASL <variable_20
  ROL A
  ASL <variable_20
  ROL A
  CLC
  ADC <variable_05
  STA <variable_21
  LDA <variable_20
  CLC
  ADC <variable_1E
  STA <variable_20
  LDA <variable_21
  ADC #$00
  STA <variable_21
  LDA <variable_21
  STA $0441
  LDA <variable_20
  STA $0442
  LDA <variable_19
  STA $0443
  LDA #$01
  STA $0440
  JSR subroutine_04

  RTS

;$F15A

subroutine_02:
  STA <variable_27
  LDA #$00
  CPX #$00
  BEQ label_08
  CLC
label_07:
  ADC <variable_27
  DEX
  BNE label_07
label_08:

  RTS

;$F169 - GOOD
;Sets Sprite DMA At $0200

sprite_dma:
  LDA #LOW(SPRITES)
  STA OAMADDR
  LDA #HIGH(SPRITES)
  STA OAMDMA

  RTS

;$F174

subroutine_03:
  LDA #$64
  STA <variable_2C
  LDY <variable_29
label_09:
  CPY <variable_2A
  BEQ label_0B
  LDA PALETTES, Y
  TAX
  CLC
  ADC #$05
  STA <variable_28
  LDA <variable_2C
  SEC
  SBC <variable_28
  BCC label_0B
  STA <variable_2C
  LDA <variable_2B
  CLC
  ADC PALETTES, Y
  ADC #$03
  STA <variable_2B
  INY
  LDA PALETTES, Y
  STA PPUADDR
  INY
  LDA PALETTES, Y
  STA PPUADDR
  INY
label_0A:
  LDA PALETTES, Y
  STA PPUDATA
  INY
  DEX
  BNE label_0A
  JMP label_09
label_0B:
  STY <variable_29

  RTS

;$F1B9

subroutine_04:
label_0C:
  LDA $0440
  CLC
  ADC #$03
  STA <variable_04
  LDA <variable_2B
  CMP <variable_04
  BCS label_0D
  LDA <variable_0C
  BEQ label_0C
  JSR subroutine_03
  JMP label_0C
label_0D:
  SEC
  SBC <variable_04
  STA <variable_2B
  LDX #$00
  LDY <variable_2A
label_0E:
  LDA $0440, X
  STA PALETTES, Y
  INX
  INY
  CPX <variable_04
  BNE label_0E
  STY <variable_2A

  RTS

;$F1E9

subroutine_05:
  STA <variable_31
  JSR subroutine_06
  LDY #$00
  LDA [variable_39], Y
  STA <variable_34
  TAX
  INY
  LDA [variable_39], Y
  STA <variable_35
  JSR subroutine_02
  STA <variable_37
  CLC
  ADC #$02
  JSR subroutine_0F
  STA <variable_38
  TAX
  LDA $0563, X
  TAX
  LDA <variable_34
  STA $0595, X
  LDA <variable_35
  STA $0596, X
  INX
  INX
  LDY #$FF
label_0F:
  INY
  LDA $0463, Y
  BNE label_0F
  TYA
  STA $0595, X
  INX
  DEC <variable_37
  BNE label_0F
  LDX <variable_38
  LDA <variable_31
  JSR subroutine_08
  LDX <variable_38
  JSR subroutine_07
  LDA <variable_38

  RTS

;$F238

subroutine_06:
  STA <variable_04
  LDA #$BE
  STA <variable_39
  LDA #$FE
  STA <variable_3A
  LDA <variable_04
  BPL label_10
  INC <variable_3A
label_10:
  ASL A
  TAY
  LDA [variable_39], Y
  PHA
  INY
  LDA [variable_39], Y
  CLC
  ADC #$BE
  STA <variable_39
  PLA
  ADC #$FE
  STA <variable_3A

  RTS

;$F25B

subroutine_07:
label_11:
  LDA $0563, X
  TAX
  LDA $0595, X
  STA <variable_34
  LDA $0596, X
  STA <variable_35
  INX
  INX
  LDA <variable_2F
  STA <variable_3C
  LDA <variable_30
  STA <variable_3D
label_12:
  LDA <variable_3D
  BNE label_17
  LDA <variable_34
  STA <variable_3B
  LDA <variable_2D
  STA <variable_3E
  LDA <variable_2E
  STA <variable_3F
label_13:
  LDA <variable_3F
  BNE label_14
  LDA $0595, X
  TAY
  LDA $0523, Y
  BEQ label_14
  LDA <variable_3E
  STA $04A3, Y
  LDA <variable_3C
  STA $04E3, Y
  INX
  JMP label_15
label_14:
  LDA $0595, X
  TAY
  LDA #$FF
  STA $04E3, Y
  INX
label_15:
  LDA <variable_3E
  CLC
  ADC #$08
  STA <variable_3E
  LDA <variable_3F
  ADC #$00
  STA <variable_3F
  DEC <variable_3B
  BNE label_13
label_16:
  LDA <variable_3C
  CLC
  ADC #$08
  STA <variable_3C
  LDA <variable_3D
  ADC #$00
  STA <variable_3D
  DEC <variable_35
  BNE label_12

  RTS

label_17:

;$F2CB

  LDA <variable_34
  STA <variable_3B
label_18:
  LDA $0595, X
  TAY
  LDA #$FF
  STA $04E3, Y
  INX
  DEC <variable_3B
  BNE label_18
  JMP label_16

;$F2E0

subroutine_08:
  STA <variable_31
  LDA $0563, X
  CLC
  ADC #$02
  PHA
  LDA <variable_31
  JSR subroutine_06
  LDY #$00
  LDA [variable_39], Y
  STA <variable_34
  INY
  LDA [variable_39], Y
  STA <variable_35
  LDA #$00
  ORA #$1C
  LDX <variable_33
  STA <variable_36
  LDA #$02
  LDY #$01
  STY <variable_41
  STA <variable_40
  LDA #$00
  STA <variable_42
  PLA
  TAX
label_19:
  LDA <variable_34
  STA <variable_3B
label_1A:
  LDA <variable_40
  LSR A
  CLC
  ADC #$01
  TAY
  LDA [variable_39], Y
  STA <variable_04
  LDA <variable_40
  AND #$01
  BEQ label_1B
  LDA <variable_04
  AND #$0F
  JMP label_1C
label_1B:
  LDA <variable_04
  LSR A
  LSR A
  LSR A
  LSR A
label_1C:
  PHA
  LDA $0595, X
  TAY
  PLA
  STA $0523, Y
  LDA <variable_36
  STA $0463, Y
  INX
  LDA <variable_40
  CLC
  ADC <variable_41
  STA <variable_40
  DEC <variable_3B
  BNE label_1A
  LDA <variable_40
  CLC
  ADC <variable_42
  STA <variable_40
  DEC <variable_35
  BNE label_19

  RTS

;$F357

subroutine_09:
  LDA <variable_43
  EOR #$01
  STA <variable_43
  BNE label_1F
  LDY #$08
  LDX #$3D
label_1D:
  LDA $0463, X
  BEQ label_1E
  JSR subroutine_0A
  DEX
  BPL label_1D

  RTS

;$F36F

label_1E:
  JSR subroutine_0B
  DEX
  BPL label_1D

  RTS

;$F376

label_1F:
  LDY #$08
  LDX #$00
label_20:
  LDA $0463, X
  BEQ label_21
  JSR subroutine_0A
  INX
  CPX #$3E
  BNE label_20

  RTS

;$F388

label_21:
  JSR subroutine_0B
  INX
  CPX #$3E
  BNE label_20

  RTS

;$F391

subroutine_0A:
  STA SPRITES+2, Y
  LDA $04E3, X
  STA SPRITES, Y
  LDA $0523, X
  STA SPRITES+1, Y
  LDA $04A3, X
  STA SPRITES+3, Y
  INY
  INY
  INY
  INY

  RTS

;$F3AB

subroutine_0B:
  LDA #$FF
  STA SPRITES, Y
  INY
  INY
  INY
  INY

  RTS

;$F3B5

subroutine_0C:
label_22:
  LDA <variable_1F
  AND #$01
  ASL A
  STA <variable_04
  LDA <variable_1E
  AND #$01
  ORA <variable_04
  TAY
  LDA <variable_1F
  ASL A
  ASL A
  AND #$F8
  STA <variable_04
  LDA <variable_1E
  LSR A
  CLC
  ADC <variable_04
  TAX
  ORA #$C0
  STA $0442
  LDA #$23
  STA $0441
  LDA #$01
  STA $0440
  LDA data_00, Y
  AND <variable_1A
  STA <variable_04
  LDA data_00, Y
  EOR #$FF
  AND $0400, X
  ORA <variable_04
  STA $0400, X
  STA $0443
  JMP label_0C

;$F3FB

data_00:
  .db $03, $0C, $30, $C0

;$F3FF

data_01:
  .db $0D, $00, $00, $2C
  .db $00, $00, $00, $26
  .db $00, $00, $00, $20
  .db $00, $00, $00, $00
  .db $0D, $00, $00, $13
  .db $00, $00, $00, $26
  .db $00, $00, $00, $20
  .db $00, $00, $00, $28

;$F41F

label_23:
  LDA #$01
  STA <variable_0C
  LDA #$20
  STA <variable_05
  STA PPUADDR
  LDA #$00
  STA PPUADDR
  LDX #$04
  TAY
label_24:
  STA PPUDATA
  DEY
  BNE label_24
  DEX
  BNE label_24
  JSR subroutine_10
  LDX #$00
  LDA #$00
label_25:
  STA $0563, X
  INX
  CPX #$32
  BNE label_25
  JSR sprite_dma
  LDA #$0E
  STA variable_50
  STA <variable_2D
  LDA #$3C
  STA variable_51
  STA <variable_2F
  LDA #$80
  STA variable_55
  LDA #$96
  STA variable_56
  LDA #$14
  JSR subroutine_05
  STA variable_4F
  LDA #$02
  JSR subroutine_05
  STA variable_54
  LDA #$FF
  STA <variable_2F
  LDA #$05
  JSR subroutine_05
  STA variable_7B
  LDX #$13
label_26:
  LDA data_03, X
  STA $0463, X
  DEX
  BPL label_26
  LDA #$09 ; DMC + Square 1
  STA APUFLAGS
  LDA #$20
  STA $0440
  LDA #$3F
  STA $0441
  LDA #$00
  STA $0442
  LDY #$00
label_27:
  LDA data_01, Y
  STA $0443, Y
  INY
  CPY #$20
  BNE label_27
  JSR subroutine_04
  LDA #$00
  STA <variable_0C
  JSR subroutine_0D
  LDA <ppumask
  ORA #$18
  STA <ppumask
  STA PPUMASK
label_28:
  JSR subroutine_0E
  JSR subroutine_0D
  JMP label_28

subroutine_0D:
  LDA #$00
  STA variable_49
label_29:
  LDA variable_49
  BEQ label_29

  RTS

;$F4D4

subroutine_0E:
  JSR read_controllers
  JSR subroutine_11
  JSR subroutine_1C
  JSR subroutine_21
  JSR subroutine_2B
  JSR subroutine_2D
  JSR subroutine_19 ; Listen For A Press
  JSR subroutine_1A ; Listen For B PRess
  JSR subroutine_30 ; Listen For Start + Select Press
  LDA variable_50
  STA <variable_2D
  LDA variable_51
  STA <variable_2F
  LDX variable_4F
  JSR subroutine_07
  JSR subroutine_09

  RTS

;$F503

check_controller:
  LDA variable_5A
  BNE check_controller_vertical_done

check_controller_vertical: ; Check Controller Vertical
check_controller_up: ; Check Controller Up
  LDA <controller_01
  AND #CONTROLLER_UP
  BEQ check_controller_up_done
  LDA #$08
  JSR subroutine_14
  BEQ check_controller_up_done
  LDA #$3F
  STA variable_59
  LDA #$F7
  STA variable_5A
  LDA #$08
  JSR subroutine_13
  BEQ label_2A
  LDA #$20
  JMP label_2B
label_2A:
  LDA #$00
label_2B:
  STA variable_5B
  LDA #$08
  STA variable_5E
  JMP check_controller_vertical_done
check_controller_up_done:

check_controller_down: ; Check Controller Down
  LDA <controller_01
  AND #CONTROLLER_DOWN
  BEQ check_controller_down_done
  LDA #$04
  JSR subroutine_14
  BEQ check_controller_down_done
  LDA #$FF
  STA variable_59
  LDA #$F6
  STA variable_5A
  LDA #$04
  JSR subroutine_13
  BEQ label_2C
  LDA #$20
  JMP label_2D
label_2C:
  LDA #$00
label_2D:
  STA variable_5B
  LDA #$04
  STA variable_5E
check_controller_down_done:
check_controller_vertical_done:

  LDA variable_58
  BNE check_controller_done

check_controller_horizontal:
check_controller_left: ; Check Controller Left
  LDA <controller_01
  AND #CONTROLLER_LEFT
  BEQ check_controller_left_done
  LDA #$02
  JSR subroutine_14
  BEQ check_controller_left_done
  LDA #$3F
  STA variable_57
  LDA #$F7
  STA variable_58
  LDA #$00
  STA variable_5C
  LDA #$02
  STA variable_5D
  JMP check_controller_horizontal_done
check_controller_left_done:

check_controller_right:
  LDA <controller_01 ; Check Controller Right
  AND #CONTROLLER_RIGHT
  BEQ check_controller_right_done
  LDA #$01
  JSR subroutine_14
  BEQ check_controller_right_done
  LDA #$FF
  STA variable_57
  LDA #$F6
  STA variable_58
  LDA #$00
  STA variable_5C
  LDA #$01
  STA variable_5D
check_controller_right_done:
check_controller_horizontal_done:
check_controller_done:

  RTS

;$F5B0

subroutine_0F:
  STA <variable_04
  LDX #$FF
label_2E:
  INX
  LDA $0564, X
  CMP $0563, X
  BNE label_2E
  STX <variable_4B
  STA <variable_4A
  INX
label_2F:
  LDA <variable_04
  CLC
  ADC $0563, X
  STA $0563, X
  INX
  CPX #$32
  BNE label_2F
  LDA <variable_4B

  RTS

;$F5D3

subroutine_10:
  LDA #$00
  STA <scroll_x
  LDA #$04
  STA <scroll_y
  LDA #$01
  LDX #$05
  LDY #$03
  JSR subroutine_00
  LDA #$03
  STA <variable_4C
  LDA #$04
  STA <variable_4D
  LDA #$08
  STA <variable_4E
label_30:
  LDA <variable_4C
  LDX <variable_4D
  LDY <variable_4E
  JSR subroutine_00
  LDA <variable_4D
  CLC
  ADC #$04
  STA <variable_4D
  CMP #$24
  BNE label_31
  LDA #$04
  STA <variable_4D
  LDA <variable_4E
  CLC
  ADC #$04
  STA <variable_4E
label_31:
  INC <variable_4C
  LDA <variable_4C
  CMP #$13
  BNE label_30
  LDA #$03
  STA <variable_4C
  LDA #$04
  STA <variable_4D
  LDA #$12
  STA <variable_4E
label_32:
  LDA #$13
  LDX <variable_4D
  LDY <variable_4E
  JSR subroutine_00
  LDA <variable_4D
  CLC
  ADC #$04
  STA <variable_4D
  CMP #$24
  BNE label_33
  LDA #$04
  STA <variable_4D
  LDA <variable_4E
  CLC
  ADC #$04
  STA <variable_4E
label_33:
  INC <variable_4C
  LDA <variable_4C
  CMP #$1B
  BNE label_32
  LDA #$55
  LDX #$04
  LDY #$00
  JSR subroutine_2C
  LDA #$00
  LDX #$04
  LDY #$04
  JSR subroutine_2C
  LDA #$AA
  LDX #$02
  LDY #$09
  JSR subroutine_2C
  LDA #$FF
  LDX #$04
  LDY #$0B
  JSR subroutine_2C
  LDX #$00
  LDY #$00
  JSR subroutine_15
  LDA #$02
  STA code_line

  RTS

;$F67B

subroutine_11:
  LDA <variable_5F
  EOR #$01
  STA <variable_5F
  BNE label_34
  JSR check_controller
label_34:
  LDA <variable_58
  BEQ label_38
  LDY <variable_5C
  LDA [variable_57], Y
  CMP #$80
  BNE label_35
  LDA #$00
  STA <variable_58
  JMP label_36
label_35:
  LDX #$50
  JSR subroutine_12
  BEQ label_38
label_36:
  TYA
  AND #$0F
  CMP #$07
  BNE label_37
  JSR subroutine_18
  LDA <controller_01
  AND <variable_5D
  BEQ label_37
  LDA <variable_5D
  JSR subroutine_14
  BEQ label_37
  LDY #$0F
label_37:
  INY
  STY <variable_5C
label_38:
  LDA <variable_5A
  BEQ label_3D
  LDY <variable_5B
  LDA [variable_59], Y
  CMP #$80
  BNE label_39
  LDA #$00
  STA <variable_5A
  JMP label_3A
label_39:
  LDX #$51
  JSR subroutine_12
  BEQ label_3D
label_3A:
  TYA
  AND #$0F
  CMP #$07
  BNE label_3C
  JSR subroutine_18
  LDA <controller_01
  AND <variable_5E
  BEQ label_3C
  LDA <variable_5E
  JSR subroutine_14
  BEQ label_3C
  LDA <variable_5E
  JSR subroutine_13
  BEQ label_3B
  LDY #$2F
  JMP label_3C
label_3B:
  LDY #$0F
label_3C:
  INY
  STY <variable_5B
label_3D:

  RTS

;$F6FF

data_02:
  .db $01, $01, $02, $02, $03, $03, $04, $04
  .db $03, $03, $02, $02, $02, $01, $ff, $80
  .db $05, $04, $04, $03, $03, $04, $05, $04
  .db $03, $03, $02, $02, $02, $01, $ff, $80
  .db $02, $03, $04, $05, $06, $06, $06, $04
  .db $03, $03, $02, $02, $02, $01, $ff, $80
  .db $05, $06, $07, $08, $07, $06, $05, $04
  .db $03, $03, $02, $02, $02, $01, $ff, $80
  .db $ff, $ff, $fe, $fe, $fd, $fd, $fc, $fc
  .db $fd, $fd, $fe, $fe, $fe, $ff, $01, $80
  .db $fb, $fc, $fc, $fd, $fd, $fc, $fb, $fc
  .db $fd, $fd, $fe, $fe, $fe, $ff, $01, $80
  .db $fe, $fd, $fc, $fb, $fa, $fa, $fa, $fc
  .db $fd, $fd, $fe, $fe, $fe, $ff, $01, $80
  .db $fb, $fa, $f9, $f8, $f9, $fa, $fb, $fc
  .db $fd, $fd, $fe, $fe, $fe, $ff, $01, $80

;$F77F

subroutine_12:
  PHA
  ASL A
  PLA
  ROR A
  DEC <variable_5F
  BEQ label_3E
  CLC
label_3E:
  ADC <tmp_00, X
  STA <tmp_00, X
  INC <variable_5F

  RTS

;$F78F

subroutine_13:
  CMP #$04
  BNE label_3F
  LDA <cursor_y_begin
  CMP #$02
  BNE label_40
  LDA #$01

  RTS

;$F79C

label_3F:
  CMP #$08
  BNE label_40
  LDA <cursor_y_begin
  CMP #$01
  BNE label_40
  LDA #$01

  RTS

;$F7A9

label_40:
  LDA #$00

  RTS

;$F7AC

subroutine_14:
  CMP #$01
  BNE label_41
  LDA <cursor_x_begin
  CMP #$07
  BEQ label_45
  INC <cursor_x_begin
  JMP label_44
label_41:
  CMP #$02
  BNE label_42
  LDA <cursor_x_begin
  BEQ label_45
  DEC <cursor_x_begin
  JMP label_44
label_42:
  CMP #$04
  BNE label_43
  LDA <cursor_y_begin
  CMP #$04
  BEQ label_45
  INC <cursor_y_begin
  JMP label_44
label_43:
  CMP #$08
  BNE label_44
  LDA <cursor_y_begin
  BEQ label_45
  DEC <cursor_y_begin
  JMP label_44
label_44:
  LDA #$01

  RTS

;$F7E7

label_45:
  LDA #$00

  RTS

;$F7EA

subroutine_15:
  LDA #$AA
subroutine_16:
label_46:
  STA <variable_1A
  TXA
  ASL A
  STA <variable_1E
  TYA
  ASL A
  CLC
  ADC #$04
  CMP #$08
  BCC label_47
  CLC
  ADC #$01
label_47:
  STA <variable_1F
  JSR subroutine_0C
  INC <variable_1E
  JSR subroutine_0C
  INC <variable_1F
  JSR subroutine_0C
  DEC <variable_1E
  JMP label_22

;$F812

subroutine_17:
  LDA #$00
  JMP label_46

;$F817

subroutine_18:
  TYA
  PHA
  LDX <variable_60
  LDY <variable_61
  JSR subroutine_17
  LDA <cursor_y_begin
  CMP #$02
  BCS label_48
  STA <variable_61
  STA <cursor_y_end
  LDA <cursor_x_begin
  STA <variable_60
  STA <cursor_x_end
  LDX <variable_60
  LDY <variable_61
  JSR subroutine_15
  PLA
  TAY

  RTS

;$F83A

label_48:
  STA <cursor_y_end
  LDA <cursor_x_begin
  STA <cursor_x_end
  PLA
  TAY

  RTS

;$F843

data_03:
  .db $19, $19, $19, $19
  .db $1A
  .db $19, $19, $19, $19
  .db $1A
  .db $19, $19, $19, $19
  .db $1A
  .db $19, $19, $19, $19
  .db $1A

;$F857

label_49:
  LDA $0477
  CMP #$1A
  BNE label_4A
  LDA #$18
  JMP label_4B
label_4A:
  LDA #$1A
label_4B:
  LDX variable_6D
  CPX #$07
  BCS label_4C
  ORA #$20
label_4C:
  STA $0477
  STA $0478
  STA $0479
  STA $047A

  RTS

;$F87B

label_4D:
  LDA <cursor_y_end
  ASL A
  ASL A
  ASL A
  CLC
  ADC <cursor_x_end
  ADC #$03
  PHA
  LDA <variable_65
  ASL A
  ASL A
  CLC
  ADC #$12
  TAY
  LDA <variable_64
  ASL A
  ASL A
  CLC
  ADC #$04
  TAX
  PLA
  PHA
  JSR subroutine_00
  JSR subroutine_2A
  PLA
  JSR subroutine_26
  JMP label_4E
label_4E:
  INC <variable_64
  LDA <variable_64
  CMP #$06
  BNE label_4F
  LDA <variable_65
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$02
  TAX
  LDA CODES, X
  SEC
  SBC #$03
  AND #$01
  BEQ label_50
  LDA <variable_64
label_4F:
  CMP #$08
  BNE label_52
label_50:
  LDA <variable_65
  CMP #$02
  BEQ label_51
  LDA #$00
  STA <variable_64
  INC <variable_65
  JMP label_52
label_51:
  DEC <variable_64
label_52:
  JMP label_87

;$F8DA

subroutine_19:
  LDA <controller_01
  AND #CONTROLLER_A
  CMP <variable_66
  BNE label_53

  RTS

;$F8E3

label_53:
  STA <variable_66
  CMP #$80
  BEQ label_54

  RTS

;$F8EA

label_54:
  LDA <cursor_y_end
  CMP #$02
  BCS label_55
  JMP label_4D
label_55:
  JMP label_62

;$F8F6

subroutine_1A:
  LDA <controller_01
  AND #CONTROLLER_B
  CMP <variable_67
  BNE label_56

  RTS

;$F8FF

label_56:
  STA <variable_67
  CMP #$40
  BEQ label_57

  RTS

;$F906

label_57:
  JMP label_58
label_58:
  LDA <variable_64
  BEQ label_5C
  LDA <variable_65
  CMP #$02
  BNE label_5B
  LDA $067D
  SEC
  SBC #$03
  AND #$01
  BNE label_59
  LDA #$05
  BNE label_5A
label_59:
  LDA #$07
label_5A:
  CMP <variable_64
  BNE label_5B
  TAX
  LDA CODES+16, X
  BNE label_5D
label_5B:
  JSR subroutine_28
  BNE label_5E
label_5C:
  LDA <variable_64
  ORA <variable_65
  BEQ label_5E
  JSR subroutine_1B
label_5D:
  LDA <variable_65
  ASL A
  ASL A
  CLC
  ADC #$12
  TAY
  LDA <variable_64
  ASL A
  ASL A
  CLC
  ADC #$04
  TAX
  JSR subroutine_25
  LDA #$13
  JSR subroutine_00
  LDA #$00
  JMP label_7D
label_5E:
  JMP label_5F

;$F95B

subroutine_1B:
label_5F:
  DEC <variable_64
  LDA <variable_64
  CMP #$FF
  BNE label_61
  LDA <variable_65
  BEQ label_60
  LDA #$07
  STA <variable_64
  DEC <variable_65
  JMP label_61
label_60:
  INC <variable_64
label_61:
  JSR subroutine_27
  JMP label_87

;$F978

label_62:
  LDA <cursor_y_end
  SEC
  SBC #$02
  STA <variable_65
  LDA <cursor_x_end
  STA <variable_64
  JSR subroutine_27
  TXA
  PHA
  TYA
  PHA
  JSR subroutine_2E
  PLA
  TAY
  PLA
  TAX

  RTS

;$F992

subroutine_1C:
  LDA <variable_65
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$98
  STA <variable_69
  LDA <variable_64
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$0A
  STA <variable_68
  LDA <variable_55
  STA variable_6E
  LDA <variable_68
  STA variable_6F
  JSR subroutine_1D
  CLC
  ADC #$80
  STA <variable_6A
  LDA <variable_6B
  JSR subroutine_1E
  STA <variable_6B
  LDA <variable_56
  STA variable_6E
  LDA <variable_69
  STA variable_6F
  JSR subroutine_1D
  CLC
  ADC #$80
  STA <variable_6A
  LDA <variable_6C
  JSR subroutine_1E
  STA <variable_6C
  LDA <variable_55
  CLC
  ADC <variable_6B
  STA <variable_55
  LDA <variable_56
  CLC
  ADC <variable_6C
  STA <variable_56
  LDX <variable_6D
  LDA <variable_55
  CLC
  ADC data_04, X
  STA <variable_2D
  LDA <variable_56
  CLC
  ADC data_05, X
  STA <variable_2F
  INX
  CPX #$10
  BNE label_63
  LDX #$00
label_63:
  STX <variable_6D
  LDX <variable_54
  JSR subroutine_07
  JMP label_49

;$FA0D

data_04:
  .db $00, $04, $07, $09, $0A, $09, $07, $04
  .db $00, $FC, $F9, $F7, $F6, $F7, $F9, $FC
  .db $00

;$FA1E

data_05:
  .db $F6, $F7, $F9, $FC, $00, $04, $07, $09
  .db $0A, $09, $07, $04, $00, $FC, $F9, $F7
  .db $F6

;$FA2F

subroutine_1D:
  LDA <variable_6E
  CMP <variable_6F
  BCC label_66
  BNE label_64
  LDA #$00

  RTS

;$FA3A

label_64:
  LDA <variable_6F
  SEC
  SBC <variable_6E
  LDX #$03
label_65:
  SEC
  ROR A
  DEX
  BNE label_65

  RTS

;$FA47

label_66:
  LDA <variable_6F
  SEC
  SBC <variable_6E
  LDX #$03
label_67:
  LSR A
  DEX
  BNE label_67
  CLC
  ADC #$01

  RTS

;$FA56

subroutine_1E:
  EOR #$80
  CMP <variable_6A
  BCC label_68
  BEQ label_69
  SBC #$01
  JMP label_69
label_68:
  ADC #$01
label_69:
  EOR #$80

  RTS

;$FA68

subroutine_1F:
  LDA <variable_72
  BEQ label_6A
  LDA #$00
  STA <variable_72
  LDX #$30
  JSR subroutine_20
  LDA #$01
  STA <variable_74

  RTS

;$FA7A

label_6A:
  LDA #$01
  STA <variable_72
  LDX #$20
  JSR subroutine_20
  LDA #$01
  STA <variable_73

  RTS

;$FA88

data_06:
  .db $00, $06, $08, $06, $00, $FA, $F8, $FA
  .db $00, $03, $04, $03, $00, $FD, $FC, $FD

;$FA98

data_07:
  .db $F8, $FA, $00, $06, $08, $06, $00, $FA
  .db $FC, $FD, $00, $03, $04, $03, $00, $FD

;$FAA8

subroutine_20:
  LDY #$00
label_6B:
  LDA data_06, Y
  CLC
  ADC <variable_70
  STA $04A3, X
  LDA data_07, Y
  CLC
  ADC <variable_71
  STA $04E3, X
  LDA data_06, Y
  STA $060B, X
  LDA data_07, Y
  STA $062B, X
  LDA #$01
  STA $0523, X
  LDA #$1A
  STA $0463, X
  INX
  INY
  CPY #$10
  BNE label_6B
  LDA #$0E
  STA NOISE_LO
  LDA #$04
  STA NOISE_HI
  LDA #$25
  STA NOISE_VOL
  LDA #$18
  STA <variable_75

  RTS

;$FAEC

subroutine_21:
  LDA <variable_75
  BEQ label_6C
  DEC <variable_75
  BNE label_6C
  LDA #$30
  STA NOISE_VOL
label_6C:
  LDA <variable_73
  BEQ label_6D
  LDX #$20
  INC <variable_73
  LDA <variable_73
  CMP #$18
  BEQ label_6F
  JSR subroutine_22
label_6D:
  LDA <variable_74
  BEQ label_6E
  LDX #$30
  INC <variable_74
  LDA <variable_74
  CMP #$18
  BEQ label_70
  JSR subroutine_22
label_6E:

  RTS

;$FB1C

label_6F:
  LDA #$00
  STA <variable_73
  JSR subroutine_24
  JMP label_6D
label_70:
  LDA #$00
  STA <variable_74
  JMP label_7A

;$FB2D

subroutine_22:
  AND #$07
  STA <variable_04
  LDY #$10
label_71:
  LDA $04E3, X
  CMP #$FF
  BEQ label_77
  LDA $0463, X
  EOR #$02
  STA $0463, X
  LDA $060B, X
  BPL label_72
  CLC
  ADC $04A3, X
  BCS label_74
  JMP label_73
label_72:
  CLC
  ADC $04A3, X
  BCC label_74
label_73:
  LDA #$FF
  STA $04E3, X
  LDA #$00
  STA $0463, X
  JMP label_77
label_74:
  STA $04A3, X
  LDA $062B, X
  BPL label_75
  CLC
  ADC $04E3, X
  BCS label_76
  JMP label_73
label_75:
  CLC
  ADC $04E3, X
  BCS label_73
label_76:
  STA $04E3, X
  LDA <variable_04
  BNE label_77
  LDA $060B, X
  JSR subroutine_23
  STA $060B, X
  LDA $062B, X
  JSR subroutine_23
  STA $062B, X
label_77:
  INX
  DEY
  BNE label_71

  RTS

;$FB98

subroutine_23:
  BEQ label_79
  BPL label_78
  CLC
  ADC #$01

  RTS

;$FBA0

label_78:
  SEC
  SBC #$01
label_79:

  RTS

;$FBA4

subroutine_24:
label_7A:
  LDY #$10
label_7B:
  LDA #$00
  STA $0463, X
  LDA #$FF
  STA $04E3, X
  INX
  DEY
  BNE label_7B

  RTS

;$FBB5

subroutine_25:
  TYA
  PHA
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$0A
  STA <variable_71
  TXA
  PHA
  SEC
  SBC #$04
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$0D
  STA <variable_70
  JSR subroutine_28
  BEQ label_7C
  JSR subroutine_1F
label_7C:
  PLA
  TAX
  PLA
  TAY

  RTS

;$FBD9

subroutine_26:
label_7D:
  PHA
  JSR subroutine_29
  PLA
  STA CODES, X

  RTS

;$FBE2

subroutine_27:
  JSR subroutine_29
  LDA <variable_64
  BEQ label_7F
  LDA CODES, X
  BNE label_7F
label_7E:
  DEX
  LDA CODES, X
  BNE label_7F
  DEC <variable_64
  BNE label_7E
label_7F:
  RTS

;$FBF9

subroutine_28:
  JSR subroutine_29
  LDA CODES, X

  RTS

;$FC00

subroutine_29:
  LDA <variable_65
  ASL A
  ASL A
  ASL A
  CLC
  ADC <variable_64
  TAX

  RTS

;$FC0A

subroutine_2A:
  LDA <cursor_x_end
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  STA <variable_76
  STA <variable_2D
  LDA <cursor_y_end
  ASL A
  ASL A
  ASL A
  PHA
  ASL A
  ASL A
  CLC
  ADC #$40
  STA <variable_77
  STA <variable_2F
  PLA
  CLC
  ADC <cursor_x_end
  STA variable_7D
  ADC #$03
  LDX <variable_7B
  JSR subroutine_08
  LDX <variable_7B
  JSR subroutine_07
  LDA <variable_65
  ASL A
  ASL A
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$90
  SEC
  SBC <variable_77
  LSR A
  LSR A
  LSR A
  LSR A
  STA <variable_79
  LDA <variable_64
  SEC
  SBC <cursor_x_end
  ASL A
  STA <variable_78
  LDA #$10
  STA <variable_7A
  LDA variable_7D
  ASL A
  ASL A
  ASL A
  ASL A
  STA <variable_04
  LDA #$00
  ASL <variable_04
  ROL A
  ASL <variable_04
  ROL A
  CLC
  ADC #$02
  STA SQ1_HI
  LDA <variable_04
  STA SQ1_LO
  LDA #$24
  STA SQ1_VOL
  LDA #$F9
  STA SQ1_SWEEP
  LDA #$14
  STA variable_7C

  RTS

;$FC82

subroutine_2B:
  LDA <variable_7C
  BEQ label_80
  DEC <variable_7C
  BNE label_80
  LDA #$30
  STA SQ1_VOL
label_80:
  LDA <variable_7A
  BNE label_81

  RTS

;$FC94

label_81:
  DEC <variable_7A
  BNE label_82
  LDX <variable_7B
  LDA #$FF
  STA <variable_2F
  JMP label_11
label_82:
  LDA <variable_76
  CLC
  ADC <variable_78
  STA <variable_76
  STA <variable_2D
  LDA <variable_77
  CLC
  ADC <variable_79
  STA <variable_77
  STA <variable_2F
  LDX <variable_7B
  JMP label_11

;$FCB8

subroutine_2C:
  STA <variable_1A
  STY <variable_1F
  STX <variable_7E
label_83:
  LDA #$00
label_84:
  STA <variable_1E
  JSR subroutine_0C
  LDA <variable_1E
  CLC
  ADC #$01
  CMP #$10
  BNE label_84
  INC <variable_1F
  DEC <variable_7E
  BNE label_83

  RTS

;$FCD5

subroutine_2D:
  LDX <variable_7F
  LDY <variable_80
  INY
  CPY #$05
  BNE label_85
  LDY #$00
  INX
label_85:
  STY <variable_80
  CPX #$08
  BNE label_86
  LDX #$00
label_86:
  STX <variable_7F
  LDA data_08, X
  STA $0443
  LDA #$01
  STA $0440
  LDA #$3F
  STA $0441
  LDA #$07
  STA $0442
  JMP label_0C

;$FD03

data_08:
  .db $21, $2C, $2B, $28, $27, $25, $24, $2C

;$FD0B

subroutine_2E:
label_87:
  LDX <code_digit
  LDY <code_line
  STY <code_line_prev
  LDA #$AA
  JSR subroutine_16
  LDA <variable_65
  CLC
  ADC #$02
  STA <code_line
  LDA <variable_64
  STA <code_digit
  JSR subroutine_2F
  LDX <code_digit
  LDY <code_line
  LDA #$55
  JMP label_46

;$FD2D

data_09:
  .db $AF, $AF, $AF, $AF, $AF, $AF, $AF, $AF
  .db $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA

;$FD3D

subroutine_2F:
  LDA <code_line_prev
  CMP <code_line
  BEQ label_8A
  LDA #$23
  STA $0441
  LDA #$E0
  STA $0442
  LDY #$1F
label_88:
  LDA #$FF
  STA $0443, Y
  STA $0420, Y
  DEY
  BPL label_88
  LDA #$20
  STA $0440
  JSR subroutine_04
  LDA <code_line
  SEC
  SBC #$02
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$E0
  STA $0442
  LDA #$23
  STA $0441
  LDY #$0F
label_89:
  LDA data_09, Y
  STA $0443, Y
  DEY
  BPL label_89
  LDA #$10
  STA $0440
  JSR subroutine_04
label_8A:

  RTS

;$FD89

subroutine_30:
  LDA <controller_01
  AND #CONTROLLER_START_SELECT
  BNE label_8C
  LDA #$01
  STA <variable_84

label_8B:
  RTS

;$FD94

label_8C:
  LDA <variable_84
  BEQ label_8B
  LDA #$00
  STA PPUCTRL
  STA PPUMASK
  LDA #$6B
  STA <variable_80
  LDA #$06
  STA <code_digit
  LDA #$90
  STA <code_line
  LDA #$00
  STA <code_line_prev
  LDX #$0F
  LDA #$FF
label_8D:
  STA <variable_90, X
  DEX
  BPL label_8D
  LDA #$03
  STA <variable_88
  LDA #$EF
  STA <variable_86
  LDA #$02
  STA <variable_87
  LDA #$71
  STA <variable_89
label_8E:
  LDY #$00
  STY <variable_84
label_8F:
  LDA [variable_80], Y
  BEQ label_90
  SEC
  SBC #$03
  AND #$0F
  LSR A
  ORA <variable_84
  STA [variable_80], Y
  LDA #$00
  ROL A
  ASL A
  ASL A
  ASL A
  STA <variable_84
  INY
  CPY #$08
  BNE label_8F
label_90:
  STY <variable_85
  CPY #$08
  BEQ label_91
  CPY #$06
  BEQ label_92
  JMP label_9A
label_91:
  LDY #$03
  LDA [variable_80], Y
  JMP label_93
label_92:
  LDY #$03
  LDA [variable_80], Y
label_93:
  LDY #$00
  LDA [variable_80], Y
  AND #$07
  ORA <variable_84
  STA [variable_80], Y
  LDX #$00
  STX <variable_84
label_94:
  LDY data_0B, X
  LDA [variable_80], Y
  ASL A
  ASL A
  ASL A
  ASL A
  INX
  LDY data_0B, X
  ORA [variable_80], Y
  LDY <variable_84
  STA variable_8A, Y
  INC <variable_84
  INX
  CPX #$08
  BNE label_94
  LDA <variable_8A
  AND #$7F
  STA <variable_8A
  LDA <variable_8A
  LDX <variable_8B
  CMP <variable_90
  BNE label_95
  CPX <variable_91
  BEQ label_9A
label_95:
  CMP <variable_94
  BNE label_96
  CPX <variable_95
  BEQ label_9A
label_96:
  CMP <variable_98
  BNE label_97
  CPX <variable_99
  BEQ label_9A
label_97:
  LDY #$01
label_98:
  LDA variable_8A, Y
  STA [code_line], Y
  DEY
  BPL label_98
  LDY #$03
  LDA variable_89, Y
  STA [code_line], Y
  DEY
  LDA variable_8B, Y
  STA [code_line], Y
  LDA <variable_89
  AND <variable_86
  LDX <variable_85
  CPX #$08
  BNE label_99
  ORA <variable_87
label_99:
  STA <variable_89
label_9A:
  SEC
  ROL <variable_86
  ASL <variable_87
  LDA <variable_80
  CLC
  ADC #$08
  STA <variable_80
  BCC label_9B
  INC <code_digit
label_9B:
  LDA <code_line
  CLC
  ADC #$04
  STA <code_line
  BCC label_9C
  INC <code_line_prev
label_9C:
  DEC <variable_88
  BEQ label_9D
  JMP label_8E
label_9D:
  LDX #$18
label_9E:
  LDA data_0A, X
  STA <variable_10, X
  DEX
  BPL label_9E
  JMP $0010 ; UNKNOWN LABEL
data_0A:
  LDX #$0B
label_9F:
  LDA <variable_90, X
  STA $8001, X ; UNKNOWN REGISTER
  DEX
  BPL label_9F
  LDA <variable_89
  STA $8000 ; UNKNOWN REGISTER
  LDA #$00
  STA $8000 ; UNKNOWN REGISTER
  JMP [RESET_vector]

;$FEB6

data_0B:
  .db $03, $05, $02, $04, $01, $00, $07, $06
  .db $00, $2A, $00, $30, $00, $6E, $00, $72
  .db $00, $7C, $00, $86, $00, $90, $00, $9A
  .db $00, $A4, $00, $AE, $00, $B8, $00, $C2
  .db $00, $CC, $00, $D6, $00, $E0, $00, $EA
  .db $00, $F4, $00, $FE, $01, $08, $01, $12
  .db $01, $1C, $08, $02, $01, $23, $45, $67
  .db $1E, $04, $2C, $C0, $00, $00, $00, $00
  .db $00, $02, $CC, $00, $00, $00, $08, $00
  .db $00, $52, $32, $CC, $5D, $96, $2C, $E4
  .db $05, $23, $2C, $E4, $DC, $6A, $2C, $E4
  .db $60, $2A, $00, $55, $5A, $A0, $40, $06
  .db $02, $A0, $40, $50, $AA, $A0, $40, $0C
  .db $40, $C0, $44, $48, $0C, $C4, $00, $C4
  .db $0C, $C4, $40, $88, $0C, $C4, $02, $02
  .db $B1, $80, $04, $04, $0A, $00, $05, $50
  .db $AC, $E0, $C4, $C4, $04, $04, $8D, $E0
  .db $07, $10, $05, $20, $8C, $C0, $04, $04
  .db $8D, $60, $07, $90, $05, $00, $8C, $00
  .db $04, $04, $09, $60, $A0, $05, $81, $24
  .db $08, $40, $04, $04, $AC, $E0, $02, $40
  .db $24, $20, $8C, $C0, $04, $04, $E4, $E4
  .db $06, $40, $24, $60, $C4, $C4, $04, $04
  .db $8D, $00, $05, $00, $05, $20, $8C, $C0
  .db $04, $04, $E4, $E4, $A0, $A0, $A0, $A0
  .db $0C, $40, $04, $04, $09, $C5, $A0, $31
  .db $81, $05, $08, $C0, $04, $04, $8D, $A4
  .db $07, $40, $05, $60, $8C, $84, $04, $04
  .db $0E, $40, $0A, $00, $0A, $00, $0C, $40
  .db $04, $04, $2C, $70, $87, $10, $20, $E0
  .db $0C, $40, $04, $04, $AE, $E0, $0A, $00
  .db $0A, $00, $0C, $40, $04, $04, $E4, $E4
  .db $81, $90, $06, $40, $08, $00, $04, $04
  .db $E4, $E4, $06, $40, $0A, $00, $0C, $40
  .db $04, $04, $E0, $E4, $A6, $A0, $A0, $E0
  .db $C4, $80, $04, $04, $00, $00, $23, $31
  .db $00, $00, $00, $00, $05, $04, $00, $70
  .db $03, $3B, $71, $0E, $FF, $50, $0C, $C4
  .db $03, $3B, $71, $0E, $FF, $50, $0C, $C4
  .db $00, $00, $00, $00, $00, $00, $00, $00
  .db $00, $00, $00, $AA

;$FFFA - GOOD

NMI_vector:
  .dw NMI

;$FFFC - GOOD

RESET_vector:
  .dw RESET

;$FFFE - GOOD

IRQ_vector:
  .dw $FFFF