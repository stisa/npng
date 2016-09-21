Critical chunks
---------------
(must appear in this order, except PLTE is optional)

|Name | Multiple | Ordering constraints|
|-----|----------|---------------------|
 IHDR |  No      | Must be first
 PLTE |  No      | Before IDAT
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