Naïve PNG
=========

A naïve png encoder written in [nim](https://nim-lang.org).  
No external dependecies needed, just nim.  
Probably unsuitable for serious use, as data is currently stored uncompressed, and no filtering is implemented.
( A 300x300 blue square is ~353kb, opening and saving with paint brings it to ~2kb, to give you an idea of how bad this is. )
See [examples](examples) for example code.
Currently ONLY supports with 8-bit depth and RGBA colors.

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