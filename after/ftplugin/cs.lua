-- Use standard cindent for C# because treesitter indent is buggy
-- TODO: Remove this after csharp treesitter parser is fixed
vim.opt_local.indentexpr = ''
vim.opt_local.cindent = true
