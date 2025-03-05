import nimib
nbInit()
nb.context["path_to_root"] = "../writeups.html"

nb.darkMode()
nb.title = "So you want to write hot code reload, eh?"
nbText:"""
# It is not hot it is atleast lukewarm

One of the most desirable features of a game development environment is the abillity to change code and see the changes live.
Vexxing many game developers use a statically typed compiled language to program games making hot code reload require work.
As someone that went thought the work this documents the journey across the [potato](https://www.github.com/beef331/potato) fields.

## Dynamic libraries - I swear they just keep moving on me.

For those not in the know a dynamic library is a compiled blob of code that you can load at runtime.
Enabling both the abillity to add new code and to replace implementations.
They have a symbol table which lets users search for and access procedures and variables once loaded.
It is this which will allow us to write hot code reload.
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
This can be expanded to use tagged unions instead to enable storing more complex state(infact in potato deeply nested structures save just fine!)
"""

nbSave()
