* lua_avconv.c is actually avconv.c with lua patches. Since it was not obvious 
to the author how to integrate into the standard build chain of libav to patch 
conditionally (based on a -DLUA flag or similar) and create a dinamic library,
a clone was splited (temporally) with the added patches and a temporal 
make_custom.sh to create a shared object

* Compilation depends on libav. The "make_custom.sh" has been adapted to a 
given layout structure.  Read the notes on make_custom.sh to configure/adapt 
the compilation.

* Read chapters 25 and 26 of "Programming in Lua" for more info:
  - http://www.lua.org/pil/25.html
  - http://www.lua.org/pil/26.html
