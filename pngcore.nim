# http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html

# http://www.fileformat.info/format/png/corion.htm
import corzl
import streams

const Header = [137.uint8, 80, 78, 71, 13, 10, 26, 10]

type Color =uint32

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

type IDAT = object of Chunk

type IEND = object of Chunk

type Filters = enum
  None=0 
  Sub=1       
  Up=2
  Average=3       
  Paeth=4       

#proc color(rgba:uint32):Color = Color(rgba)
const White = Color(0xFFFFFFFF)
const Black = Color(0x000000FF)

proc crc32(sta: uint32, data:openarray[char]):uint32 =
  var state = sta
  let len = data.len
  state = not state;
  for i in 0..<len:
    for j in 0..<8: # TODO: table-based
      let bit : uint32 = (state xor (data[i].uint8 shr j.uint8)) and 1;
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

proc charsOf(b4:uint32):array[4,char]=
  result[0] = (b4 shr 24).uint8.char
  result[1] = (b4 shr 16).uint8.char
  result[2] = (b4 shr 8).uint8.char
  result[3] = (b4 shr 0).uint8.char
  #echo repr result

proc insertChars(s:var string, chrs:openarray[char])=
  if s==nil: s=""
  for c in chrs: s&=c

method serialize(chunk: Chunk):string {.base.}=#seq[char] {.base.} =
  #result = newSeq[char]()
  result=""
  result.insertChars(charsOf(chunk.bytelen))
  #echo repr result
  #let chartoint8 = [chunk.typ[0],chunk.typ[1],chunk.typ[2],chunk.typ[3]]
  result &= chunk.typ # chartoint8
  if chunk.data.len>0:
    result.insertChars(chunk.data)
    #for cd in chunk.data: result&=cd
    result.insertChars( charsOf(crc32(0, chunk.typ&chunk.data)))
  else: result&= charsOf(crc32(0, chunk.typ))
  #echo repr result

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
  result.data = charsOf(result.width)&charsOf(result.height)
  result.data &= result.bit_depth.char
  result.data &= result.color_type.char
  result.data &= result.compression_type.char
  result.data &= result.filter_type.char
  result.data &= result.interlace_type.char

proc expand(pixels:openarray[Color],w,h:int):seq[seq[char]] =
  ## Expand pixels int scanlines of bytes
  ## Assumes that pixels are 4-bytes ( so r,g,b,a )
  result = newSeq[seq[char]](h)
  var offset = 0
  for yline in result.mitems:
    yline = newSeq[char]()
    for xc in 0..<w:
      yline &= charsOf(pixels[offset+xc])
    offset+=w

proc deexpand(pixbytes:seq[seq[char]]):string=
  result = ""#newSeq[char]()
  for y in pixbytes:
    for x in y: result.add(x)

proc strToSeqChar(sc:string):seq[char] =
  result = newSeq[char]()
  for c in sc: result&=c

proc applyFilter(pixbytes: var seq[seq[char]],filter:Filters=None)=
  if filter == None:
    for ln in pixbytes.mitems:
      ln = 0.char & ln

proc compress(pixbytes: var seq[seq[char]]) =
  discard
 
proc zcompress*(data: string): string = # TODO: drop zlib
  let size = data.len
  var resultSize = corzl.compressBound(Ulong(size))
  result = newString(resultSize)
  let res = corzl.compress(
    result, Pulongf(addr resultSize), data, size)
  if res != corzl.Z_OK:
    raise newException(ValueError, "zlib returned error " & $res)
  result.setLen(resultSize)

proc initIDAT(ihdr:IHDR, pixels:openarray[Color]):IDAT = 
  var ypos = 0 # goes from 0 to <ihdr.height
  var xpos = 0 # goes from 0 to <ihdr.width*4
  let w = ihdr.width*4 # Convert the width from pixels to bytes ( each pixel is 3 bytes of rbg and 1 byte for alpha)

  # Begin with image scanlines represented as described in Image layout;
  # the layout and total size of this raw data are determined by the fields of IHDR. 
  var exppixels = expand(pixels,ihdr.width.int,ihdr.height.int)
  
  # Filter the image data according to the filtering method specified by the IHDR chunk. 
  # (Note that with filter method 0, the only one currently defined, this implies 
  # prepending a filter type byte to each scanline.) 
  # http://www.libpng.org/pub/png/spec/1.2/PNG-Filters.html <- Filters
  exppixels.applyFilter(None) # Currently default to none, will need to support others

  # Compress the filtered data using the compression method specified by the IHDR chunk.
  result.data = zcompress(deexpand(exppixels)).strToSeqChar
  result.typ = "IDAT"
  result.bytelen = (4+4+result.data.len).uint32

proc initIEND():IEND=
  result.bytelen = 4+4
  result.typ = "IEND"

when isMainModule:
  var fs = newFileStream("out.txt",fmWrite)

  let pix = [White, White,White, White,White, White]
  
  fs.write(Header)
  let ihdr = initIHDR(3,2)
  let iend = initIEND()
  let idat = initIDAT(ihdr,pix)
  fs.write(serialize(ihdr))
  echo repr serialize(ihdr), "<!IHDR!>"
  fs.write(serialize(idat))
  echo repr serialize(idat), "<!IDAT!>"  
  fs.write(serialize(iend))
  echo repr serialize(iend), "<!IEND!>"
  fs.close()

  echo repr readFile("out.txt")
