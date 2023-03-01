import nimib
import std/[tables]

nbInit
nb.darkMode()

nbText"""
# Nim - Reuse, reuse, and reuse.

Much like outside programming one of the best things a programmer can do is reuse.
Nim has a few mechanisms to enable very good code reuse.
This writeup will demonstrate these best practices to ensure code is not written more than needed.
To start the build up of these mechanisms consider a procedure that iterates a sequence and prints each element.
"""

nbCodeInBlock:
  proc printAllValues[T](s: seq[T]) =
    for x in s:
      echo x



nbText"""
This is all fine and dandy now one can print all values of a sequence on their own line, but now consider using `printAllValues` on a `array[10, int]`.
One's reaction might be "I can just make an array variation"
"""

nbCodeInBlock:
  proc printAllValues[Idx, T](a: array[Idx, T]) =
    for x in a:
      echo x

nbText"""
See I personally had trouble in math aswell, to me that seems like two identical implementations of a procedure.
This nicely introduces the next part of the solution `openArray`.
"""


nbText"""
## OpenArrays - Slice and dice!

`openArray` (yes I have it on good authority that's how it's written) is what other languages call a slice.
It stores a pointer the start of data and the length of that slice.
Sequences and arrays implicitly convert to `openarray` inside a procedure call.
Whenever writing code one should always use an `openarray` if it fits in the design, this means unless you need a dynamic length you should use openarray.
Due to their implementation `openArray`s allow you to use memory safe collections like `array` or `seq`, but also allow manual managed collections as there is a `toOpenArray` that accepts a `ptr UncheckedArray[T]`.

Since there is a `toOpenArrayByte` for `openArray[char]` any code that operates on binary data should use `openArray[byte]` since it allows *all* collections to work with it, unlike `openArray[char]`, `string`, or `seq[byte]`.

So what can be done instead is write a procedure that operates on an `openArray[T]` as follows:
"""

nbCodeInBlock:
  proc printAllValues[T](oa: openArray[T]) =
    for x in oa:
      echo x

  [10, 20, 30].printAllValues()
  echo "Array'd"

  printAllValues @[10, 20, 30]
  echo "Seq'd"

  var a = cast[ptr UncheckedArray[int]](create(int, 100))
  a[0] = 300
  a[1] = 200
  a.toOpenArray(0, 1).printAllValues() # Look maw even raw ptrs?!
  echo "Ptr'd"
  dealloc(a)

nbText"""
Oh it's that easy?!
Yes, but now to interject this happy train of thought ... what if one wants to call this procedure with a table or any other collection?

## Unconstrained Generics - Kangaroo court is in session
Glossed over until this point generics are practically code subsitution.
They simply take in parameters and replace all instances of those generic parameters with the resolved version.
This process is called instantiation, which is why calling a procedure may create a mismatch error deep inside another library.
Generics have a feature called `mixin` which allow the compiler to look at the scope of instantion aswell as declaration for a symbol.
This allows something some refer to as a "Generic Interface", where user code allows overriding behaviour without runtime costs.
A possible solution for an unconstrained generic would look something like:
"""

nbCodeInBlock:
  proc printAllValues[T](coll: T) =
    mixin items
    ## Remember `mixin` tells the compiler "Look for this implementation at procedure declaration and instiantiation"
    for val in coll.items: # There is a bug with implicit `items` so calling it explicitly inside a generic is best health for everyone
      echo val


nbText"""
This is grand it is now a fully generic procedure that works on any type that implements a `items` iterator.
Now let us call it with a `(int, int)` and see what happens

```
Error: type mismatch: got <(int, int)>
but expected one of:
iterator items(a: cstring): char
  first type mismatch at position: 1
  required type for a: cstring
  but expression 'coll' is of type: (int, int)
...
```

Hmmmm ... that is an error message, what if there was a more clear way of indicating that something fit this procedure.
Calling Dr. Concept, Dr. Fine, Dr. Concept.

## Concept Constrained Generics - They're traits but not':
`concept`s are best thought of as user defined duck typing, what that means is the programmer defines the shape of the type for the procedure.
They do not exist at runtime and only are used for constraining generics.
There are two versions of `concept`s this will be looking at the more flexible old style of them.
The old variant of `concept`s are very eldritch to look at, but they are relatively simple.
All that happens is the compiler attempts to compile the statement and then checks if that line is a boolean and if it is true.
"""

nbCode:
  type Iterable = concept i # This introduces a var i: TheCheckedType
    for _ in i.items: discard # Ensure this type has a `items` iterator

  proc printAllValues[T: Iterable](iter: T) =
    mixin items # Still should mixin items
    for x in iter.items: # Still should call it explicitly here
      echo x

  iterator items[K, V](table: Table[K, V]): (K, V) =
    for x in table.pairs:
      yield x

  var a = {"a": "b", "b": "c"}.toTable
  printAllValues(a)
  printAllValues [10, 20]

  type MyType = object
    a: int

  iterator items(myType: MyType): int =
    for i in 0..<myType.a:
      yield i

  MyType(a: 2).printAllValues() # wow this works


nbText"""
The benefit of this approach is there is now an explicitly designed API, inside a procedure using a concept one should only use procedures the concept declares or that are certainly unconstrained.
To replicate the test of `(int, int)` previously done.
```
Error: type mismatch: got <(int, int)>
but expected one of:
proc printAllValues[T: Iterable](iter: T)
  first type mismatch at position: 1
  required type for iter: T: Iterable
  but expression '(10, 10)' is of type: (int, int)
```

This error message is a bit more clear we did not pass something that is `Iterable` so we then can look at the implementation of `Iterable` and see it needs an `items`.
Hopefully this starts the cogs spinning, but to look further in the capabilities of concepts and generics consider a command line program that can provide a message, have a default value and options.

## Prompter - not the tele kind that is a trademark
"""
nbCode:
  type
    Promptable = concept p, type P
      var str = ""
      writeParam(p) # Ensure a `writeParam` procedure takes an instance of this type
      parseInput(str, P) is P # Ensure there is a procedure that parses input returning `P`
      p == p is bool # We need to compare for `Defaultable`, best to be here

    Defaultable = concept type D
      defaultParam(D) is D # Check if we have a default parameter


    Optionable = concept type H
      paramOptions(H) is array or seq

    PrompterError = ref object of ValueError # Just an error we will use later

nbText"""
With these few concepts the world is ours!
These allow the user to provide very basic proc for their types in a way that is quite ergonomic.
Now implementing these is as simple as follows.
"""

nbCode:
  proc writeOptions[T: Promptable]() =
    mixin writeParam, paramOptions, defaultParam # Our generic interface procedures, mixin'd since we want users to override them
    stdout.write '['
    let
      opts = paramOptions(T)
      defult =
        when T is Defaultable: # Check if we have a `defaultParam` procedure in a type level way
          some(defaultParam(T))
        else:
          none(T)

    for i, x in opts.pairs:
      let isDefault = defult.isSome and x == defult.unsafeGet
      if isDefault:
        stdout.write '('
      writeParam(x)
      if isDefault:
        stdout.write ')'
      if i < opts.high:
        stdout.write ", "

    stdout.write ']'


  proc prompt*[T: Promptable](msg: string, optionsPostfix = ""): T =
    mixin defaultParam, parseInput # Same as above mix them in
    stdout.write msg, " "

    when T is Optionable: # Check if we have `paramOptions` at the type level
      writeOptions[T]()

    stdout.write optionsPostfix
    stdout.flushFile()

    let line = stdin.readLine()
    if line.len == 0 and T is Defaultable:
      defaultParam(T)
    else:
      parseInput(line, T)

nbText"""
The most interesting part of this entire setup is this lacks any assumption of the shape of the type that is used.
Since the only operations used on the `Promptable` type are inside the concept there will never be an instantiation error.
Finally the procedures can be implemented for a type, here a basic `bool` implementation lies:
"""

nbCode:

  proc paramOptions(_: typedesc[bool]): auto = [true, false]

  proc writeParam(b: bool) =
    stdout.write:
      if b:
        "Y"
      else:
        "N"

  proc defaultParam(_: typedesc[bool]): bool = true


  proc parseInput(input: string, _: typedesc[bool]): bool =
    case input
    of "y", "Y":
      true
    of "n", "N":
      false
    else:
      raise PrompterError(msg: "Invalid input, did not get Y/y/N/n")

  try:
    if prompt[bool]("Do you like ice cream?", " "):
      echo "Good!"
    else:
      echo "Well you suck"
  except PrompterError as e:
    echo e.msg

nbSave()
