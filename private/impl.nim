## Implementation of a basic png encoder, does no filtering and no compression.

import streams,math

const Header* = [137.char, 80.char, 78.char, 71.char, 13.char, 10.char, 26.char, 10.char]

type Color = uint32

type Chunk = object of RootObj
  bytelen: uint32 # number of bytes after this header
  typ: seq[char] # chunk type s
  data: seq[char]

type IHDR* = object of Chunk
  width,height : uint32
  bit_depth: uint8 # Valid values are 1, 2, 4, 8, and 16
  color_type:uint8 # Valid values are 0, 2, 3, 4, and 6
  compression_type:uint8 # only 0 is defined
  filter_type:uint8 # only 0 is defined
  interlace_type:uint8 # 0 and 1 are defined

type IDAT* = object of Chunk

type IEND* = object of Chunk

type Filters* {.pure.}= enum
  None=0 
  Sub=1       
  Up=2
  Average=3       
  Paeth=4       

const 
  White = Color(0xFFFFFFFF)
  Black = Color(0x000000FF)

proc crc32(sta: uint32, data:openarray[char]):uint32 =
  var state = sta
  let len = data.len
  state = not state;
  for i in 0..<len:
    for j in 0..<8: # TODO: table-based
      let bit : uint32 = (state xor (cast[uint8](data[i]) shr cast[uint8](j))) and 1;
      state = (state shr 1) xor cast[uint32]( cast[int64](high(uint32)+1-bit) and 0xEDB88320 )
  return not state;

proc adler32(data:openarray[char]):uint32 = # output is correct
  let len = data.len
  var s1 : uint32 = 1
  var s2 : uint32 = 0
  for i in 0..<len:
    s1 = (s1 + cast[uint32](data[i])) mod 65521;
    s2 = (s2 + s1) mod 65521;

  return cast[uint32](s2) shl 16 or s1;

proc `&`[T](ar,ar2:openarray[T]):seq[T]=
  result = newSeq[T]()
  for a in ar: result&=a
  for a in ar2: result&=a
  assert(ar.len+ar2.len == result.len)


proc bytesOf(b4:uint32):array[4,uint8]=
  result[0] = (b4 shr 24).uint8
  result[1] = (b4 shr 16).uint8
  result[2] = (b4 shr 8).uint8
  result[3] = (b4 shr 0).uint8

proc charsOf(b4:uint32):array[4,char]=
  result[0] = cast[uint8](b4 shr 24).char
  result[1] = cast[uint8](b4 shr 16).char
  result[2] = cast[uint8](b4 shr 8).char
  result[3] = cast[uint8](b4 shr 0).char
 
proc insertChars(s:var seq[char], chrs:openarray[char])=
  if s==nil: s= @[]
  for c in chrs: s&=c

method serialize*(chunk: Chunk):seq[char] {.base.}=
  result = @[]
  
  result.insertChars(charsOf(chunk.bytelen))
  
  result &= chunk.typ

  if chunk.data.len>0:
    result.insertChars(chunk.data)
  
    result.insertChars( charsOf(crc32(0, chunk.typ&chunk.data)))
  else: 
    result.insertChars( charsOf(crc32(0, chunk.typ)))
 
proc initIHDR*(w,h:int,bit_depth=8,ctype=6,comptype=0,ftype=0,itype=0):IHDR =
  # IHDR specific data
  result.width = w.uint32
  result.height = h.uint32
  result.bit_depth = cast[uint8](bit_depth)
  result.color_type = cast[uint8](ctype)
  result.compression_type = cast[uint8](comptype)
  result.filter_type = cast[uint8](ftype)
  result.interlace_type = cast[uint8](itype)
  # General chunk
  result.bytelen = 2*4 + 5
  result.typ = @['I','H','D','R']
  result.data = charsOf(result.width)&charsOf(result.height)
  result.data &= result.bit_depth.char
  result.data &= result.color_type.char
  result.data &= result.compression_type.char
  result.data &= result.filter_type.char
  result.data &= result.interlace_type.char


proc expand(pixels:openarray[Color],w,h:int):seq[seq[char]] =
  ## Expand pixels into scanlines of bytes
  ## Assumes that pixels are 4-bytes ( so r,g,b,a )
  result = newSeq[seq[char]](h)
  
  var offset = 0
  for yline in result.mitems:
    yline = newSeq[char]()
    for xc in 0..<w:
      yline &= charsOf(pixels[offset+xc])
    offset+=w

proc flatten(pixbytes:seq[seq[char]]):seq[char]=
  ## Flatten the array of scanlines to a 1-D array
  result = @[]
  for y in pixbytes:
    for x in y: result.add(x)

proc applyFilter(pixbytes: var seq[seq[char]],filter:Filters= Filters.None)=
  if filter == Filters.None:
    for ln in pixbytes.mitems:
      ln = 0.char & ln
  elif filter == Filters.Sub:
    for ln in pixbytes.mitems:
      var tmp = ln[0..3]
      for i in 4..<ln.len:
        tmp &= (cast[uint8](ln[i]) - cast[uint8](ln[i-4])).char  
      ln = 1.char & tmp
  elif filter == Filters.Up:
  # Not working right, nice effect though
    for j in 0..<pixbytes.len:
      for i in 0..<pixbytes[j].len:
        if j==0: continue
        pixbytes[j][i] = ( cast[uint8](pixbytes[j][i]) - cast[uint8](pixbytes[j-1][i])).char
      if j==0: pixbytes[j] = 0.char & pixbytes[j]
      else: pixbytes[j] = 2.char & pixbytes[j]

proc charsOfAndCompl(b2:uint16):array[4,char]=
  # Returns b2 and it's 1 complement, as 4 chars representing
  # two little endian uint16 
  result[0] = cast[uint8](b2 shr 0).char
  result[1] = cast[uint8](b2 shr 8).char
  result[2] = cast[uint8]((b2 xor 0xFFFF) shr 0).char
  result[3] = cast[uint8]((b2 xor 0xFFFF) shr 8).char

#zlib magic headers
#78 01 - No Compression/low
#78 9C - Default Compression
#78 DA - Best Compression 

proc compress(pixbytes: seq[char],isFirst:bool=true,isLast:bool=false) :seq[char] =
  ## Wrap data as uncompressed
  result = @[]
  if isFirst: result &= [120.char, 1.char]  #no compression  magic header
  if isLast: result &= 1.char else: result &= 0.char # set block delimiter if final
  
  result &= charsOfAndCompl(cast[uint16](pixbytes.len)) # length
  result &= pixbytes # compressed data
  #result &= charsOf(adler32(pixbytes)) # adler32 MOVED TO initIDATs

proc initIDATs*(ihdr:IHDR, pixels:openarray[Color]):seq[IDAT] = 
  # Begin with image scanlines represented as described in Image layout;
  # the layout and total size of this raw data are determined by the fields of IHDR.
  var exppixels = expand(pixels,ihdr.width.int,ihdr.height.int)
  
  # Filter the image data according to the filtering method specified by the IHDR chunk. 
  # (Note that with filter method 0, the only one currently defined, this implies 
  # prepending a filter type byte to each scanline.) 
  # http://www.libpng.org/pub/png/spec/1.2/PNG-Filters.html <- Filters
  exppixels.applyFilter(Filters.Sub) # Currently default to none, will need to support others
  let pixlines = exppixels.flatten()

  const block_size = 62_000
  let reps = ceil(pixlines.len / block_size).int # 30_000 < 32k
  result = newSeq[IDAT](reps)
  
  if reps>0:
    
    for i in 0..<reps:
      let isFirst = if i==0: true else: false
      let isLast = if i==reps-1: true else: false
   
      # Compress the filtered data using the compression method specified by the IHDR chunk.
      if isLast:
        result[i].data = compress(pixlines[i*block_size..^1],isFirst,isLast) # currently does not compress
        result[i].data &= charsOf(adler32(pixlines)) # adler32
      else:
        result[i].data = compress(pixlines[i*block_size..<(i+1)*block_size],isFirst,isLast) # currently does not compress
      
      result[i].typ = @['I','D','A','T']
      result[i].bytelen = cast[uint32](result[i].data.len)
  else:
    result[0].data = compress(pixlines,true,true) # currently does not compress
    result[0].data &= charsOf(adler32(pixlines)) # adler32
    result[0].typ = @['I','D','A','T']
    result[0].bytelen = cast[uint8](result[0].data.len)

proc initIEND*():IEND=
  result.bytelen = 0
  result.typ = @['I','E','N','D']


proc encodePng*(w,h:int,pixels:openarray[Color]) : seq[char] =
  let ihdr = initIHDR(w,h)
  let iend = initIEND()
  let idats = initIDATs(ihdr,pixels)
  
  let sihdr = serialize(ihdr)
  let siend = serialize(iend)

  result = @[]
  for r in Header:
    result.add(r)
  result &= sihdr
  
  for idat in idats:  result &= serialize(idat)
  
  result &= siend

when isMainModule:
  var fs2 = newFileStream("pngte.png",fmWrite)

  let pix2 = [ White,Black,White,Black,White,Black]
  fs2.write(encodePng(3,2,pix2))
  fs2.close()


#proc color(rgba:uint32):Color = Color(rgba)
