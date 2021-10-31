import nimib
nbInit()

nbText"""
To begin let's look at the most basic example of Nim metaprogramming.
Templates! These are very simple code subsitutions.
When you call a template it pastes it's body with the code replaced at the callsite"
Now you might be asking "Now what does that look like?!"
"""

nbCode:
  template thisIsATemplate() = echo "Hello from template"
  thisIsATemplate()

nbText"""
In this case when we call `thisIsATemplate` it simply just pastes `echo "Hello from template"`.
Now to look at a more elaborate example that uses passed in symbols.
```nim
template makeVar(name, value: untyped) =
  var name = value
makeVar(hello, "world")
echo hello
```
"""

nbText"""
"What does this template do, what's `untyped`?!"

Nim has two built in types for metaprogramming `typed` and `untyped`.
The latter is used for passing code that you do not want to be semantically checked, which means you do not want it checked in the compiler just the straight code from the value.
Now what the template does, you can compile your program with `--expandMacro:makeVar` or use `macros.expandMacros` and it'll show you exactly what it did.
"""

nbCode:
  import std/macros
  template makeVar(name, value: untyped) =
    var name = value
  expandMacros:
    makeVar(hello, "world")

nbText"""
This outputs the following at compile time:
```nim
var hello = "world"
```
As you can see all it did was paste the `name` and `value` parameter into the statement.
With a minor modification we've succesfully made the Go walrus operator.
```
template `:=`(name, value: untyped) = var name = value
```
"""



















nbSave()
