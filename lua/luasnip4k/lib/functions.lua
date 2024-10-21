--- @module "luasnip4k.functions"
local functions = {}

local function find_identifier_for(node, type)
  for child in node:iter_children() do
    if child:type() == type then return child end
  end
  return nil
end

local function find_function_and_parent_names(start_node, valid_node_types)
  local node = start_node
  local parent_node = nil

  -- find the immediate top-level function declaration for the cursor location (node)
  while node ~= nil do
    if node:type() == "function_declaration" and valid_node_types[node:parent():type()] then
      parent_node = node:parent():parent()
      if parent_node and parent_node:type() == "companion_object" then
        parent_node = parent_node:parent():parent()
      end
      break
    end
    node = node:parent()
  end

  if node then
    local function_name = find_identifier_for(node, "simple_identifier")
    local parent_name = parent_node and find_identifier_for(parent_node, "type_identifier") or nil
    return function_name, parent_name
  else
    return nil, nil
  end
end

function functions.get_qualified_function_name()
  local function_name, parent_name = find_function_and_parent_names(vim.treesitter.get_node(), {
    source_file = true,
    class_body = true,
  })

  local bufnr, result = 0, nil
  result = parent_name and vim.treesitter.get_node_text(parent_name, bufnr) or "<top>"
  result = function_name and result .. "." .. vim.treesitter.get_node_text(function_name, bufnr)
  return result
end

function functions.get_function_parameters()
  local node = vim.treesitter.get_node()
  local parameters = {}

  while node ~= nil do
    if node:type() == "function_declaration" then
      local query = vim.treesitter.query.parse("kotlin", [[
        (function_value_parameters (parameter (simple_identifier) @param))
      ]])

      local bufnr = 0
      for _, capture, _ in query:iter_captures(node, bufnr) do
        local parameter = vim.treesitter.get_node_text(capture, bufnr)
        table.insert(parameters, string.format("%s = [${%s}]", parameter, parameter))
      end
      break
    end

    node = node:parent()
  end

  return table.concat(parameters, ", ")
end

return functions
