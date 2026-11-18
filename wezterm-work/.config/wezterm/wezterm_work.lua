local wezterm = require 'wezterm'
local work = {}
local config_dir = os.getenv('DEVVM_CONFIG_DIR') or wezterm.home_dir .. '/.config/wezterm'
local socket_dir = os.getenv('DEVVM_SOCKET_DIR') or wezterm.home_dir .. '/.local/share/wezterm-devservers'
local state_dir = os.getenv('DEVVM_STATE_DIR') or wezterm.home_dir .. '/.local/state/wezterm-devservers'
local helper = wezterm.home_dir .. '/.local/bin/devvm'
local workspace = 'devservers'
local hosts, by_name, by_domain, by_short = {}, {}, {}, {}

local validation_error
local seen, aliases = {}, {}
local reserved = { all = true, init = true, ls = true, list = true, add = true,
  rm = true, open = true, detach = true, merge = true, help = true, menu = true, ['local'] = true }
local file = io.open(config_dir .. '/devservers', 'r')
if file then
  for line in file:lines() do
    local fields = {}
    for field in line:gsub('#.*', ''):gmatch('%S+') do table.insert(fields, field) end
    local name, alias = fields[1], fields[2] or ''
    if name then
      local short = name:match('^[^.]+')
      if #fields > 2 or not name:match('^[A-Za-z0-9][A-Za-z0-9.%-]*$')
        or not short or seen[short] or (alias ~= '' and (aliases[alias] or reserved[alias]
          or not alias:match('^[A-Za-z0-9][A-Za-z0-9_%-]*$'))) then
        validation_error = 'Invalid devservers entry: ' .. line .. '. Fix the list with devvm ls.'
        break
      end
      seen[short] = true
      if alias ~= '' then aliases[alias] = true end
      local base = 'devserver:' .. short
      local host = { name = name, short = short, label = alias ~= '' and alias or short,
        color_index = #hosts + 1,
        domains = { base, base .. ':alternate' },
        domain = wezterm.GLOBAL['devservers_domain_' .. short] or base }
      table.insert(hosts, host)
      by_name[name] = host
      by_short[short] = host
      for _, domain in ipairs(host.domains) do by_domain[domain] = host end
    end
  end
  file:close()
end
if validation_error then hosts, by_name, by_domain, by_short = {}, {}, {}, {} end
wezterm.add_to_config_reload_watch_list(config_dir .. '/devservers')

function work.is_managed_domain(domain)
  return by_domain[domain] ~= nil
end

function work.tab_domain(tab)
  local domain = tab.active_pane and tab.active_pane.domain_name or 'local'
  if domain == 'local' then return 'Local', 'local' end
  local host = by_domain[domain] or by_name[domain] or by_short[domain]
  if host then return host.label, 'devserver:' .. host.short, host.color_index end
  return domain, domain
end

local function window_panes(window)
  local panes = {}
  for _, tab in ipairs(window:tabs()) do
    for _, pane in ipairs(tab:panes()) do
      panes[pane:pane_id()] = pane
    end
  end
  return panes
end

local function domain_panes(host)
  local panes = {}
  for _, window in ipairs(wezterm.mux.all_windows()) do
    for id, pane in pairs(window_panes(window)) do
      if pane:get_domain_name() == host.domain then
        panes[id] = pane
      end
    end
  end
  return panes
end

local function remembered_window(id)
  if not id then return nil end
  local ok, window = pcall(wezterm.mux.get_window, id)
  return ok and window or nil
end

local function main_window(control)
  local main = remembered_window(wezterm.GLOBAL.devservers_main)
  if not main or main:get_workspace() ~= workspace then
    local windows = wezterm.mux.all_windows()
    table.sort(windows, function(a, b) return a:window_id() < b:window_id() end)
    main = nil
    for _, window in ipairs(windows) do
      local members = window_panes(window)
      members[control:pane_id()] = nil
      local name = window:get_workspace()
      if (name == workspace or name == 'devservers:local') and next(members) then main = window; break end
    end
    if not main then
      local _, _, window = wezterm.mux.spawn_window {
        domain = { DomainName = 'local' }, workspace = workspace, cwd = wezterm.home_dir,
      }
      main = window
    end
    main:set_workspace(workspace)
    wezterm.GLOBAL.devservers_main = main:window_id()
  end
  local has_local = false
  for id, pane in pairs(window_panes(main)) do
    if id ~= control:pane_id() and pane:get_domain_name() == 'local' then
      has_local = true
    end
  end
  if not has_local then
    local tab = main:spawn_tab { domain = { DomainName = 'local' }, cwd = wezterm.home_dir }
    tab:set_title('local')
  end
  main:set_title('Devservers')
  return main
end

local function focus(window, pane)
  local origin = wezterm.gui.gui_windows()[1]
  for _, gui in ipairs(wezterm.gui.gui_windows()) do
    local ok, focused = pcall(function() return gui:is_focused() end)
    if ok and focused then origin = gui; break end
  end
  if origin then
    pcall(function()
      origin:perform_action(wezterm.action.SwitchToWorkspace { name = window:get_workspace() }, origin:active_pane())
    end)
  end
  local function select(attempt)
    local ok, selected = pcall(function()
      local gui = window:gui_window()
      if not gui then return false end
      -- Moving a pane can leave its original tab object mirrored elsewhere.
      for index, tab in ipairs(window:tabs()) do
        for _, member in ipairs(tab:panes()) do
          if member:pane_id() == pane:pane_id() then
            gui:perform_action(wezterm.action.ActivateTab(index - 1), member)
            gui:focus()
            return true
          end
        end
      end
      return false
    end)
    if (not ok or not selected) and attempt < 20 then
      wezterm.time.call_after(0.05, function() select(attempt + 1) end)
    end
  end
  select(0)
end

local function attach(host)
  local domain = wezterm.mux.get_domain(host.domain)
  if not domain then
    error(host.short .. ': domain is not registered; restart WezTerm after adding a host')
  end
  domain:attach()
end

local function move_to_window(pane, destination, socket)
  local ok, _, stderr = wezterm.run_child_process {
    '/usr/bin/env', 'WEZTERM_UNIX_SOCKET=' .. socket,
    wezterm.executable_dir .. '/wezterm', '-n', 'cli', '--no-auto-start',
    'move-pane-to-new-tab', '--pane-id', tostring(pane:pane_id()),
    '--window-id', tostring(destination:window_id()),
  }
  if not ok then error(stderr) end
end

local function move_host(host, destination, socket)
  local bootstrap
  local present = window_panes(destination)
  local existing = domain_panes(host)
  local has_domain = false
  for _, pane in pairs(present) do
    if pane:get_domain_name() == host.domain then has_domain = true end
  end
  -- A destination must already belong to this domain or the remote mux creates
  -- another window when it files the moved panes.
  if not has_domain then
    -- A mixed window's active pane may advertise a path from another machine.
    local _, pane = destination:spawn_tab { domain = { DomainName = host.domain }, cwd = '/' }
    if next(existing) then bootstrap = pane end
  end
  local moved = false
  for id in pairs(existing) do
    if not present[id] and (not bootstrap or id ~= bootstrap:pane_id()) then moved = true end
  end
  if moved then
    -- Move every member of a split into its own tab. Leaving an already mirrored
    -- member in place lets the next remote layout update remove that member.
    local ids = {}
    for id in pairs(existing) do table.insert(ids, id) end
    table.sort(ids)
    for _, id in ipairs(ids) do
      if not bootstrap or id ~= bootstrap:pane_id() then
        move_to_window(existing[id], destination, socket)
      end
    end
  end
  -- Only close the shell we created; existing panes are never terminated.
  if bootstrap and moved then bootstrap:send_text('exit\n') end
  for _, pane in pairs(window_panes(destination)) do
    if pane:get_domain_name() == host.domain and (not bootstrap or pane:pane_id() ~= bootstrap:pane_id()) then
      return pane
    end
  end
end

local function relocate_host(host, destination, socket, force)
  local present = window_panes(destination)
  local needs_move = false
  for id in pairs(domain_panes(host)) do
    if not present[id] then needs_move = true end
  end
  if needs_move or force then
    -- Clear the client's mirrored tabs before moving again. The remote mux keeps
    -- its processes; reattachment gives this GUI a consistent pane/tab graph.
    local domain = wezterm.mux.get_domain(host.domain)
    domain:detach()
    -- The old client's background cleanup can detach its domain after this call
    -- returns. A second registered domain prevents it from detaching the new
    -- connection while preserving the remote server's processes.
    host.domain = host.domain == host.domains[1] and host.domains[2] or host.domains[1]
    wezterm.GLOBAL['devservers_domain_' .. host.short] = host.domain
    wezterm.mux.get_domain(host.domain):attach()
  end
  return move_host(host, destination, socket)
end

local function hide_duplicates()
  local windows = wezterm.mux.all_windows()
  local members = {}
  for _, window in ipairs(windows) do members[window:window_id()] = window_panes(window) end
  for _, window in ipairs(windows) do
    local mine = members[window:window_id()]
    local all_remote = next(mine) ~= nil
    for _, pane in pairs(mine) do
      all_remote = all_remote and work.is_managed_domain(pane:get_domain_name())
    end
    if all_remote then
      for _, other in ipairs(windows) do
        if other:window_id() ~= window:window_id() and other:get_workspace() == workspace then
          local theirs = members[other:window_id()]
          local shared, additional = true, false
          for id in pairs(mine) do shared = shared and theirs[id] ~= nil end
          for id in pairs(theirs) do additional = additional or mine[id] == nil end
          if shared and (additional or other:window_id() < window:window_id()) then
            -- Some mux versions leave mirrored windows after a move. Hide the
            -- copies without closing their shared sessions.
            window:set_workspace('devservers-stale')
            break
          end
        end
      end
    end
  end
end

local function execute(request, control)
  local main = main_window(control)
  local messages, errors = {}, {}
  if request.action == 'local' then
    for _, pane in pairs(window_panes(main)) do
      if pane:get_domain_name() == 'local' and pane:pane_id() ~= control:pane_id() then
        focus(main, pane)
        return { messages = { 'Local tab' }, errors = {} }
      end
    end
  end
  for _, name in ipairs(request.hosts) do
    local ok, result = pcall(function()
      local host = assert(by_name[name], 'host is not configured: ' .. name)
      if request.action == 'detach' then
        local panes = domain_panes(host)
        assert(next(panes), host.short .. ': no attached panes; open the host first')
        local destination = remembered_window(wezterm.GLOBAL['devservers_detached_' .. host.short])
        if not destination or destination:window_id() == main:window_id() then
          local tab, _, window = wezterm.mux.spawn_window {
            domain = { DomainName = 'local' }, workspace = workspace, cwd = wezterm.home_dir,
          }
          tab:set_title('local')
          destination = window
          destination:set_title(host.label)
        end
        local pane = relocate_host(host, destination, request.socket, true)
        wezterm.GLOBAL['devservers_detached_' .. host.short] = destination:window_id()
        if pane then focus(destination, pane) end
        return host.label .. ': detached'
      end
      attach(host)
      if request.action == 'open' then
        local detached = remembered_window(wezterm.GLOBAL['devservers_detached_' .. host.short])
        if detached then
          for _, pane in pairs(window_panes(detached)) do
            if pane:get_domain_name() == host.domain then
              focus(detached, pane)
              return host.label .. ': focused'
            end
          end
        end
      end
      local pane = relocate_host(host, main, request.socket,
        wezterm.GLOBAL['devservers_detached_' .. host.short] ~= nil)
      wezterm.GLOBAL['devservers_detached_' .. host.short] = nil
      if pane then focus(main, pane) end
      return host.label .. ': in unified window'
    end)
    if ok then table.insert(messages, result) else table.insert(errors, tostring(result)) end
  end
  hide_duplicates()
  return { messages = messages, errors = errors }
end

local function receive_request(_, pane, name, path)
  if name ~= 'DEVVM_REQUEST' or pane:get_domain_name() ~= 'local' then return end
  local prefix = state_dir .. '/requests/'
  if path:sub(1, #prefix) ~= prefix or path:find('/%.%./') then return end
  local completed = io.open(path .. '.result', 'r')
  if completed then completed:close(); return end
  -- Retries must not replay a merge while its first remote operation is pending.
  if wezterm.GLOBAL.devvm_inflight == path then return end
  wezterm.GLOBAL.devvm_inflight = path
  local result
  local ok, err = pcall(function()
    local f = assert(io.open(path, 'r'))
    local text = f:read('*a'); f:close()
    local request = wezterm.json_parse(text)
    assert(request.action == 'open' or request.action == 'merge' or request.action == 'detach' or request.action == 'local', 'invalid devvm action')
    assert(type(request.hosts) == 'table' and type(request.socket) == 'string', 'invalid devvm request')
    result = execute(request, pane)
  end)
  if not ok then result = { messages = {}, errors = { tostring(err) } } end
  wezterm.GLOBAL.devvm_inflight = nil
  local f = io.open(path .. '.result.tmp', 'w')
  if f then
    f:write(wezterm.json_encode(result)); f:close()
    os.rename(path .. '.result.tmp', path .. '.result')
  end
end

local function open_from_key(window, pane, host)
  window:perform_action(wezterm.action.SpawnCommandInNewTab {
    domain = { DomainName = 'local' }, cwd = wezterm.home_dir, args = { '/bin/bash', helper, host.name },
  }, pane)
end

function work.apply_to_config(config)
  config.default_workspace = workspace
  -- An already scheduled prototype poller can outlive configuration reload.
  wezterm.GLOBAL.domain_poll_owner = nil
  if validation_error then wezterm.log_error(validation_error) end
  config.unix_domains = config.unix_domains or {}
  for _, host in ipairs(hosts) do
    for _, domain in ipairs(host.domains) do
      table.insert(config.unix_domains, { name = domain,
        socket_path = socket_dir .. '/' .. host.short .. '.sock', no_serve_automatically = true })
    end
  end
  local home = wezterm.home_dir
  local rules = {
    { regex = '\\b([tTdDpP]\\d+)\\b', format = 'https://fburl.com/b/$1' },
    { regex = '^>>> Lint for (.*):$', format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$1&editor=vscode-insiders' },
    { regex = home .. '/fbsource/(.*):(\\d+):\\d+', format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$1&lines[0]=$2&editor=vscode-insiders' },
    { regex = '--> (fbcode/.*):(\\d+):\\d+', format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$1&lines[0]=$2&editor=vscode-insiders' },
    { regex = '^(---|\\+\\+\\+) [ab]/(fbcode/.*)', format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$2&editor=vscode-insiders' },
  }
  for _, rule in ipairs(rules) do table.insert(config.hyperlink_rules, rule) end
  table.insert(config.keys, { key = 'o', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window, pane)
    local choices = {}
    for _, host in ipairs(hosts) do table.insert(choices, { id = host.name, label = host.label .. '  ' .. host.name }) end
    window:perform_action(wezterm.action.InputSelector { title = 'Devserver', fuzzy = true, choices = choices,
      action = wezterm.action_callback(function(win, p, name)
        if name then open_from_key(win, p, by_name[name]) end
      end),
    }, pane)
  end) })
  for i = 1, math.min(9, #hosts) do
    local host = hosts[i]
    table.insert(config.keys, { key = tostring(i), mods = 'CMD|OPT',
      action = wezterm.action_callback(function(window, pane) open_from_key(window, pane, host) end) })
  end
  table.insert(config.keys, { key = '0', mods = 'CMD|OPT', action = wezterm.action_callback(function(window, pane)
    window:perform_action(wezterm.action.SpawnCommandInNewTab {
      domain = { DomainName = 'local' }, cwd = wezterm.home_dir, args = { '/bin/bash', helper, 'local' },
    }, pane)
  end) })
  wezterm.on('user-var-changed', receive_request)

  local function retire_legacy_menus()
    for _, window in ipairs(wezterm.mux.all_windows()) do
      for _, tab in ipairs(window:tabs()) do
        for _, pane in ipairs(tab:panes()) do
          -- Titles survive attachment; the old OSC ownership marker does not.
          pcall(function()
            if pane:get_title() == 'dotfiles-domain-menu' then pane:send_text('\nDEVVM_MENU_EXIT\n') end
          end)
        end
      end
    end
  end
  wezterm.on('gui-attached', retire_legacy_menus)
  wezterm.on('window-config-reloaded', function()
    if wezterm.GLOBAL.native_tabs_migrated then return end
    wezterm.GLOBAL.native_tabs_migrated = true
    retire_legacy_menus()
  end)
end

return work
