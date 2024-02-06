# Nelua's Lua Interpreter

This is the Lua 5.4.6 interpreter used by Nelua, with the following changes:

* Uses rpmalloc as the default memory allocator (usually much faster than the system's default memory allocator).
* Libraries "hasher", "lpeglabel", "sys" and "lfs" are bundled (they are required by Nelua compiler).
* Use a distribution friendly LUA_ROOT in luaconf.h
* Use -fno-crossjumping -fno-gcse in lua VM for a faster instruction execution.
* C compilation flags are tuned to squeeze more performance from the Lua interpreter.
* Execute `luainit.lua` code on startup, used to adjust `package.path`
to make Nelua compiler files available with `require`.

It is recommended to use this interpreter to have the same behavior
and because it can be ~30% faster than the standard Lua.
