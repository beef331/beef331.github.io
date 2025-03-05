var i = 0
proc entry() {.exportc, dynlib.} =
  inc i
  echo i 
