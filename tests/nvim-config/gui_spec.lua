describe('nvim-config gui helpers', function()
  local gui

  before_each(function()
    package.loaded['config.gui'] = nil
    gui = require('config.gui')
  end)

  it('maximizes the window with wmctrl on unix', function()
    local original_run_command = gui.run_command
    local original_run_system = gui.run_system
    local commands = {}
    local systems = {}

    gui.run_command = function(command)
      table.insert(commands, command)
    end

    gui.run_system = function(command)
      table.insert(systems, command)
    end

    assert.are.equal('wmctrl', gui.on_gui_enter({ is_unix = true, windowid = 123 }))
    assert.are.same({ 'set vb t_vb=' }, commands)
    assert.are.same({ 'wmctrl -i -b add,maximized_vert,maximized_horz -r 123' }, systems)

    gui.run_command = original_run_command
    gui.run_system = original_run_system
  end)

  it('maximizes the window with simalt on non-unix systems', function()
    local original_run_command = gui.run_command
    local original_run_system = gui.run_system
    local commands = {}
    local systems = {}

    gui.run_command = function(command)
      table.insert(commands, command)
    end

    gui.run_system = function(command)
      table.insert(systems, command)
    end

    assert.are.equal('simalt', gui.on_gui_enter({ is_unix = false }))
    assert.are.same({ 'set vb t_vb=', 'simalt ~x' }, commands)
    assert.are.same({}, systems)

    gui.run_command = original_run_command
    gui.run_system = original_run_system
  end)
end)
