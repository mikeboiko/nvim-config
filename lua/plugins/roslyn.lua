return {
  -- roslyn
  'seblyng/roslyn.nvim',
  config = function()
    require('roslyn').setup({})

    -- The Mason `roslyn` package exposes a `roslyn` wrapper that runs
    -- `dotnet Microsoft.CodeAnalysis.LanguageServer.dll`. Point the LSP command
    -- at it so roslyn.nvim does not fall back to bare
    -- `Microsoft.CodeAnalysis.LanguageServer`, which is not on PATH. When the
    -- wrapper is missing, leave roslyn.nvim to discover the server itself.
    local roslyn_bin = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin', 'roslyn')
    if vim.fn.executable(roslyn_bin) == 1 then
      vim.lsp.config('roslyn', { cmd = { roslyn_bin, '--stdio' } })
    end
  end,
}
