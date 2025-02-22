## --app:lib

type MyType = object
  a, b: int

proc doThing(typ: MyType) = echo "Hello"

var myVal = MyType(a: 100, b: 20)

proc potatoMain() {.exportc, dynlib.} = 
  doThing(myVal)  
