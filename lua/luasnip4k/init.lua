local ok, _ = pcall(require, "luasnip")

if not ok then
  vim.print("luasnip4k requires LuaSnip!")
  return
end

require("luasnip4k.http4k")
