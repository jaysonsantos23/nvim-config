-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set
map("i", "jj", "<esc>", { desc = "Normal Mode" })
map("i", "JJ", "<esc>", { desc = "Normal Mode" })
map("i", "JJ", "<esc>", { desc = "Normal Mode" })
map("n", "<C-S-i>", "<Cmd> lua require('jdtls').organize_imports()<CR>", { desc = "Organize Imports" })
map("n", "J", "}f", { desc = "Organize Imports" })
map("n", "K", "{f", { desc = "Organize Imports" })
map("t", "jj", "<C-\\><C-n>", { noremap = true, silent = true })
