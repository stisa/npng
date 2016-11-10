Naïve PNG
=========

### I just found out that [nimPNG](https://github.com/jangko/nimPNG) exists, it is quite complete from I can tell, and   
### it also has a nim-based version of zlib. This project is thus _on hold_

A naïve png encoder written in [nim](https://nim-lang.org).  
No external dependecies needed, just nim.  
Probably unsuitable for serious use, as data is currently stored uncompressed, and no filtering is implemented.
( A 300x300 blue square is ~353kb, opening and saving with paint brings it to ~2kb, to give you an idea of how bad this is. )
See [examples](examples) for example code, or see [graph](https://github.com/stisa/graph) for more advanced examples.
Currently ONLY supports pngs with 8-bit depth and RGBA colors.

The purpose of this lib is **saving pngs**, I believe that drawing should be handled by a separate lib that will
then provide a seq of pixels in a suitable format to be used in `initPng(w,h,pixels)`.  
Anyway, pixels can be accessed with `[i,j]` and `[i,j]=`. Indexing is row-major, so both index start at 0, `j` grows 
from left to right and `i` from top to bottom ( so the origin is top-left )  

Documentation
-------------
See  [generated documentation](http://stisa.space/npng/)

TODO
-----

- [Filters](http://www.libpng.org/pub/png/spec/1.2/PNG-Filters.html)
- A way to choose the best filter ( run all and select the one with len < ?)
- Test and reduce/optimize copying of seq/string, possibly move to arrays


LICENSE
-------
[MIT]()