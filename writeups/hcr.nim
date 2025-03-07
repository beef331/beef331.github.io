import nimib
nbInit()
nb.context["path_to_root"] = "../writeups.html"
nb.partials["header_right"] = ""
nb.context["github_remote_url"] = ""
nb.context["github_logo"] = ""


nb.darkMode()
nb.title = "So you want to write hot code reload, eh?"
nbText:"""
# It is not hot it is atleast lukewarm

One of the most desirable features of a game development environment is the ability to change code and see the changes live.
Vexingly many game developers use a statically typed compiled language making hot code reload more difficult.
As someone that went though the work this documents the journey across the [potato](https://www.github.com/beef331/potato) fields.

## Dynamic libraries - I swear they just keep moving on me.

For those not in the know a dynamic library is a compiled blob of code that you can load at runtime.
Enabling both the ability to add new code and to replace implementations.
They have a symbol table which lets users search for and access procedures and variables once loaded.
It is this which will allow us to write hot code reload.
The game code can be compiled into a dynamic library and be loaded by a host program.
Allowing the programmer to change code then recompile and continue where left off.
"""

proc nbFile(name: string) =
  nbFile(name, readFile(name))


nbFile("hcr1host.nim")
nbFile("hcr1lib.nim")
nbFile("hcr1lib.nims")

nbText:"""
This is a basic program with a pluggable function.
When `hcr1host` runs it loads the library `./libhcr.so` then it calls the `entry` procedure declared there.
Those smart enough to always plug in a USB type-A first try can see where this takes us.
The first step to that quest is to have a loop that watches the file.
Here cause I prefer brevity will resort to a simple watcher(A cross platform solution that will make anyone knowledgable cry and even whimper.).
"""

nbFile("hcr2host.nim")

nbText:"""
With this one can modify the `hcr1lib.nim` and recompile it and without closing `hcr2host` will see a live change.
Tinkering with it you may notice a problem that sticks out like a toe in a ripped sock.
Nothing persists on reload.
"""

nbFile("hcr2lib.nim")

nbText:"""
Using this as the library every reload prints `1` and it does not persist.
This means one needs to store global state somehow... the best way of doing that is you guessed it dynamic symbols!
Not only does a dynamic library add to a symbol table the host program also does.
To do this one needs to invent a `saveInt` procedure which lets the library save and reload state.
Though a cookie jar is only good for storage cause you can get cookies out which means it also needs a `getInt` procedure to fetch the value stored.
"""

nbFile("hcr3host.nim")

nbText:"""
Nim specific but exceptions do not raise across dynamic library barriers so it is best to return a bool as we do here.
This allows the reloading code to set a default value if we do not load.
With C `-rdynamic` is required to be able to access the host procedures from the dynamic library
"""

nbFile("hcr3lib.nim")

nbText:"""
More Nim specific details `dynlib` loads using `dlopen` which means we can supply `""` and it will load from this program's symbol table.
In less nerdy POSIX talk it means it will load `getInt` and `setInt` from the host program.

With all this now one can easily replace their dynamic library and now they can reload integers!
This can be expanded to use tagged unions instead to enable storing more complex state(infact in Potato deeply nested structures save just fine!)

## Serialization

The heart of storing state across reloads is ensuring the old data can be migrated to the most recent binary with possible new fields added.
In this case it means one will use a tagged union across primitive types.
Meaning we need a single data type that can hold `int`, `float`, `string`, a list, and a structure.

```nim
import std/tables

type
  HcrKind = enum
    Int
    Float
    String
    Array
    Struct

  HcrObj = object
    case kind: HcrKind
    of Int:
      i: int
    of Float:
      f: float
    of String:
      s: string
    of Array:
      arr: seq[HcrObj]
    of Struct:
      fields: Table[string, HcrObj]
```  


This data type is sufficient to store every type under the sun (though in the case of Potato Nim's `std/json.JsonNode` is just used).
To enable support of reference types all data of a structure type should be stored to a root level `HcrObj` where the entry object is at a field named `data`.
This allows storing references in the top level using their old pointer value as a field name.


With that the following is how mapping between types works:

- Any integer, enum, char, or bool maps to `Int`
- 32bit and 64bit floats map to `Float`
- `string` maps to `String`
- `ptr T`, `pointer`, and `proc` map to `Int`
- `ref T` stores as an `Int` in place. Though adds to the root object's fields at its old pointer value. On load a table of the old pointer to new must be stored to migrate to new pointers.
- `seq[T]` and `array[Idx, T]` map to `Array`
- `set[T]` maps to `String` just allocate a string which is `sizeof(set[T]))` and copy the memory over
- `object` and `tuple` map to `Struct`, iterate the fields and store to `fields`

It is also very important to note that since pointers are assumed to be valid after reload the old library must not be unloaded.
This will leak memory but it also ensures the pointers are still pointing to alive data.
Doing this will also force all pointer procedures to be reloaded on program reload as migrating pointer procedures is not a fun problem.
Pointer procedures to named procedures is relative easy to migrate, but any anonymous procedure is mangled in such a way you cannot be certain two procedures with the same name are the same.
For intuitive hot code reload it is best to avoid pointer procedures and use some sort of global memory or vtable instead, that way it can be reinitialised and the procedures will be updated.

To enable saving before reload one should also create a list of serializers to store all global variables to the host program.

```nim
# Inside the library
var serializers: seq[proc()]
proc hcrSave() {.exportc, dynlib.} =
  for serializer in serializers:
    serializer()

var someInt = 0
serializers.add proc() =
  saveInt("someInt", someInt)
```
`hcrSave` can then be called before reload on the host to save the state.
Which means when the next library is loaded it will fetch the memory stored in the host and continue as if nothing happened.

## Signals

If a loaded program crashes one should not have to relaunch the program.
It likely should continue where it left off rerunning the frame.
To achieve this one can use signal handlers to call a `hcrError` procedure from the host program.
This `hcrError` will use `siglongjmp` to return the program back to before the loop was called and let the program continue again.

"""

nbFile("hcr4host.nim")
nbFile("hcr4lib.nim")
nbFile("hcr4lib.nims")

nbText"""
## Closing
Thanks for reading.
More information can be found by reading the source code of [Potato](https://github.com/beef331/potato).
Including things not touched on here like how to use a single module for both the host and library.
"""

nbSave()
