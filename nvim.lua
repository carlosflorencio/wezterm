local w = require("wezterm")

local module = {}

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == "true"
end

local function is_process(pane, name)
  local process_name = pane:get_foreground_process_name()
  return process_name:find(name) ~= nil
end

-- TODO: check if there are more than 1 pane in the tab, if no, fish accept suggestion
local function panes_count(window)
  -- Get the current tab
  local tab = window.active_tab()

  -- Get the panes in the tab
  local panes = tab:panes()

  -- Count the number of panes
  local paneCount = 0
  for _, pane in ipairs(panes) do
    paneCount = paneCount + 1
  end

  return paneCount
end

local direction_keys = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

local process_exceptions = {
  k9s = {
    { key = "k", mods = "CTRL" },
  },
  lazygit = {
    { key = "j", mods = "CTRL" },
    { key = "k", mods = "CTRL" },
  },
}

local pane_title_exceptions = {
  auggie = {
    { key = "j", mods = "CTRL" },
  },
}

local function should_pass_through_to_process(pane, direction, mods)
  for process_name, exceptions in pairs(process_exceptions) do
    if is_process(pane, process_name) then
      for _, exception in ipairs(exceptions) do
        if exception.key == direction and exception.mods == mods then
          return true
        end
      end
    end
  end
  return false
end

local function should_pass_through_to_title(pane, direction, mods)
  local title = pane:get_title()
  for title_pattern, exceptions in pairs(pane_title_exceptions) do
    if title:find(title_pattern) then
      for _, exception in ipairs(exceptions) do
        if exception.key == direction and exception.mods == mods then
          return true
        end
      end
    end
  end
  return false
end

function module.smart_split_nav(opts)
  local mods = opts.action == "resize" and "META|SHIFT" or "CTRL"

  return {
    key = opts.direction,
    mods = mods,
    action = w.action_callback(function(win, pane)
      if should_pass_through_to_process(pane, opts.direction, mods) or should_pass_through_to_title(pane, opts.direction, mods) then
        win:perform_action({ SendKey = { key = opts.direction, mods = mods } }, pane)
        return
      end

      if is_vim(pane) then
        win:perform_action({ SendKey = { key = opts.direction, mods = mods } }, pane)
      else
        if opts.action == "resize" then
          win:perform_action({ AdjustPaneSize = { direction_keys[opts.direction], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[opts.direction] }, pane)
        end
      end
    end),
  }
end

return module
