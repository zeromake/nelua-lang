local class = require 'pl.class'
local Scope = require 'euluna.scope'
local assertf = require 'euluna.utils'.assertf

local TraverserContext = class()

function TraverserContext:_init(traverser)
  self.scope = Scope()
  self.traverser = traverser
  self.asts = {}
end

function TraverserContext:push_scope()
  local scope = self.scope:fork()
  self.scope = scope
  return scope
end

function TraverserContext:pop_scope()
  self.scope = self.scope.parent
end

function TraverserContext:push_ast(ast)
  table.insert(self.asts, ast)
end

function TraverserContext:pop_ast()
  table.remove(self.asts)
end

function TraverserContext:get_parent_ast()
  return self.asts[#self.asts - 1]
end

local Traverser = class()

function Traverser:_init()
  self.visitors = {}
end

function Traverser:register(name, func)
  self.visitors[name] = func
end

function Traverser:traverse(ast, context, scope)
  assert(scope, 'no scope in traversal')
  local visitor_func = assertf(self.visitors[ast.tag], "visitor '%s' does not exist", ast.tag)
  context:push_ast(ast)
  visitor_func(ast, context, scope)
  context:pop_ast()
end

Traverser.Context = TraverserContext

return Traverser