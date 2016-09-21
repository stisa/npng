# http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html

# http://www.fileformat.info/format/png/corion.htm

import streams

const Header = [137.uint8, 80, 78, 71, 13, 10, 26, 10]

type Chunk = object of RootObj
  bytelen: uint32 # number of bytes after this header
  typ: string # chunk type s
  data: seq[char]
  #crc: uint32 # crc32 calculated on type and data

type IHDR = object of Chunk
  width,height : uint32
  bit_depth: uint8 # Valid values are 1, 2, 4, 8, and 16
  color_type:uint8 # Valid values are 0, 2, 3, 4, and 6
  compression_type:uint8 # only 0 is defined
  filter_type:uint8 # only 0 is defined
  interlace_type:uint8 # 0 and 1 are defined

proc crc32(sta: uint32, data:openarray[uint8]):uint32 =
  var state = sta
  let len = data.len
  state = not state;
  for i in 0..<len:
    for j in 0..<8: # TODO: table-based
      let bit : uint32 = (state xor (data[i] shr j.uint8)) and 1;
      state = (state shr 1) xor ((high(uint32)+1-bit).int64 and 0xEDB88320).uint32
  return not state;

proc adler32(state: var uint32, data:openarray[uint8]):uint32 =
  let len = data.len
  var s1 : uint16 = (state shr  0).uint16
  var s2 : uint16 = (state shr 16).uint16
  for i in 0..<len:
    s1 = (s1 + data[i]) mod 65521;
    s2 = (s2 + s1) mod 65521;

  return s2.uint32 shl 16 or s1;

proc `&`[T](ar,ar2:openarray[T]):seq[T]=
  result = newSeq[T]()
  for a in ar: result&=a
  for a in ar2: result&=a
  assert(ar.len+ar2.len == result.len)


proc bytesOf(b4:uint32):array[4,uint8]=
  result[0] = (b4 shr 0).uint8
  result[1] = (b4 shr 8).uint8
  result[2] = (b4 shr 16).uint8
  result[3] = (b4 shr 24).uint8

proc charOf(b4:uint32):array[4,char]=
  result[0] = (b4 shr 0).char
  result[1] = (b4 shr 8).char
  result[2] = (b4 shr 16).char
  result[3] = (b4 shr 24).char

method serialize(chunk: Chunk):seq[uint8] {.base.} =
  result = newSeq[uint8]()
  result &= bytesOf(chunk.bytelen)
  let chartoint8 = [chunk.typ[0].uint8,chunk.typ[1].uint8,chunk.typ[2].uint8,chunk.typ[3].uint8]
  echo repr chartoint8
  echo repr (['I'.uint8,'H'.uint8,'D'.uint8,'R'.uint8])
  result &= chartoint8
  result&=chunk.data
  result&= bytesOf(crc32(0, chartoint8&chunk.data))

proc initIHDR(w,h:int,bit_depth=8,ctype=6,comptype=0,ftype=0,itype=0):IHDR =
  # IHDR specific data
  result.width = w.uint32
  result.height = h.uint32
  result.bit_depth = bit_depth.uint8
  result.color_type = ctype.uint8
  result.compression_type = comptype.uint8
  result.filter_type = ftype.uint8
  result.interlace_type = itype.uint8
  # General chunk
  result.bytelen = 3*4 + 2*4 + 5
  result.typ = "IHDR"
  result.data = bytesOf(result.width)&bytesOf(result.height)
  result.data &= result.bit_depth
  result.data &= result.color_type
  result.data &= result.compression_type
  result.data &= result.filter_type
  result.data &= result.interlace_type

when isMainModule:
  var fs = newFileStream("out.txt",fmWrite)
  fs.write(Header)
  let ihdr = initIHDR(3,2)
  let sihdr = serialize(ihdr)
  echo sihdr
  fs.write(sihdr[4..7])
  fs.close()

  echo repr readFile("out.txt")