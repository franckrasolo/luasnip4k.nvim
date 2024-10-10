return {
  check = function()
    vim.health.start("luasnip4k")

    local ok, _ = pcall(require, "luasnip")
    if ok then
      vim.health.ok("LuaSnip is installed")
    else
      vim.health.error("luasnip4k requires LuaSnip!")
    end
  end,
}
