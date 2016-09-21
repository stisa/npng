Critical chunks
---------------
(must appear in this order)

|Name | Multiple | Ordering constraints|
|-----|----------|---------------------|
 IHDR |  No      | Must be first
 PLTE |  No      | Optional, before IDAT if present
 IDAT |  Yes     | Multiple IDATs must be consecutive
 IEND |  No      | Must be last
   
Ancillary chunks
-------------------------------------------------
(need not appear in this order)

|Name | Multiple | Ordering constraints|
|-----|----------|---------------------|
 cHRM |  No      | Before PLTE and IDAT
 gAMA |  No      | Before PLTE and IDAT
 iCCP |  No      | Before PLTE and IDAT
 sBIT |  No      | Before PLTE and IDAT
 sRGB |  No      | Before PLTE and IDAT
 bKGD |  No      | After PLTE; before IDAT
 hIST |  No      | After PLTE; before IDAT
 tRNS |  No      | After PLTE; before IDAT
 pHYs |  No      | Before IDAT
 sPLT |  Yes     | Before IDAT
 tIME |  No      | None
 iTXt |  Yes     | None
 tEXt |  Yes     | None
 zTXt |  Yes     | None

Chunk spec
-----------
    OFFSET      | Count | TYPE |   Description
|---------------|-------|------|----------------|
0000h           |1      |dword |  Number of data bytes after this header.
0004h           |4      |char  |  Chunk type.[^1]
????h           |?      |byte  |  Data
????h           |1      |dword | CRC 

[^1] A 4-byte chunk type code. For convenience in
description and in examining PNG files, type
codes are restricted to consist of uppercase
and lowercase ASCII letters (A-Z, a-z).
However, encoders and decoders should treat the
codes as fixed binary values, not character
strings. For example, it would not be correct
to represent the type code IDAT by the EBCDIC
equivalents of those letters.

[^2] Calculated on the preceding bytes in that
chunk, including the chunk type code and chunk
data fields, but not including the length
field. The CRC is always present, even for
empty chunks such as IEND. The CRC algorithm
is specified below.