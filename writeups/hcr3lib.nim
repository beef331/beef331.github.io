proc saveInt(name: string, val: int) {.importc, dynlib"".}
proc getInt(name: string, val: var int): bool {.importc, dynlib"".}

var i = 0
if not getInt("i", i):
  i = 0 # Redundant but let's stay classy 

proc entry() {.exportc, dynlib.} =
  inc i
  echo i
  saveInt("i", i)
