return {
  -- mason
  'mason-org/mason.nvim',
  opts = {},
  config = function()
    require('mason').setup({
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    })

    local registry = require('mason-registry')
    local package_name = 'roslyn'

    if registry.is_installed(package_name) then
      return
    end

    registry.refresh(function(success)
      if not success then
        vim.notify('Mason could not refresh its registries; roslyn was not installed.', vim.log.levels.ERROR)
        return
      end

      if not registry.has_package(package_name) then
        vim.notify('Mason could not find the roslyn package in its configured registries.', vim.log.levels.ERROR)
        return
      end

      local package = registry.get_package(package_name)
      if package:is_installed() or package:is_installing() then
        return
      end

      package:install({}, function(installed, error)
        if not installed then
          vim.notify(('Mason failed to install roslyn: %s'):format(tostring(error)), vim.log.levels.ERROR)
        end
      end)
    end)
  end,
}
