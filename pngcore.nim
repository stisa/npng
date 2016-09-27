import private/impl
import streams

type Color = uint32
const 
  White = Color(0xFFFFFFFF)
  Black = Color(0x000000FF)

when isMainModule:
  var fs = newFileStream("pngte.png",fmWrite)

  let pix = [ Color(0xFF00FFFF),White,White,White,White,Color(0xFF00FFFF)]
  fs.write(Header)

  let ihdr = initIHDR(3,2)
  let iend = initIEND()
  let idat = initIDAT(ihdr,pix)
  fs.write(serialize(ihdr))
  
  fs.write(serialize(idat))
  
  fs.write(serialize(iend))
  
  fs.close()


#proc color(rgba:uint32):Color = Color(rgba)
