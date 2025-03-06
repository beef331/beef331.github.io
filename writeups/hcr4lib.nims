--app:lib
--nimMainPrefix:"hcr"
when defined(linux):
  --o:"libhcr.so"
elif defined(windows):
  --o:"libhcr.dll"
else:
  --o:"libhcr.dylib"
