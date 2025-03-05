import std/dynlib

type Entry = proc() {.cdecl.}

var lib = loadLib("./libhcr.so")
let entry = cast[Entry](lib.symAddr("entry"))
entry()
