local languages = {
  java = {
    treesitter_queries = {
      package = "(package_declaration (scoped_identifier) @package)",
      import  = "(import_declaration) @import",
    },
    import_options = function(import)
      local single_import = string.format("import %s;", import)
      local wildcard_import = string.format("import %s.*;", string.match(import, "^(.+)%.%w+$"))
      return single_import, wildcard_import
    end
  },
  kotlin = {
    treesitter_queries = {
      package = "(package_header (identifier) @package)",
      import  = "(import_header) @import",
    },
    import_options = function(import)
      local single_import = string.format("import %s", import)
      local wildcard_import = string.format("import %s.*", string.match(import, "^(.+)%.%w+$"))
      return single_import, wildcard_import
    end
  },
}

local function get_captures(bufnr, lang, query_string)
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = vim.treesitter.query.parse(lang, query_string)

  return query:iter_captures(root, bufnr, 0, -1)
end

local function get_package_details(lang)
  local bufnr = 0

  for _, node in get_captures(bufnr, lang, languages[lang].treesitter_queries.package) do
    local package_name = vim.treesitter.get_node_text(node, bufnr)
    local y = node:range()

    return package_name, y + 1
  end
end

local function find_current_imports(lang)
  local bufnr = 0
  local captures = get_captures(bufnr, lang, languages[lang].treesitter_queries.import)
  local result = {}

  for _, node in captures do
    local import_statement = vim.treesitter.get_node_text(node, bufnr)
    local start_row_index = node:range()

    table.insert(result, {
      statement = import_statement,
      line_number = start_row_index + 1,
    })
  end

  return result
end

local function insert_imports(lang, imports)
  if #imports == 0 then return end

  local current_imports = find_current_imports(lang)
  local last_import_line_number = #current_imports > 0 and current_imports[#current_imports].line_number
  local result = {}
  local line_number = 0
  local nothing_to_insert = true

  if last_import_line_number then
    line_number = last_import_line_number
  else
    local package_name, lineno = get_package_details(lang)

    if package_name and lineno then
      line_number = lineno
      table.insert(result, "")
    end
  end

  for _, import in ipairs(imports) do
    local single_import, wildcard_import = languages[lang].import_options(import)
    local found = false

    for _, current_import in ipairs(current_imports) do
      if current_import.statement == single_import or current_import.statement == wildcard_import then
        found = true
        break
      end
    end

    if found == false then
      table.insert(result, single_import)
      nothing_to_insert = false
    end
  end

  if nothing_to_insert == true then return end
  vim.api.nvim_buf_set_lines(0, line_number, line_number, false, result)
end

--- @module "luasnip4k.imports"
return function(lang)
  local events = require("luasnip.util.events")

  return {
    hook = function(callback)
      return { node_callbacks = { [events.enter] = callback } }
    end,

    insert_imports = function(imports) return insert_imports(lang, imports) end,
  }
end
