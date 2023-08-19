add_rules("mode.debug", "mode.release")

option("rpmalloc")
    set_default(false)
option_end()

if is_plat("windows") then
    add_cxflags("/utf-8")
    if is_mode("release") then
        set_optimize("faster")
    end
end

if is_plat("linux") then
    add_defines("LUA_USE_LINUX")
elseif is_plat("windows", "mingw") then
    add_defines("LUA_USE_WINDOWS", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS")
elseif is_plat("macosx") then
    add_defines("LUA_USE_MACOSX")
else
    add_defines("LUA_USE_POSIX")
end

target("nelua-lua")
    add_defines("MAKE_LUA")
    add_includedirs("src/lua")
    add_files("src/*.c")
    if get_config("rpmalloc") then
        add_files("src/srpmalloc/*.c")
        add_defines("LUA_USE_RPMALLOC")
    end
    add_files("src/lpeglabel/*.c")
    set_rundir("$(projectdir)")

target("nelua-luac")
    add_defines("MAKE_LUAC")
    add_includedirs("src/lua")
    add_files("src/onelua.c")
    set_rundir("$(projectdir)")
