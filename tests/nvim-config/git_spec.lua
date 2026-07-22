local git = require('config.git')

local function run(command)
  local output = vim.fn.system(command)
  assert.are.equal(0, vim.v.shell_error, output)
end

describe('nvim-config git helpers', function()
  local repository

  before_each(function()
    repository = vim.fn.tempname()
    vim.fn.mkdir(repository, 'p')
    run({ 'git', '-C', repository, 'init', '--quiet' })

    vim.fn.writefile({ 'tracked' }, repository .. '/tracked.txt')
    run({ 'git', '-C', repository, 'add', 'tracked.txt' })
    run({
      'git',
      '-C',
      repository,
      '-c',
      'user.name=nvim-config tests',
      '-c',
      'user.email=nvim-config-tests@example.invalid',
      'commit',
      '--quiet',
      '-m',
      'Initial commit',
    })
  end)

  after_each(function()
    vim.fn.delete(repository, 'rf')
  end)

  it('lists Git-added and untracked files as absolute paths', function()
    vim.fn.writefile({ 'added' }, repository .. '/added.txt')
    run({ 'git', '-C', repository, 'add', 'added.txt' })
    vim.fn.writefile({ 'untracked' }, repository .. '/untracked.txt')

    local files, error_message = git.list_new_files({ 'HEAD' }, repository)

    assert.is_nil(error_message)
    table.sort(files)
    assert.are.same({
      repository .. '/added.txt',
      repository .. '/untracked.txt',
    }, files)
  end)

  it('limits untracked files to explicit pathspecs', function()
    vim.fn.writefile({ 'selected' }, repository .. '/selected.txt')
    vim.fn.writefile({ 'other' }, repository .. '/other.txt')

    local files, error_message = git.list_new_files({ 'HEAD', '--', 'selected.txt' }, repository)

    assert.is_nil(error_message)
    assert.are.same({ repository .. '/selected.txt' }, files)
  end)
end)
