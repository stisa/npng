##[
`Examples <./examples.html>`_
]##

import private/impl
import streams

when defined(js) or defined(nimdoc):
  import dom,base64

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
  Transparent* = Color(0x00000000)
    ## Common colors used for testing
  Black* = Color(0x000000FF)
  Blue* = Color(0x0000FFFF)
  Green* = Color(0x00FF00FF)
  Red* = Color(0xFF0000FF)
  Purple* = Color(0xFF00FFFF)
  Yellow* = Color(0xFFFF00FF)
  White* = Color(0xFFFFFFFF)
  HalfTBlack* = Color(0x00000088) 
    ## HalfT<Color> colors are <color> at half alpha
  HalfTBlue* = Color(0x0000FF88)
  HalfTGreen* = Color(0x00FF0088)
  HalfTRed* = Color(0xFF000088)
  HalftWhite* = Color(0xFFFFFF88)

type PNG* = object
  ## A png file. To create one, see ``initPNG`` 
  w*,h*:int
  pixels*:seq[Color]

proc `[]`*(png:PNG,i,j:int):Color= png.pixels[i*png.w+j]
proc `[]=`*(png: var PNG,i,j:int,col:Color) = png.pixels[i*png.w+j] = col

proc initPNG*(w,h:int):PNG=
  ## Create a w by h png. Initially it is filled with black, fully transparent pixels.
  result.w = w
  result.h = h
  result.pixels = newSeq[Color](w*h)

proc initPNG*(w,h:int,pix:seq[Color]):PNG=
  ## Create a w by h png, with initial pixels ``pix``
  assert(pix.len <= (w*h), "Too many pixels")
  result.w = w
  result.h = h
  if pix.len == w*h:
    result.pixels = pix
  elif pix.len<(w*h):
    result.pixels = pix & newSeq[Color](w*h-pix.len)

proc fillWith*(png:var PNG,color:Color=White)=
  ## Fill a png with ``color``
  for p in png.pixels.mitems: p=color 

proc toSeqChar(png:PNG):seq[char] {.inline.}= encodePng(png.w,png.h,png.pixels)

when defined(js) or defined(nimdoc):
  proc appendImg*(png:PNG,toID:string="body")=
    ## Inline a png in a html file. If toId is presents,
    ## it tries adding it to that element, otherwise adds it
    ## to body.
    var iel = document.createElement("IMG").ImageElement
    iel.src = "data:image/png;base64,"&base64.encode(toSeqChar(png))
    if toID=="body":
      document.body.appendChild(iel)
    else:
      let parent = document.getElementById(toID)
      parent.appendChild(iel)
  
when not defined(js) or defined(nimdoc):
  proc writeToFile*(png:PNG,file:string)=
    ## Write a png to a file.
    ## The file is created if not present and overwritten otherwise.
    var fs = newFileStream(file,fmWrite)
    for c in toSeqChar(png):
      fs.write(c)
    fs.close()
  
when isMainModule and not defined js:
  var png = initPNG(30,39)
  png.fillWith(Green)
  png.writeToFile("test2.png")

when isMainModule and defined js:  
  proc log*(str:varargs[auto]) = {.emit: "console.log(`str`);".}

  var png = initPNG(300,300)
  png.fillWith(Green)
  png.appendImg("ts")
#proc color(rgba:uint32):Color = Color(rgba)
