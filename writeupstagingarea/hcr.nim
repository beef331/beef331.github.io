import nimib
import std/[tables, os]

nbInit
nb.darkMode()

proc nbCodePath(name: string) =
  nbFile(name.changeFileExt(""), readFile(name))

nbText"""
# Swapping the Sand for the Idol

Sometimes one makes a mistake.
In some cases the mistake might be minor, but in the case of writing many compiled languages the mistake is often large.
"How can one recompile their code and keep state across reloads" is a question that keeps people awake due to these rigid beasts.
There are two paths that people generally take.
The rosy road is gold encrusted and has a sign labelled "scripting languages".
Taking this road allows one to store their state in their main program and just run procedures across that data.
Effectively preventing the issue of data persistence as the main code is never changed so no state needs migrated.
Another remnant of a path diverges into the juaane trees.
Overgrown and bush ridden it offers a different approach.
Simply have a host program which loads a library then on source change reload the code and migrate the data.
This will be the bushwacking journey across that path (moreover documenting what I went through with [potato](https://github.com/beef331/potato)).

## Basics of Reloading

The entire weight of relying on dynamic libraries to reload code of course relies on dynamic libraries.
For the uninitiated a dynamic library is a bit of compiled code that has exposed symbols the loading program can access and call into.
Consider how your OS can find `main` and invoke it to run a program.
That is what will be replicated here, but instead of `main` it could be `potatoMain`.
So the 'host' program really will be a simple daemon that watches over the dynamic library and calls into it.

To start off the following code is what will be wrapped to be dynamically loaded
"""

nbCodeSkip:
  type MyType = object
    a, b: int

  proc doThing(typ: var MyType) = discard

  var myVal = MyType(a: 100, b: 20)
  while true:
    doThing(myVal)    



nbText"""
So in this case the desire is to replace the `while true` with the 'host' program.
Really it is best to not rely on Nim's implicit `NimMain` invoke and move to a procedure.
With that change it now is a simple.

"""

nbCodePath"hcrlib1.nim"

nbText"""
The astute will already have magnifying glasses on `{.exportc, dynlib.}`.
`exportc` tells the Nim compiler not to mangle a procedure name and in this case it forces it to be named `potatoMain`.
This allows other code rely on the name of this procedure.
Secondly `dynlib` forces Nim(and by extension the C compiler) to keep the symbol alive even if it is not used.
As this is intended to be a dynamic library together it means a `potatoMain` now resides in the symbol table of the shared library.

With this as the studded plastic block the path forward depends upon a host program.
For now this host program will just be a hard coded "load a dynamic library at this path".
"""

nbCodePath"hcrhost1.nim" 

nbText"""
Just like that and the most simple version of hot code reload is done!
At this point some may just call it a plugin system since it can just reload any shared library named `libmylib`.
The code inside `hcrlib1` can be changed then recompiled then it will be reloaded automatically.
"""



nbSave()
