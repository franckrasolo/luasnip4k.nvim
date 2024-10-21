local LANG = "kotlin"
local imports = require("luasnip4k.lib.imports")(LANG)
local hook = imports.hook
local insert_imports = imports.insert_imports

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local functions = require("luasnip4k.lib.functions")
local scopes = require("luasnip4k.lib.scopes")
local scope = scopes.scope
local any_scope = scopes.any_scope
local top_level = scopes.top_level
local class = scopes.class
local object_declaration = scopes.object_declaration
local statement = scopes.statement
local expression = scopes.expression

local function main_without_args()
  return fmt(
    [[
      fun main() {{
          {}
      }}
    ]],
    { i(0) }
  )
end

local function main_with_args()
  return fmt(
    [[
      fun main(args: Array<String>) {{
          {}
      }}
    ]],
    { i(0) }
  )
end

local function static_main_with_args()
  return fmt(
    [[
      @JvmStatic
      fun main(args: Array<String>) {{
          {}
      }}
    ]],
    { i(0) }
  )
end

local intellij_snippets = {
  s(
    { trig = "anon", name = "Anonymous object" },
    fmta(
      [[
        object : <supertype> {
            <body>
        }
      ]],
      { supertype = i(1, "Any()"), body = i(0) }
    ),
    any_scope { expression, statement }
  ),
  s(
    { trig = "closure", name = "Closure", desc = "Closure (function without name)" },
    fmta(
      "{ <param>: <param_type> ->> <copy><body> }",
      { param = i(1, "x"), param_type = i(2, "Any"), copy = rep(1), body = i(0) }
    ),
    any_scope { expression, statement }
  ),
  s(
    { trig = "exfun", name = "Extension function" },
    fmta(
      [[
        fun <receiver>.<name>(<params>): <return_type> {
            <body>
        }
      ]],
      { receiver = i(1, "Any"), name = i(2, "f"), params = i(3), return_type = i(4, "Unit"), body = i(0) }
    ),
    any_scope { class, top_level }
  ),
  s(
    { trig = "exval", name = "Extension property", desc = "Extension read-only property" },
    fmta(
      [[
        val <receiver>.<name>: <type>
            get() = <expr>
      ]],
      { receiver = i(1, "Any"), name = i(2, "v"), type = i(3, "Any"), expr = i(0) }
    ),
    any_scope { class, top_level }
  ),
  s(
    { trig = "exvar", name = "Extension property", desc = "Extension read-write property" },
    fmta(
      [[
        var <receiver>.<name>: <type>
            get() = <expr>
            set(value) {
                <assignment>
            }
      ]],
      { receiver = i(1, "Any"), name = i(2, "v"), type = i(3, "Any"), expr = i(4), assignment = i(0) }
    ),
    any_scope { class, top_level }
  ),
  s(
    { trig = "fun0", desc = "Function with no parameters" },
    fmta(
      [[
        fun <name>(): <return_type> {
            <body>
        }
      ]],
      { name = i(1), return_type = i(2, "Unit"), body = i(0) }
    ),
    any_scope { class, top_level, statement }
  ),
  s(
    { trig = "fun1", desc = "Function with one parameter" },
    fmta(
      [[
        fun <name>(<param>: <param_type>): <return_type> {
            <body>
        }
      ]],
      {
        name = i(1),
        param = i(2, "x"),
        param_type = i(3, "Any"),
        return_type = i(4, "Unit"),
        body = i(0),
      }
    ),
    any_scope { class, top_level, statement }
  ),
  s(
    { trig = "fun2", desc = "Function with two parameters" },
    fmta(
      [[
        fun <name>(<param1>: <param1_type>, <param2>: <param2_type>): <return_type> {
            <body>
        }
      ]],
      {
        name = i(1),
        param1 = i(2, "x"),
        param1_type = i(3, "Any"),
        param2 = i(4, "y"),
        param2_type = i(5, "Any"),
        return_type = i(6, "Unit"),
        body = i(0),
      }
    ),
    any_scope { class, top_level, statement }
  ),
  s(
    { trig = "interface", name = "Interface" },
    fmta(
      [[
        interface <name> {
            <body>
        }
      ]],
      { name = i(1), body = i(0) }
    ),
    any_scope { class, top_level, statement }
  ),
  s({ trig = "main", desc = "main() function" }, main_without_args(), scope(top_level)),
  s({ trig = "maina", desc = "main(args) function" }, main_with_args(), scope(top_level)),
  s({ trig = "maino", desc = "main(args) function" }, static_main_with_args(), scope(object_declaration)),
  s(
    { trig = "object", name = "Anonymous object" },
    fmta(
      [[
        object : <supertype> {
            <body>
        }
      ]],
      { supertype = i(1, "Any()"), body = i(0) }
    ),
    any_scope { expression, statement }
  ),
  s({ trig = "psvm", desc = "main() function" }, main_without_args(), scope(top_level)),
  s({ trig = "psvma", desc = "main(args) function" }, main_with_args(), scope(top_level)),
  s({ trig = "psvmo", desc = "main(args) function" }, static_main_with_args(), scope(object_declaration)),
  s(
    { trig = "serr", desc = "Prints a string to System.err" },
    fmt("System.err.println({})", { i(0) }),
    scope(statement)
  ),
  s(
    { trig = "singleton", name = "Singleton" },
    fmta(
      [[
        object <name> {
            <body>
        }
      ]],
      { name = i(1), body = i(0) }
    ),
    any_scope { class, top_level, statement }
  ),
  s(
    { trig = "sout", desc = "Prints a string to System.out" },
    fmt("println({})", { i(0) }),
    scope(statement)
  ),
  s(
    { trig = "soutf", desc = "Prints current class and function name to System.out" },
    fmt([[println("{}")]], { f(functions.get_qualified_function_name) }),
    scope(statement)
  ),
  s(
    { trig = "soutp", desc = "Prints function parameter names and values to System.out" },
    fmt([[println("{}")]], { f(functions.get_function_parameters) }),
    scope(statement)
  ),
  s(
    { trig = "test", name = "JUnit 5 test", desc = "Template for a JUnit 5 test" },
    fmta(
      [[
        @Test
        fun `<name>`() {
            <body>
        }
      ]],
      {
        name = i(1, "", hook(function() return insert_imports { "org.junit.jupiter.api.Test" } end)),
        body = i(0, ""),
      }
    ),
    any_scope { class, top_level, statement }
  ),
  s(
    { trig = "void", desc = "Function returning nothing" },
    fmta(
      [[
        fun <name>(<params>) {
            <body>
        }
      ]],
      { name = i(1), params = i(2), body = i(0) }
    ),
    any_scope { class, top_level, statement }
  ),
}

ls.add_snippets(LANG, intellij_snippets)
