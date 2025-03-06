import std/[dynlib, times, os, tables]
import system/ansi_c

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

const
  ErrorJump = 1
  QuitJump = 2

type sigjmp_buf {.bycopy, importc: "sigjmp_buf", header: "<setjmp.h>".} =  object

proc sigsetjmp(jmpb: C_JmpBuf, savemask: cint): cint {.header: "<setjmp.h>", importc: "sigsetjmp".}
proc siglongjmp(jmpb: C_JmpBuf, retVal: cint) {.header: "<setjmp.h>", importc: "siglongjmp".}

var jmp: C_JmpBuf

proc hcrError() {.exportc, dynlib.} =
  siglongjmp(jmp, ErrorJump)

proc hcrQuit() {.exportc, dynlib.} =
  siglongjmp(jmp, QuitJump)


var 
  lastLoad = default Time
  crashed = false

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
      case sigsetjmp(jmp, int32.high.cint)
      of 0:
        entry()
      of ErrorJump:
        crashed = true
        echo "Crashed"
      of QuitJump:
        break
      else:
        echo "Incorrect jump"
      # lib.unloadLib() # We no longer want to free memory we allocated as pointers may outlast the shared library

