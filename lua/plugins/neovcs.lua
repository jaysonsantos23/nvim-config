return {
  "https://github.com/adelarsq/neovcs.vim",
  keys = {
    "<leader>v",
  },
  config = function()
    require("neovcs").setup()
  end,
}
