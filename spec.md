https://github.com/PistonDevelopers/image-png/blob/master/src/encoder.rs
http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html
http://www.fileformat.info/format/png/corion.htm


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

Header
------
OFFSET          | Count |TYPE  | Description
|---------------|-------|------|----------------|
 0000h          |8      | char |  ID=89h,'PNG',13,10,26,10

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

IHDR Image Header
-----------------
This chunk must appear FIRST. Its contents are:

Width:            4 bytes  
Height:           4 bytes  
Bit depth:        1 byte  
Color type:       1 byte  
Compression type: 1 byte  
Filter type:      1 byte  
Interlace type:   1 byte  


# Deflate
Stream format[edit]
A Deflate stream consists of a series of blocks. Each block is preceded by a 3-bit header:
First bit: Last-block-in-stream marker: 
  1: this is the last block in the stream.
  0: there are more blocks to process after this one.
Second and third bits: Encoding method used for this block type: 
  00: a stored/raw/literal section, between 0 and 65,535 bytes in length.
  01: a static Huffman compressed block, using a pre-agreed Huffman tree.
  10: a compressed block complete with the Huffman table supplied.
  11: reserved, don't use.

# zlib
Deflate-compressed datastreams within PNG are stored in the "zlib" format,
which has the structure: 
   Compression method/flags code: 1 byte
   Additional flags/check bits:   1 byte
   Compressed data blocks:        n bytes
   Check value:                   4 bytes


# 3.2.4. Non-compressed blocks (BTYPE=00)
Any bits of input up to the next byte boundary are ignored. The rest of the block consists of the following information: 

  0   1   2   3   4...

+---+---+---+---+================================+

|  LEN  | NLEN  |... LEN bytes of literal data...|

+---+---+---+---+================================+

LEN is the number of data bytes in the block. NLEN is the one's complement of LEN. 

# Zlib data format
2.2. Data format

  A zlib stream has the following structure:

        0   1
      +---+---+
      |CMF|FLG|   (more-->)
      +---+---+

  (if FLG.FDICT set)

        0   1   2   3
      +---+---+---+---+
      |     DICTID    |   (more-->)
      +---+---+---+---+

  (end if)

      +=====================+---+---+---+---+
      |...compressed data...|    ADLER32    |
      +=====================+---+---+---+---+

  Any data which may appear after ADLER32 are not part of the zlib
  stream.

  CMF (Compression Method and flags)
      This byte is divided into a 4-bit compression method and a 4-
      bit information field depending on the compression method.

        bits 0 to 3  CM     Compression method
        bits 4 to 7  CINFO  Compression info

  CM (Compression method)
      This identifies the compression method used in the file. CM = 8
      denotes the "deflate" compression method with a window size up
      to 32K.  This is the method used by gzip and PNG (see
      references [1] and [2] in Chapter 3, below, for the reference
      documents).  CM = 15 is reserved.  It might be used in a future
      version of this specification to indicate the presence of an
      extra field before the compressed data.

  CINFO (Compression info)
      For CM = 8, CINFO is the base-2 logarithm of the LZ77 window
      size, minus eight (CINFO=7 indicates a 32K window size). Values
      of CINFO above 7 are not allowed in this version of the
      specification.  CINFO is not defined in this specification for
      CM not equal to 8.

  FLG (FLaGs)
      This flag byte is divided as follows:

        bits 0 to 4  FCHECK  (check bits for CMF and FLG)
        bit  5       FDICT   (preset dictionary)
        bits 6 to 7  FLEVEL  (compression level)

      The FCHECK value must be such that CMF and FLG, when viewed as
      a 16-bit unsigned integer stored in MSB order (CMF*256 + FLG),
      is a multiple of 31.

  FDICT (Preset dictionary)
      If FDICT is set, a DICT dictionary identifier is present
      immediately after the FLG byte. The dictionary is a sequence of
      bytes which are initially fed to the compressor without
      producing any compressed output. DICT is the Adler-32 checksum
      of this sequence of bytes (see the definition of ADLER32
      below).  The decompressor can use this identifier to determine
      which dictionary has been used by the compressor.

  FLEVEL (Compression level)
      These flags are available for use by specific compression
      methods.  The "deflate" method (CM = 8) sets these flags as
      follows:

        0 - compressor used fastest algorithm
        1 - compressor used fast algorithm
        2 - compressor used default algorithm
        3 - compressor used maximum compression, slowest algorithm

      The information in FLEVEL is not needed for decompression; it
      is there to indicate if recompression might be worthwhile.

  compressed data
      For compression method 8, the compressed data is stored in the
      deflate compressed data format as described in the document
      "DEFLATE Compressed Data Format Specification" by L. Peter
      Deutsch. (See reference [3] in Chapter 3, below)

      Other compressed data formats are not specified in this version
      of the zlib specification.

  ADLER32 (Adler-32 checksum)
      This contains a checksum value of the uncompressed data
      (excluding any dictionary data) computed according to Adler-32
      algorithm. This algorithm is a 32-bit extension and improvement
      of the Fletcher algorithm, used in the ITU-T X.224 / ISO 8073
      standard. See references [4] and [5] in Chapter 3, below)

      Adler-32 is composed of two sums accumulated per byte: s1 is
      the sum of all bytes, s2 is the sum of all s1 values. Both sums
      are done modulo 65521. s1 is initialized to 1, s2 to zero.  The
      Adler-32 checksum is stored as s2*65536 + s1 in most-
      significant-byte first (network) order.



