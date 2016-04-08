  .inesprg 1 ; 1 16KB PRG ROM
  .ineschr 1 ; 1 8KB CHR ROM
  .inesmir 1 ; Vertical Mirroring
  .inesmap 0 ; Mapper 0

  .bank 0
  .org $C000
  .incbin "bank.raw"
  .incbin "bank.raw"

  .bank 1
  .org $E000
  .incbin "bank.raw"
  .incbin "bank.raw"

  .bank 2
  .org $0000
  .incbin "gamegenie.chr"