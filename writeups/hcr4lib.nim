import system/ansi_c
proc hcrError() {.importc, dynlib"".}
proc hcrQuit() {.importc, dynlib"".}

unhandledExceptionHook = proc(e: ref Exception) {.nimcall, gcsafe, raises: [], tags: [].}=
  try:
    {.cast(tags: []).}:
      for i, x in e.getStackTraceEntries:
        stdout.write x.fileName, "(", x.line, ") ", x.procName
        stdout.write "\n"
      stdout.write"Error: "
      stdout.writeLine e.msg
      stdout.flushFile()
      hcrError()
  except:
    discard


{.push stackTrace:off.}
proc signalHandler(sign: cint) {.noconv.} =
  if sign == SIGINT:
    hcrQuit()
    hcrError()
  elif sign == SIGSEGV:
    writeStackTrace()
    echo "SIGSEGV: Illegal storage access. (Attempt to read from nil?)"
    hcrError()
  elif sign == SIGABRT:
    writeStackTrace()
    echo "SIGABRT: Abnormal termination."
    hcrError()
  elif sign == SIGFPE:
    writeStackTrace()
    echo "SIGFPE: Arithmetic error."
    hcrError()
  elif sign == SIGILL:
    writeStackTrace()
    echo "SIGILL: Illegal operation."
    hcrError()
  elif (when declared(SIGBUS): sign == SIGBUS else: false):
    echo "SIGBUS: Illegal storage access. (Attempt to read from nil?)"
    hcrError()
{.pop.}

#c_signal(SIGINT, signalHandler)
c_signal(SIGSEGV, signalHandler)
c_signal(SIGABRT, signalHandler)
c_signal(SIGFPE, signalHandler)
c_signal(SIGILL, signalHandler)
when declared(SIGBUS):
  c_signal(SIGBUS, signalHandler)



proc saveInt(name: string, val: int) {.importc, dynlib"".}
proc getInt(name: string, val: var int): bool {.importc, dynlib"".}

var i = 0
if not getInt("i", i):
  i = 0 # Redundant but let's stay classy 

proc entry() {.exportc, dynlib.} =
  inc i
  echo i
  saveInt("i", i)
  if i >= 10:
    hcrQuit() # Leave this place
