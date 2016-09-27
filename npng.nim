import private/impl
import streams


type Color* = uint32
  ## An RGBA Color is defined as follows:  
  ## ``0x 12 34 56 78``  
  ## - ``12``: red level: ``00`` => no red , ``FF`` => full red  
  ## - ``34``: greej level: ``00`` => no green , ``FF`` => full green  
  ## - ``56``: blue level: ``00`` => no blue , ``FF`` => full blue  
  ## - ``78``: alpha level: ``00`` => fully transparent , ``FF`` => fully opaque  
  ## Examples:  
  ##  - solid yellow: ``0xFFFF00FF``  
  ##  - solid blue:  ``0x0000FFFF``  

const 
  White* = Color(0xFFFFFFFF)
  Black* = Color(0x000000FF)
  Red* = Color(0xFF0000FF)
  Green* = Color(0x00FF00FF)
  Blue* = Color(0x0000FFFF)
  Yellow* = Color(0xFFFF00FF)
  Purple* = Color(0xFF00FFFF)

type PNG* = object
  ## A png file. To create one, see ``initPNG`` 
  w,h:int
  pixels:seq[Color]

proc initPNG*(w,h:int):PNG=
  ## Create a w by h png. Initially it is filled with black, fully transparent pixels.
  result.w = w
  result.h = h
  result.pixels = newSeq[Color](w*h)

proc initPNG*(w,h:int,pix:seq[Color]):PNG=
  ## Create a w by h png, with initial pixels ``pix``
  assert(pix.len < (w*h), "Too many pixels")
  result.w = w
  result.h = h
  if pix.len == w*h:
    result.pixels = pix
  elif pix.len<(w*h):
    result.pixels = pix & newSeq[Color](w*h-pix.len)

proc writeToFile*(png:PNG,file:string)=
  ## Write a png to a file.
  ## The file is created if not present and overwritten otherwise.
  var fs = newFileStream(file,fmWrite)
  fs.write(encodePng(png.w,png.h,png.pixels))
  fs.close()

proc fillWith*(png:var PNG,color:Color=White)=
  ## Fill a png with ``color``
  for p in png.pixels.mitems: p=color 

when isMainModule:
  var png = initPNG(300,300)
  png.fillWith(BLue)
  png.pixels[2]=Red
  png.writeToFile("test.png")


#proc color(rgba:uint32):Color = Color(rgba)
