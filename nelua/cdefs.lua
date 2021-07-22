local tabler = require 'nelua.utils.tabler'

local cdefs = {}

cdefs.types_printf_format = {
  nlfloat32     = '"%.7g"',
  nlfloat64     = '"%.14g"',
  nlpointer     = '"%p"',
  nlisize       = '"%" PRIiPTR',
  nlint8        = '"%" PRIi8',
  nlint16       = '"%" PRIi16',
  nlint32       = '"%" PRIi32',
  nlint64       = '"%" PRIi64',
  nlusize       = '"%" PRIuPTR',
  nluint8       = '"%" PRIu8',
  nluint16      = '"%" PRIu16',
  nluint32      = '"%" PRIu32',
  nluint64      = '"%" PRIu64',
  -- C types
  nlcstring     = '"%s"',
  nlcchar       = '"%c"',
  nlcschar      = '"%c"',
  nlcshort      = '"%i"',
  nlcint        = '"%i"',
  nlclong       = '"%li"',
  nlclonglong   = '"%lli"',
  nlcptrdiff    = '"%" PRIiPTR',
  nlcuchar      = '"%u"',
  nlcushort     = '"%u"',
  nlcuint       = '"%u"',
  nlculong      = '"%lu"',
  nlculonglong  = '"%llu"',
  nlcsize       = '"%lu"',
  nlclongdouble = '"%.19Lg"',
}

cdefs.primitive_typenames = {
  nlisize       = {'intptr_t', '<stdint.h>'},
  nlint8        = {'int8_t', '<stdint.h>'},
  nlint16       = {'int16_t', '<stdint.h>'},
  nlint32       = {'int32_t', '<stdint.h>'},
  nlint64       = {'int64_t', '<stdint.h>'},
  nlint128      = '__int128',
  nlusize       = {'uintptr_t', '<stdint.h>'},
  nluint8       = {'uint8_t', '<stdint.h>'},
  nluint16      = {'uint16_t', '<stdint.h>'},
  nluint32      = {'uint32_t', '<stdint.h>'},
  nluint64      = {'uint64_t', '<stdint.h>'},
  nluint128     = 'unsigned __int128',
  nlfloat32     = 'float',
  nlfloat64     = 'double',
  nlfloat128    = '_Float128',
  nlboolean     = {'bool', '<stdbool.h>'},
  nlcstring     = 'char*',
  nlpointer     = 'void*',
  nlnilptr      = 'void*',
  nlvoid        = 'void',
  -- C types
  nlcvalist     = {'va_list', '<stdarg.h>'},
  nlcvarargs    = '...',
  nlcchar       = 'char',
  nlcschar      = 'signed char',
  nlcshort      = 'short',
  nlcint        = 'int',
  nlclong       = 'long',
  nlclonglong   = 'long long',
  nlcptrdiff    = {'ptrdiff_t', '<stddef.h>'},
  nlcuchar      = 'unsigned char',
  nlcushort     = 'unsigned short',
  nlcuint       = 'unsigned int',
  nlculong      = 'unsigned long',
  nlculonglong  = 'unsigned long long',
  nlcsize       = {'size_t', '<stddef.h>'},
  nlclongdouble = 'long double',
}

cdefs.builtins_headers = {
  -- stddef.h
  NULL = '<stddef.h>',
  -- stdbool.h
  ["false"] = '<stdbool.h>',
  ["true"] = '<stdbool.h>',
  -- stdio.h
  fwrite = '<stdio.h>',
  fputc = '<stdio.h>', fputs = '<stdio.h>',
  fprintf = '<stdio.h>', snprintf = '<stdio.h>',
  fflush = '<stdio.h>',
  stderr = '<stdio.h>', stdout = '<stdio.h>',
  -- stdlib.h
  abort = '<stdlib.h>',
  exit = '<stdlib.h>',
  -- string.h
  strlen = '<string.h>',
  strspn = '<string.h>',
  memcmp = '<string.h>',
  -- math.h
  fmodf = '<math.h>', fmod = '<math.h>',
  floorf = '<math.h>', floor = '<math.h>',
  truncf = '<math.h>', trunc = '<math.h>',
  powf = '<math.h>', pow = '<math.h>',
  -- inttypes.h
  PRIiPTR = '<inttypes.h>', PRIuPTR = '<inttypes.h>', PRIxPTR = '<inttypes.h>',
  PRIi8 = '<inttypes.h>', PRIu8 = '<inttypes.h>',
  PRIi16 = '<inttypes.h>', PRIu16 = '<inttypes.h>',
  PRIi32 = '<inttypes.h>', PRIu32 = '<inttypes.h>',
  PRIi64 = '<inttypes.h>', PRIu64 = '<inttypes.h>',
}

cdefs.for_compare_ops = {
  le = '<=',
  ge = '>=',
  lt = '<',
  gt = '>',
  ne = '!=',
  eq = '==',
}

cdefs.search_compilers = {
  'gcc', 'clang',
  'x86_64-w64-mingw32-gcc', 'x86_64-w64-mingw32-clang',
  'i686-w64-mingw32-gcc', 'i686-w64-mingw32-clang',
  'cc'
}

local compilers_flags = {}
cdefs.compilers_flags = compilers_flags

-- Generic CC
compilers_flags.cc = {
  cflags_base = "",
  cflags_release = "-O2 -DNDEBUG",
  cflags_maximum_performance = "-O3 -DNDEBUG",
  cflags_debug = "",
  cflags_shared = "-shared -fPIC",
  cflags_static = "-c",
  cmd_compile = '$(cc) "$(cfile)" -o "$(binfile)" $(cflags)',
  cmd_info = '$(cc) -E "$(cfile)" $(cflags)',
  cmd_defines = '$(cc) -E -dM $(cflags) "$(cfile)"',
  ext = '.c',
}
-- GCC
compilers_flags.gcc = tabler.update(tabler.copy(compilers_flags.cc), {
  cflags_base = "-fwrapv",
  cflags_release = "-O2 -fno-plt -DNDEBUG",
  cflags_maximum_performance = "-Ofast -fno-plt -flto -march=native -DNDEBUG",
  cflags_debug = "-g",
  cmd_compile = '$(cc) -x c "$(cfile)" -o "$(binfile)" $(cflags)',
  cmd_info = '$(cc) -x c -E "$(cfile)" $(cflags)',
  cmd_defines = '$(cc) -x c -E -dM $(cflags) "$(cfile)"',
})
-- TCC
compilers_flags.tcc = tabler.update(tabler.copy(compilers_flags.cc), {
  cflags_base = "-w",
})
-- C2M
compilers_flags.c2m = tabler.update(tabler.copy(compilers_flags.cc), {
  cflags_base = "-w",
  cflags_shared = "-c",
})
-- GCC (C++)
compilers_flags['g++'] = tabler.update(tabler.copy(compilers_flags.gcc), {
  cmd_compile = '$(cc) -x c++ "$(cfile)" -o "$(binfile)" $(cflags)',
  cmd_info = '$(cc) -x c++ -E "$(cfile)" $(cflags)',
  cmd_defines = '$(cc) -x c++ -E -dM $(cflags) "$(cfile)"',
  ext = '.cpp',
})
-- Clang
compilers_flags.clang = tabler.copy(compilers_flags.gcc)
-- Clang (C++)
compilers_flags['clang++'] = tabler.copy(compilers_flags['g++'])

-- Code to detect target features.
cdefs.target_info_code = [[
/* OS */
#if defined(__linux)
is_linux = true;
#endif
#if defined(__WIN32__) || defined(__WIN32) || defined(WIN32)
is_win32 = true;
is_windows = true;
#endif
#if defined(__WIN64__) || defined(__WIN64) || defined(WIN64)
is_win64 = true;
is_windows = true;
#endif
#if defined(__WINNT__) || defined(__WINNT) || defined(WINNT)
is_winnt = true;
is_windows = true;
#endif
#if defined(__linux__) || defined(__linux) ||  defined(linux)
is_linux = true;
#endif
#if defined(__unix__) || defined(__unix) ||  defined(unix)
is_unix = true;
#endif
#if defined(__gnu_linux__)
is_gnu_linux = true;
#endif
#if defined(__APPLE__)
is_apple = true;
#endif
#if defined(__MACH__)
is_mach = true;
#endif
/* Compilers */
#if defined(__clang__)
is_clang = true;
#endif
#if defined(__GNUC__)
is_gcc = true;
gnuc = __GNUC__;
gnuc_minor = __GNUC_MINOR__;
gnuc_patchlevel = __GNUC_PATCHLEVEL__;
#endif
#if defined(__MINGW64__) || defined(__MINGW32__)
is_mingw = true;
#endif
#if defined(_MSC_VER)
is_msvc = true;
#endif
#if defined(__TINYC__)
is_tcc = true;
#endif
#if defined(__EMSCRIPTEN__)
is_emscripten = true;
#endif
#if defined(__mirc__)
is_mirc = true;
#endif
#if defined(__COMPCERT__)
is_ccomp = true;
#endif
/* Architectures */
#if defined(__wasm__) || defined(__wasm)
is_wasm = true;
#endif
#if defined(__x86_64__) || defined(__x86_64) || \
    defined(__amd64__) || defined(__amd64) || \
    defined(_M_X64) || defined(_M_AMD64)
is_x86_64 = true;
#endif
#if defined(__i386__) || defined(__i386) || defined(_M_X86)
is_x86_32 = true;
#endif
#if defined(__ARM_EABI__) || defined(__aarch64__)
is_arm = true;
#endif
#if defined(__aarch64__)
is_arm64 = true;
#endif
#if defined(__riscv)
is_riscv = true;
#endif
/* C standard */
#if defined(__STDC__)
is_c = true
stdc = true;
#endif
#if defined(__STDC_HOSTED__)
stdc_hosted = true;
#endif
#if defined(__STDC_VERSION__)
stdc_version = __STDC_VERSION__;
#endif
#if defined(__STDC_NO_THREADS__)
stdc_no_threads = true;
#endif
#if defined(__STDC_NO_ATOMICS__)
stdc_no_atomics = true;
#endif
#if defined(__STDC_NO_COMPLEX__)
stdc_no_complex = true;
#endif
#if defined(__STDC_NO_VLA__)
stdc_no_vla = true;
#endif
#if !defined(__cplusplus)
is_c = true;
#endif
/* C++ standard */
#if defined(__cplusplus)
is_cpp = true;
cplusplus = __cplusplus;
#endif
/* Primitive sizes */
#if defined(__SIZEOF_DOUBLE__)
sizeof_double = __SIZEOF_DOUBLE__;
#endif
#if defined(__SIZEOF_FLOAT__)
sizeof_float = __SIZEOF_FLOAT__;
#endif
#if defined(__SIZEOF_INT__)
sizeof_int = __SIZEOF_INT__;
#endif
#if defined(__SIZEOF_LONG_DOUBLE__)
sizeof_long_double = __SIZEOF_LONG_DOUBLE__;
#endif
#if defined(__SIZEOF_LONG_LONG__)
sizeof_long_long = __SIZEOF_LONG_LONG__;
#endif
#if defined(__SIZEOF_LONG__)
sizeof_long = __SIZEOF_LONG__;
#endif
#if defined(__SIZEOF_POINTER__)
sizeof_pointer = __SIZEOF_POINTER__;
#endif
#if defined(__SIZEOF_PTRDIFF_T__)
sizeof_ptrdiff_t = __SIZEOF_PTRDIFF_T__;
#endif
#if defined(__SIZEOF_SHORT__)
sizeof_short = __SIZEOF_SHORT__;
#endif
#if defined(__SIZEOF_SIZE_T__)
sizeof_size_t = __SIZEOF_SIZE_T__;
#endif
/* Endianess */
#if defined(__BYTE_ORDER__)
byte_order = __BYTE_ORDER__;
#endif
#if defined(__ORDER_LITTLE_ENDIAN__)
order_little_endian = __ORDER_LITTLE_ENDIAN__;
#endif
#if defined(__ORDER_BIG_ENDIAN__)
order_big_endian = __ORDER_BIG_ENDIAN__;
#endif
]]

cdefs.reserverd_keywords = {
  -- C syntax keywords
  ['auto'] = true,
  ['break'] = true,
  ['case'] = true,
  ['char'] = true,
  ['const'] = true,
  ['continue'] = true,
  ['default'] = true,
  ['do'] = true,
  ['double'] = true,
  ['else'] = true,
  ['enum'] = true,
  ['extern'] = true,
  ['float'] = true,
  ['for'] = true,
  ['goto'] = true,
  ['if'] = true,
  ['int'] = true,
  ['long'] = true,
  ['register'] = true,
  ['return'] = true,
  ['short'] = true,
  ['signed'] = true,
  ['sizeof'] = true,
  ['static'] = true,
  ['struct'] = true,
  ['switch'] = true,
  ['typedef'] = true,
  ['union'] = true,
  ['unsigned'] = true,
  ['void'] = true,
  ['volatile'] = true,
  ['while'] = true,
  ['inline'] = true,
  ['restrict'] = true,
  ['asm'] = true,
  ['fortran'] = true,

  -- C macros aliases
  ['alignas'] = true,
  ['alignof'] = true,
  ['offsetof'] = true,
  ['bool'] = true,
  ['complex'] = true,
  ['imaginary'] = true,
  ['noreturn'] = true,
  ['static_assert'] = true,
  ['thread_local'] = true,

  -- C operator aliases
  ['and'] = true,
  ['and_eq'] = true,
  ['bitand'] = true,
  ['bitor'] = true,
  ['compl'] = true,
  ['not'] = true,
  ['not_eq'] = true,
  ['or'] = true,
  ['or_eq'] = true,
  ['xor'] = true,
  ['xor_eq'] = true,

  -- C macros used internally by compilers
  ['NULL'] = true,
  ['NAN'] = true,
  ['EOF'] = true,
  ['INFINITY'] = true,
  ['BUFSIZ'] = true,

  ['errno'] = true,
  ['stderr'] = true,
  ['stdin'] = true,
  ['stdout'] = true,
  ['assert'] = true,

  -- C arch defines
  ['i386'] = true,
  ['linux'] = true,
  ['mips'] = true,
  ['near'] = true,
  ['powerpc'] = true,
  ['unix'] = true,
}

cdefs.template = [[
/* ------------------------------ DIRECTIVES -------------------------------- */
$(directives)
/* ------------------------------ DECLARATIONS ------------------------------ */
$(declarations)
/* ------------------------------ DEFINITIONS ------------------------------- */
$(definitions)
]]


function cdefs.quotename(name)
  if cdefs.reserverd_keywords[name] then
    return name .. '_'
  end
  return name
end

return cdefs
