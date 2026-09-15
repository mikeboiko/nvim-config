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
    local package_candidates = { 'roslyn-nightly', 'roslyn' }

    local function is_exiting()
      return vim.v.exiting ~= vim.NIL and vim.v.exiting ~= 0
    end

    local function schedule(callback)
      if is_exiting() then
        return
      end

      vim.schedule(function()
        if not is_exiting() then
          callback()
        end
      end)
    end

    local function notify(message)
      schedule(function()
        vim.notify(message, vim.log.levels.ERROR)
      end)
    end

    schedule(function()
      -- Do not start a network install from a headless smoke test or during shutdown.
      if #vim.api.nvim_list_uis() == 0 then
        return
      end

      for _, package_name in ipairs(package_candidates) do
        if registry.is_installed(package_name) then
          return
        end
      end

      registry.refresh(function(success)
        if not success then
          notify('Mason could not refresh its registries; Roslyn was not installed.')
          return
        end

        -- Mason invokes async callbacks from fast events. Keep package access and
        -- notifications on the main event loop.
        schedule(function()
          local package_name
          for _, candidate in ipairs(package_candidates) do
            if registry.has_package(candidate) then
              package_name = candidate
              break
            end
          end

          if not package_name then
            notify('Mason could not find a Roslyn package in its configured registries.')
            return
          end

          local package = registry.get_package(package_name)
          if package:is_installed() or package:is_installing() then
            return
          end

          package:install({}, function(installed, error)
            if not installed then
              notify(('Mason failed to install %s: %s'):format(package_name, tostring(error)))
            end
          end)
        end)
      end)
    end)
  end,
}
