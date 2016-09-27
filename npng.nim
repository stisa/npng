import private/impl
import streams

type Color* = uint32
const 
  White* = Color(0xFFFFFFFF)
  Black* = Color(0x000000FF)
  Red* = Color(0xFF0000FF)
  Green* = Color(0x00FF00FF)
  Blue* = Color(0x0000FFFF)
  Yellow* = Color(0xFFFF00FF)
  Purple* = Color(0xFF00FFFF)

type PNG* = object
  w,h:int
  pixels:seq[Color]

proc initPNG(w,h:int):PNG=
  result.w = w
  result.h = h
  result.pixels = newSeq[Color](w*h)

proc initPNG(w,h:int,pix:seq[Color]):PNG=
  assert(pix.len < (w*h), "Too many pixels")
  result.w = w
  result.h = h
  if pix.len == w*h:
    result.pixels = pix
  elif pix.len<(w*h):
    result.pixels = pix & newSeq[Color](w*h-pix.len)

proc writeToFile(png:PNG,file:string)=
  var fs = newFileStream(file,fmWrite)
  fs.write(encodePng(png.w,png.h,png.pixels))
  fs.close()

proc fillWith(png:var PNG,color:Color=White)=
  for p in png.pixels.mitems: p=color 

when isMainModule:
  var png = initPNG(3,3)
  png.fillWith(Yellow)
  png.writeToFile("test.png")


#proc color(rgba:uint32):Color = Color(rgba)
