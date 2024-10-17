local ts_utils = require("nvim-treesitter.ts_utils")

--- @module "luasnip4k.scopes"
local scopes = {}

--- Determines if a node is located at the top-level of a Kotlin file.
--- @param node TSNode
--- @return boolean
function scopes.top_level(node)
  return node:type() == "source_file"
end

--- Determines if a node is located within the body of a class.
--- @param node TSNode
--- @return boolean
function scopes.class(node)
  return node:type() == "class_body"
end

--- Determines if a node is located within an object declaration.
--- @param node TSNode
--- @return boolean
function scopes.object_declaration(node)
  local node_types = {
    object_declaration = true,
    companion_object = true,
  }
  local parent_node = node:parent()
  return parent_node and node_types[parent_node:type()] or false
end

--- Determines if a node represents a Kotlin statement.
--- @param node TSNode
--- @return boolean
function scopes.statement(node)
  local node_types = {
    control_structure_body = true,
    function_body = true,
    lambda_literal = true,
    statements = true,
  }
  return node_types[node:type()] or false
end

--- Determines if a node represents a Kotlin expression.
--- @param node TSNode
--- @return boolean
function scopes.expression(node)
  local unary_expression_types = {
    postfix_expression = true,
    call_expression = true,
    indexing_expression = true,
    navigation_expression = true,
    prefix_expression = true,
    as_expression = true,
    spread_expression = true,
  }

  local binary_expression_types = {
    additive_expression = true,
    check_expression = true,
    comparison_expression = true,
    conjunction_expression = true,
    disjunction_expression = true,
    elvis_expression = true,
    equality_expression = true,
    infix_expression = true,
    multiplicative_expression = true,
    range_expression = true,
  }

  local primary_expression_types = {
    _function_literal = true,
    _literal_constant = true,
    callable_reference = true,
    collection_literal = true,
    if_expression = true,
    jump_expression = true,
    object_literal = true,
    parenthesized = true,
    simple_identifer = true,
    string_literal = true,
    super_expression = true,
    this_expression = true,
    try_expression = true,
  }

  return unary_expression_types[node:type()]
      or binary_expression_types[node:type()]
      or primary_expression_types[node:type()]
      or false
end

--- Builds LuaSnip options to show a snippet if the current location of the cursor
--- matches the given predicate.
--- @param predicate function a function that determines whether to show a snippet
--- @return table<string, function>: a table with the `show_condition` key bound to the given predicate function
function scopes.scope(predicate)
  return scopes.any_scope { predicate }
end

--- Builds LuaSnip options to show a snippet if the current location of the cursor
--- matches _any_ of the given predicates.
--- @param predicates function[]|nil a list of functions
--- @return table<string, function>: a table with the `show_condition` key bound to a composite predicate function
function scopes.any_scope(predicates)
  predicates = predicates or {}

  if #predicates == 0 then return { show_condition = function() return true end } end

  return {
    show_condition = function()
      local cursor_node = ts_utils.get_node_at_cursor()
      for _, predicate in ipairs(predicates) do
        if predicate(cursor_node) then return true end
      end
      return false
    end
  }
end

return scopes
