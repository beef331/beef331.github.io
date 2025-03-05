--app:lib

when defined(linux):
  --o:"libhcr.so"
elif defined(windows):
  --o:"libhcr.dll"
else:
  --o:"libhcr.dylib"
