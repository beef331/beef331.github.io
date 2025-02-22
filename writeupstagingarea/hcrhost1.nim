import std/[dynlib, os, times]

type PotatoProc = proc(){.cdecl.}

const dynamicLibExt =
  when defined(windows):
    "dll"
  elif defined(linux):
    "so"
  elif defined(macos):
    "dylib"
  else:
    {.error: "Unsupported OS".}


proc asDynamicLib(s: string): string =
  s.changeFileExt(dynamicLibExt)

let libPath = absolutePath("libmylib".asDynamicLib())

var 
  lib = LibHandle nil 
  modTime = Time() 
  prc = PotatoProc nil

echo libPath

while true:
  let newModTime = 
    try:
      getLastModificationTime(libPath)
    except CatchableError as e:
      echo e.msg
      Time()

  if newModTime != modTime:
    try:
      lib = loadLib(libPath, false)
      if lib == nil:
        echo "Could not load lib"
      else:
        echo "Loaded new lib"
      prc = cast[PotatoProc](lib.symAddr("potatoMain"))
      if prc == nil:
        echo "Could not find potatoMain"
    except CatchableError as e:
      echo e.msg
    modTime = newModTime

  if lib != nil and prc != nil:
    echo "Invoke potatoMain"
    prc()
