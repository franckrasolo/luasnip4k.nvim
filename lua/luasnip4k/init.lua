local ok, _ = pcall(require, "luasnip")

if not ok then
  vim.print("luasnip4k requires LuaSnip!")
  return
end

local M = {}

function M.setup(_)
  require("luasnip4k.snippets")
end

return M
