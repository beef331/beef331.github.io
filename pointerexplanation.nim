import nimib
nbInit()
nb.darkMode()
nb.title = "Nim - Pointer, confusing scary and over there."
nbText:"""
## Preamble - the planning phase

If you have ever looked at library bindings for C code, you have certainly seen the scary `pointer` keyword.
At first reading you may get nervous, scared and maybe even pee a little.
Not to worry this writeup will hopefully explain how to gracefully walk with pointers in Nim.

Imagine a world where you're presented with the following api, it could even be this world now:

"""
nbCode:
  type ProcType = proc(a: pointer, msg: string){.nimcall.}

  var myRegisteredObjs: seq[(pointer, ProcType)] ## Global collection for all events


  proc invoke(msg: string = "") =
    ## This calls the callbacks passing the pointer and `msg`.
    for i in 0..myRegisteredObjs.high:
      let (obj, cb) = myRegisteredObjs[i]
      cb(obj, msg)

  proc registerEvent(obj: pointer, prc: ProcType) =
    ## Adds an object and proc to the event list.
    when compileOption"checks":
      for (otherObj, cb) in myRegisteredObjs.items:
        assert obj != otherObj
    myRegisteredObjs.add (obj, prc)

  proc unregisterEvent(toRemove: pointer) =
    ## Removes an object and its coresponding callback from the event list
    for i, (obj, cb) in myRegisteredObjs.pairs:
      if obj == toRemove:
        myRegisteredObjs.del(i)
        break


nbText:"""
### Naivety - it never hurts
Hey this does not seem too complicated you have three procedures, how badly can we really mess it up.
You already might be thinking to yourself "ah yes we just do `addr` on the variable we want and write a proc for it".
Knowing that `addr` returns the address of a variable, that sounds like a brilliant idea, let us give it a whirl.
"""

nbCode:
  proc doThing() =
    var a = 300 # Make our var
    proc myIntCallback(p: pointer, msg: string) {.nimcall.} =
      ## Our procedure to run on `invoke`
      let myVal = cast[ptr int](p)[] ## Get the `ptr int` back from the type erasure
      echo msg, " ", myVal

    registerEvent(a.addr, myIntCallBack) # Add the integer
    invoke()


  doThing()
  invoke()

nbText:"""
The above output is from running with `--gc:arc`(refc is not deterministic so it may appear as if its working fine) and it shows a very odd issue, we did not mutate `a` but we got something other than `300`, how could this be?!
"""

myRegisteredObjs = @[]

nbText:"""
### Manual Memory Management - Putting the C in Nim
If you already know about stack memory vs. heap memory the answer is as clear as transparent aluminium.
`a` is a value type, which means its placed on the stack.
Stack memory is a part of memory that is often overwritten due to being used for value types declared in procedures,
since we are taking a pointer to that memory calling procedures that use the stack will unintentionally overwrite it.
This is called a "dangling pointer".
We can get around dangling pointers by using heap memory.
Heap memory is dynamically allocated and freed,
that means we can make variables outlive their procedure.
To accomplish this we will go with the C-like method of manually allocating and freeing.
"""


nbCode:
  proc doThingPtr() =
    var a = create(int) # heap allocate using un GC'd memory
    a[] = 400 # Make the heap int == 400
    proc myIntCallback(p: pointer, msg: string) {.nimcall.} =
      ## Our procedure to run on `invoke`
      let myVal = cast[ptr int](p)[] ## Get the `ptr int` back from the type erasure
      echo myVal
      if msg == "dealloc": ## Just to allow us to dealloc here
        unregisterEvent(p)
        dealloc(p)
    registerEvent(a, myIntCallBack) ## Notice we do not do `addr` since we already have a `ptr int`
    invoke()


  doThingPtr()
  invoke("dealloc")

nbtext:"""
`400` twice that is good, but how do we know what that memory is getting freed.
If on Linux you can use your new favourite friend `valgrind`.
Compiling the program with `--gc:arc -d:useMalloc`, `-d:useMalloc` is important as Nim's allocator does not play nice with valgrind.
Now the program can be ran with valgrind by doing `valgrind ./MyProgramName`.

After running we get a beautiful message:
```
HEAP SUMMARY:
in use at exit: 0 bytes in 0 blocks
total heap usage: 5 allocs, 5 frees, 1,080 bytes allocated
All heap blocks were freed -- no leaks are possible
```
This is great, everything that was allocated was returned.
"""


nbText:"""
### References - the well dressed pointers
You might be thinking to yourself "Pointers are cool, but is this really all Nim has, a fancy 'create' template".
That thought is missing the detail that Nim's `ref`s can be cast to `pointer` relatively safely.
To continue with the project of reptitive nature, time to implement the `doThing` over yet again with a `ref int` instead.
"""

nbCode:
  proc doThingRef() =
    var a = new(int) # heap allocate using gc'd memory
    a[] = 400 # Make the heap int == 400
    proc myIntCallback(p: pointer, msg: string) {.nimcall.} =
      ## Our procedure to run on `invoke`
      let myVal = cast[ref int](p)[] ## Get the `ref int` back from the type erasure
      echo myVal
      if msg == "dealloc": ## Just to allow us to dealloc here
        unregisterEvent(p)
    registerEvent(cast[pointer](a), myIntCallBack) ## Notice we do not do `addr` since we already have a `ptr int`
    invoke()


  doThingRef()
  invoke()
  invoke()
  invoke("dealloc")

nbText:"""
I am not a mathematician but that is not `400` 4 times.
Much like pointers references are heap allocated but their lifetime is based off of the Garbage Collected(GC) code,
which means in the above code when we cast to `pointer` Nim loses that the references are suppose to persist.
Nim provides a `GCRef` procedure which allows you to manually increment the reference's lifetime counter.
This allows you to use Nim's references but persist and even leak them if you miss use it.
No procedure is complete without a negation and in this case that negation is `GcUnref` as one might assume this decrements the reference's lifetime counter.
The following is the fixed reference code that properly manages the `ref`.
"""

nbCode:
  proc doThingRefFixed() =
    var a = new(int) # heap allocate using gc'd memory
    a[] = 400 # Make the heap int == 400
    GcRef(a) # Extend the lifetime of `a`
    proc myIntCallback(p: pointer, msg: string) {.nimcall.} =
      ## Our procedure to run on `invoke`
      let myVal = cast[ref int](p)[] ## Get the `ref int` back from the type erasure
      echo myVal
      if msg == "dealloc": ## Just to allow us to dealloc here
        unregisterEvent(p)
        GcUnref(cast[ref int](p)) ## Reduces lifetime back to 0, and get's GC to free it
    registerEvent(cast[pointer](a), myIntCallBack) # Notice we do not do `addr` since we already have a `ptr int`
    invoke()


  doThingRefFixed()
  invoke()
  invoke()
  invoke("dealloc")


nbText:"""
That looks right, before we pop the champagne maybe we should ensure it using valgrind again.

```
HEAP SUMMARY:
in use at exit: 0 bytes in 0 blocks
total heap usage: 10 allocs, 10 frees, 1,144 bytes allocated
All heap blocks were freed -- no leaks are possible
```
That is all I need to read to be happy.
"""

nbText:"""
## Collections - Gotta collect'em all
Many times interacting with C you will see `ptr UncheckedArray[T]` or `ptr T` which points you to the first element in an array.
This is very tedious work with if you use it like in C.
Consider the following C API imported to Nim.
"""
nbCode:
  {.emit:"""

// Get a dynamically allocated integer buffer
int* getIntBuff(int* len){
  int* buff = malloc(5 * sizeof(int));
  for(int i = 0; i < 5; i++){
    buff[i] = i;
  }
  (*len) = 5;
  return buff;
}

// Frees the dynamically allocated buffer
void freeIntBuff(int* buff){
  free(buff);
}
""".}

  proc getIntBuff(len: var cint): ptr UncheckedArray[cint] {.importc.}
  proc freeIntBuff(buff: ptr UncheckedArray[cint]) {.importc.}

nbText:"""
Notice that we used `var cint` instead of `ptr cint` this can be done when you know the code just uses it as a mutable reference.
This is a fairly simple API, we just call `getIntBuffer` use the buffer then when finished call `freeIntBuff` to deallocate it.
So let's do that, though we will print the values out.
"""

nbcode:
  var
    len = cint 0
    myBuff = getIntBuff(len)
  stdout.write "Output: "
  for i in 0..<len:
    stdout.write i
    stdout.write ':'
    stdout.write myBuff[i]
    if i < len - 1:
      stdout.write ", "
    else:
      stdout.write '\n'
      stdout.flushFile
  myBuff.freeIntBuff()


nbText:"""
When dealing with C arrays there is a slightly better way of writing the above.
`toOpenArray` allows you to more easily iterate a C array it supports the common `items`, `pairs`, and `mitems` iterators enabling less redundant code.
"""

nbCode:
  var
    myLen = cint 0
    myBuffNew = getIntBuff(myLen)
  stdout.write "Output: "
  for i, x in myBuffNew.toOpenArray(0, myLen - 1):
    stdout.write i
    stdout.write ':'
    stdout.write x
    if i < myLen - 1:
      stdout.write ", "
    else:
      stdout.write '\n'
      stdout.flushFile
  myBuffNew.freeIntBuff()


nbText:"""
This contrived example leads us into a more common case of `ptr T`, passing arrays to libraries.
To start this off we will look at even more C code that will be wrapped in a nice Nim API.
"""
nbCode:
  {.emit:"""

// Iterate the collection printing output
void printFloatArray(float* arr, int len){
  printf("'arr' contains: ");
  for(int i = 0; i < len; i++){
    printf("%f ", arr[i]);
  }
  printf("\n");
}
  """.}
  proc printFloatArray(arr: ptr UncheckedArray[float32], len: cint) {.importC, nodecl.}
  var
    myTestArr = [1f, 5, 10.321]
    myTestSeq = @[0f, 2, 3.14159, 3213, 42]
  printFloatArray(cast[ptr UncheckedArray[float32]](myTestArr.addr), cint myTestArr.len)
  printFloatArray(cast[ptr UncheckedArray[float32]](myTestSeq.addr), cint myTestSeq.len)

nbText:"""
Odd the array works but the sequence fails.
This is a similar issue to the one before `array` is a stack allocated value so its address is the address of the first element whereas `seq` is a heap allocated value.
`seq` being heap allocated is due to the fact its a growable array.
Its length is unknown at compile time and as such is heap allocated.
Implementation aside due to the `array` printing fine we know that we want the same thing a pointer to the first element of the collection.
So we can index the first value and take it's address.
"""
nbCode:
  printFloatArray(cast[ptr UncheckedArray[float32]](myTestSeq[0].addr), cint myTestSeq.len)

nbText:"""
Important to note is that this is only the proper way to interoping with a procedure that operates on the collection then releases it.
If the procedure holds onto reference you can have a dangling pointer to the heap of the sequence.
Like prior this can either be solved with `GCRef` as before or with manual allocations.
Since `seq` is growable if you `add` to the `seq` you can cause it to move memory and deallocate the old collection so choose wisely on your solution.
"""

nbSave()
