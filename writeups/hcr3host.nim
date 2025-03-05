import std/[dynlib, times, os, tables]

{.passc: "-rdynamic", passL: "-rdynamic".} ## Needed so we can access symbols from children

type Entry = proc() {.cdecl.}

const libPath = 
  when defined(linux):
    "./libhcr.so"
  elif defined(windows):
    "./libhcr.dll"
  else:
    "./libhcr.dylib"

var ints: Table[string, int]

proc saveInt(name: string, i: int) {.exportc, dynlib, raises: [].} =
  ints[name] = i

proc getInt(name: string, i: var int) : bool {.exportc, dynlib, raises: [].} =
  if name in ints:
    try:
      i = ints[name]
      true
    except CatchableError:
      false
  else:
    false


var lastLoad = default Time

while true:
  let thisLoad = 
    try:
      getLastModificationTime(libPath)
    except CatchableError:
      continue


  if lastLoad < thisLoad:
    lastLoad = thisLoad
    var lib =
      try:
        loadLib(libPath)
      except CatchableError as e:
        echo "Failed to load dynamic library: ", e.msg
        continue

    if lib == nil:
      echo "Failed to load lib: ", libPath
    else:
      let entry = cast[Entry](lib.symAddr("entry"))
      if entry == nil:
        echo "No function named 'entry'"
        if lib != nil:
          lib.unloadLib()
        continue
      entry()
      lib.unloadLib()

