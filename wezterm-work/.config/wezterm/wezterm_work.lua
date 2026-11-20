local wezterm = require 'wezterm'
local work = {}
local config_dir = os.getenv('DEVVM_CONFIG_DIR') or wezterm.home_dir .. '/.config/wezterm'
local socket_dir = os.getenv('DEVVM_SOCKET_DIR') or wezterm.home_dir .. '/.local/share/wezterm-devservers'
local state_dir = os.getenv('DEVVM_STATE_DIR') or wezterm.home_dir .. '/.local/state/wezterm-devservers'
local helper = os.getenv('DEVVM_HELPER') or wezterm.home_dir .. '/.local/bin/devvm'
local guard = helper:gsub('[^/]*$', '') .. 'devvm-guard'
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
  local panes, duplicates = {}, false
  for _, window in ipairs(wezterm.mux.all_windows()) do
    for _, tab in ipairs(window:tabs()) do
      for _, pane in ipairs(tab:panes()) do
        if pane:get_domain_name() == host.domain then
          local id = pane:pane_id()
          duplicates = duplicates or panes[id] ~= nil
          panes[id] = pane
        end
      end
    end
  end
  return panes, duplicates
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

-- The size server tabs must fit before attaching: the destination's on-screen
-- size, or the largest open window while a fresh destination has no GUI yet.
local function attach_size(destination)
  local largest
  for _, gui in ipairs(wezterm.gui.gui_windows()) do
    local ok, size, id = pcall(function()
      return gui:active_tab():get_size(), gui:mux_window():window_id()
    end)
    if ok then
      if id == destination:window_id() then return size end
      if not largest or size.cols > largest.cols then largest = size end
    end
  end
  return largest
end

local function relocate_host(host, destination, force)
  local domain = assert(wezterm.mux.get_domain(host.domain), 'restart WezTerm to register ' .. host.label)
  local present = window_panes(destination)
  local existing, duplicates = domain_panes(host)
  local other_name = host.domain == host.domains[1] and host.domains[2] or host.domains[1]
  local other = wezterm.mux.get_domain(other_name)
  local ready = next(existing) ~= nil and not duplicates and (not other or other:state() == 'Detached')
  for id in pairs(existing) do ready = ready and present[id] ~= nil end
  local key = 'devservers_direct_' .. host.short
  if not force and ready and domain:state() == 'Attached' and wezterm.GLOBAL[key] == destination:window_id() then
    local _, pane = next(existing)
    return pane
  end

  for _, name in ipairs(host.domains) do
    local old = wezterm.mux.get_domain(name)
    if old and old:state() == 'Attached' then old:detach() end
  end
  local group = { '/bin/bash', helper, '--group', host.name, destination:get_workspace() }
  local size = attach_size(destination)
  if size then
    table.insert(group, tostring(size.cols))
    table.insert(group, tostring(size.rows))
  end
  local ok, _, stderr = wezterm.run_child_process(group)
  assert(ok, host.label .. ': ' .. stderr)
  host.domain = host.domain == host.domains[1] and host.domains[2] or host.domains[1]
  wezterm.GLOBAL['devservers_domain_' .. host.short] = host.domain
  domain = assert(wezterm.mux.get_domain(host.domain))
  -- Preparation yields to the GUI. Attaching into a window that closed meanwhile
  -- panics inside WezTerm ("primary window to be valid") and aborts the whole GUI.
  if not remembered_window(destination:window_id()) then
    error(host.label .. ': destination window closed while preparing; run devvm again')
  end
  -- Attach native tabs into the destination; moving client panes leaves their
  -- stored remote tab IDs stale, so later resizes target the wrong server tab.
  domain:attach(destination)
  wezterm.GLOBAL[key] = destination:window_id()
  for _, pane in pairs(window_panes(destination)) do
    if pane:get_domain_name() == host.domain then return pane end
  end
  error(host.label .. ': attached tabs did not reach the destination window')
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
        local pane = relocate_host(host, destination, true)
        wezterm.GLOBAL['devservers_detached_' .. host.short] = destination:window_id()
        if pane then focus(destination, pane) end
        return host.label .. ': detached'
      end
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
      local pane = relocate_host(host, main,
        wezterm.GLOBAL['devservers_detached_' .. host.short] ~= nil)
      wezterm.GLOBAL['devservers_detached_' .. host.short] = nil
      if pane then focus(main, pane) end
      return host.label .. ': in unified window'
    end)
    if ok then table.insert(messages, result) else table.insert(errors, tostring(result)) end
  end
  return { messages = messages, errors = errors }
end

local function receive_request(_, pane, name, path)
  if name ~= 'DEVVM_REQUEST' or pane:get_domain_name() ~= 'local' then return end
  local prefix = state_dir .. '/requests/'
  if path:sub(1, #prefix) ~= prefix or path:find('/%.%./') then return end
  local completed = io.open(path .. '.result', 'r')
  if completed then completed:close(); return end
  -- One request at a time, even after its caller is cancelled and releases its lock:
  -- relocations must not overlap. A waiting request's pane keeps resending until free.
  if wezterm.GLOBAL.devvm_inflight then return end
  wezterm.GLOBAL.devvm_inflight = path
  -- Relocating several hosts can outlast any fixed deadline, so devvm keeps the
  -- request lock for as long as this GUI lives instead of timing out mid-relocation.
  local accepted = io.open(path .. '.accepted.tmp', 'w')
  if accepted then
    accepted:write(tostring(wezterm.procinfo.pid())); accepted:close()
    os.rename(path .. '.accepted.tmp', path .. '.accepted')
  end
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
  wezterm.on('gui-attached', function()
    -- Outside the GUI so a flooded main thread cannot starve it; one per state dir.
    wezterm.background_child_process { guard, 'watchdog', state_dir, wezterm.home_dir .. '/.local/share/wezterm',
      tostring(wezterm.procinfo.pid()) }
    retire_legacy_menus()
  end)
  wezterm.on('window-config-reloaded', function()
    if wezterm.GLOBAL.native_tabs_migrated then return end
    wezterm.GLOBAL.native_tabs_migrated = true
    retire_legacy_menus()
  end)
end

return work
