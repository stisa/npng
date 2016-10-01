import private/impl
import streams,base64


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

proc fillWith*(png:var PNG,color:Color=White)=
  ## Fill a png with ``color``
  for p in png.pixels.mitems: p=color 

proc stringify(png:PNG):string {.inline.}= encodePng(png.w,png.h,png.pixels)

proc writeBase64(png:PNG):string=
  ## Write a png file as base64, useful for inlining
  ## images in js.
  result = "data:image/png;base64,"&base64.encode(stringify(png))

when not defined(js):
  proc writeToFile*(png:PNG,file:string)=
    ## Write a png to a file.
    ## The file is created if not present and overwritten otherwise.
    var fs = newFileStream(file,fmWrite)
    fs.write(stringify(png))
    fs.close()
    #var fs2 = newFileStream("t.txt",fmWrite)
    #fs2.write("data:image/png;base64,"&base64.encode(stringify(png)))
    #fs2.close()

const rs = slurp("test2.png")


when isMainModule and not defined js:
  var png = initPNG(3,3)
  png.fillWith(Green)
  png.writeToFile("test2.png")

  assert (encode(stringify(png)) == encode(rs), "not equal")

when isMainModule and defined js:
  import dom
  
  proc log*(str:varargs[auto]) = {.emit: "console.log(`str`);".}

  var png = initPNG(3,3)
  png.fillWith(Black)
  log (stringify(png)==rs)
  log stringify(png)
  log rs
  #var iel = document.createElement("IMG").ImageElement
  #iel.src = stringify(png)#png.writebase64()
  #log(iel.src)
  #document.body.appendChild(iel)
#proc color(rgba:uint32):Color = Color(rgba)
