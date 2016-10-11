# Package
version       = "0.1.0"
author        = "stisa"
description   = "A naive png encoder."
license       = "MIT"

# Deps
requires: "nim >= 0.14.0"
task builddocs, "Build docs folder - examples and documentation":    
  exec("nim doc2 -o:docs/index.html npng.nim")
  exec("nim js -o:docs/js/exampleinline.js examples/exampleinline.nim")