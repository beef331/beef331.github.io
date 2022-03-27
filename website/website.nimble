# Package

version       = "0.1.0"
author        = "Jason"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["website"]


# Dependencies
requires "nim >= 1.5.1"
switch("d", "js")

task makeSite, "Makes the site dumbo":
  exec("karun -d:danger ./src/website.nim")
  mvFile("./app.html", "../index.html")
  mvFile("./app.js", "../app.js")