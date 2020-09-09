require 'busted.runner'()

local config = require 'nelua.configer'.get()
local assert = require 'spec.tools.assert'

describe("Nelua should parse and generate Lua", function()

it("empty file", function()
  assert.generate_lua("", "")
end)
it("return", function()
  assert.generate_lua("return")
  assert.generate_lua("return 1")
  assert.generate_lua("return 1, 2")
end)
it("number", function()
  assert.generate_lua("return 1, 1.2, 1e2, 1.2e3, 0x1f, 0b10",
                      "return 1, 1.2, 1e2, 1.2e3, 0x1f, 0x2")
  assert.generate_lua("return 0x3p5, 0x3.5, 0x3.5p7, 0xfa.d7p-5, 0b11.11p2",
                      "return 0x60, 3.3125, 0x1a8, 7.8387451171875, 0xf")
  assert.generate_lua("return 0x0, 0xffffp4",
                      "return 0x0, 0xffff0")
  assert.generate_lua("return 0xffffffffffffffff.001",
                      "return 1.8446744073709552e+19")
end)
it("string", function()
  assert.generate_lua([[return 'a', "b", [=[c]=] ]], [[return "a", "b", "c"]])
  assert.generate_lua([[return "'", '"']])
  assert.generate_lua([[return "'\001", '"\001']])
end)
it("boolean", function()
  assert.generate_lua("return true, false")
end)
it("nil", function()
  assert.generate_lua("return nil")
end)
it("varargs", function()
  assert.generate_lua("return ...")
end)
it("table", function()
  assert.generate_lua("return {}")
  assert.generate_lua('local a\nreturn {a, "b", 1}')
  assert.generate_lua('return {a = 1, [1] = 2}')
end)
it("function", function()
  assert.generate_lua("return function() end")
  assert.generate_lua("return function()\n  return\nend")
  assert.generate_lua("return function(a, b, c) end")
end)
it("indexing", function()
  assert.generate_lua("local a\nreturn a.b")
  assert.generate_lua("local a, b\nreturn a[b], a[1]")
  assert.generate_lua('return ({})[1]', 'return ({})[1]')
  assert.generate_lua('return ({}).a', 'return ({}).a')
end)
it("call", function()
  assert.generate_lua("local f\nf()")
  assert.generate_lua("local f\nreturn f()")
  assert.generate_lua("local f, g\nf(g())")
  assert.generate_lua("local f, a\nf(a, 1)")
  assert.generate_lua("local f\nf 'a'", 'local f\nf("a")')
  assert.generate_lua("local f\nf {}", 'local f\nf({})')
  assert.generate_lua('local a\na.f()')
  assert.generate_lua('local a\na.f "s"', 'local a\na.f("s")')
  assert.generate_lua("local a\na.f {}", "local a\na.f({})")
  assert.generate_lua("local a\na:f()")
  assert.generate_lua("local a\nreturn a:f()")
  assert.generate_lua("local a\na:f(a, 1)")
  assert.generate_lua('local a\na:f "s"', 'local a\na:f("s")')
  assert.generate_lua("local a\na:f {}", 'local a\na:f({})')
  --assert.generate_lua('("a"):len()', '("a"):len()')
  assert.generate_lua('local g\ng()()', 'local g\ng()()')
  assert.generate_lua('({})()', '({})()')
  --assert.generate_lua('("a"):f()', '("a"):f()')
  assert.generate_lua('local g\ng():f()', 'local g\ng():f()')
  assert.generate_lua('({}):f()', '({}):f()')
end)
it("if", function()
  assert.generate_lua("local a\nif a then\nend")
  assert.generate_lua("local a, b\nif a then\nelseif b then\nend")
  assert.generate_lua("local a, b\nif a then\nelseif b then\nelse\nend")
end)
it("switch", function()
  assert.generate_lua("switch 0 case 1 then else end", [[
local __switchval1 = 0
if __switchval1 == 1 then
else
end]])
  assert.generate_lua("switch 0 case 1 then local f f() case 2 then local g g() else local h h() end",[[
local __switchval1 = 0
if __switchval1 == 1 then
  local f
  f()
elseif __switchval1 == 2 then
  local g
  g()
else
  local h
  h()
end]])
end)
it("do", function()
  assert.generate_lua("do\n  return\nend")
end)
it("while", function()
  assert.generate_lua("local a\nwhile a do\nend")
end)
it("repeat", function()
  assert.generate_lua("local a\nrepeat\nuntil a")
end)
it("for", function()
  assert.generate_lua("for i=1,10 do\nend")
  assert.generate_lua("for i=1,10,2 do\nend")
  assert.generate_lua("local a, f\nfor i in a, f() do\nend")
  assert.generate_lua("local f\nfor i, j, k in f() do\nend")
  assert.generate_lua("local f\nfor _ in f() do\nend", "local f\nfor _ in f() do\nend")
end)
it("break", function()
  assert.generate_lua("while true do\n  break\nend")
end)
it("goto", function()
  assert.generate_lua("::mylabel::\ngoto mylabel")
end)
it("variable declaration", function()
  assert.generate_lua("local a")
  assert.generate_lua("local a = 1")
  assert.generate_lua("local a, b, c = 1, 2, nil")
  assert.generate_lua("local a, b, c = 1, 2, 3")
  assert.generate_lua("local a, b = 1", "local a, b = 1, nil")
  assert.generate_lua("local function f() local a end", "local function f()\n  local a\nend")
end)
it("assignment", function()
  assert.generate_lua("local a: any\na = 1", "local a\na = 1")
  assert.generate_lua("local a: any, b: any\na, b = 1, 2", "local a, b\na, b = 1, 2")
  assert.generate_lua("local a: any, x: any, y: any\na.b, a[1] = x, y", "local a, x, y\na.b, a[1] = x, y")
end)
it("function definition", function()
  assert.generate_lua("local function f()\nend")
  assert.generate_lua("local function f()\nend")
  assert.generate_lua("local function f(a)\nend")
  assert.generate_lua("local function f(a, b, c)\nend")
  assert.generate_lua("local a\nfunction a.f()\nend")
  assert.generate_lua("local a\nfunction a.b.f()\nend")
  assert.generate_lua("local a\nfunction a:f()\nend")
  assert.generate_lua("local a\nfunction a.b:f()\nend")
  assert.generate_lua(
    "local function f(a: integer): integer\nreturn 1\nend",
    "local function f(a)\n  return 1\nend")
end)
it("unary operators", function()
  assert.generate_lua("local a\nreturn not a")
  assert.generate_lua("local a\nreturn -a")
  assert.generate_lua("local a\nreturn ~a")
  assert.generate_lua("local a\nreturn #a")
end)
it("binary operators", function()
  assert.generate_lua("local a, b\nreturn a or b, a and b")
  assert.generate_lua("local a, b\nreturn a ~= b, a == b")
  assert.generate_lua("local a, b\nreturn a <= b, a >= b")
  assert.generate_lua("local a, b\nreturn a < b, a > b")
  assert.generate_lua("local a, b\nreturn a | b, a ~ b, a & b")
  assert.generate_lua("local a, b\nreturn a << b, a >> b")
  assert.generate_lua("local a, b\nreturn a + b, a - b")
  assert.generate_lua("local a, b\nreturn a * b, a / b, a // b")
  assert.generate_lua("local a, b\nreturn a % b")
  assert.generate_lua("local a, b\nreturn a ^ b")
  assert.generate_lua("local a, b\nreturn a .. b")
end)
it("lua 5.1 compat operators", function()
  config.lua_version = '5.1'
  assert.generate_lua("local a\nreturn ~a", "local a\nreturn bit.bnot(a)")
  assert.generate_lua("local a, b\nreturn a // b", "local a, b\nreturn math.floor(a / b)")
  assert.generate_lua("local a, b\nreturn a ^ b", "local a, b\nreturn math.pow(a, b)")
  assert.generate_lua("local a, b\nreturn a | b", "local a, b\nreturn bit.bor(a, b)")
  assert.generate_lua("local a, b\nreturn a & b", "local a, b\nreturn bit.band(a, b)")
  assert.generate_lua("local a, b\nreturn a ~ b", "local a, b\nreturn bit.bxor(a, b)")
  assert.generate_lua("local a, b\nreturn a << b", "local a, b\nreturn bit.lshift(a, b)")
  assert.generate_lua("local a, b\nreturn a >> b", "local a, b\nreturn bit.rshift(a, b)")
  config.lua_version = '5.3'
end)
it("typed var initialization", function()
  assert.lua_gencode_equals("local a: integer", "local a: integer = 0")
  assert.lua_gencode_equals("local a: boolean", "local a: boolean = false")
  assert.lua_gencode_equals("local a: table", "local a: table = {}")
end)

end)
