local w = require("wezterm")

local module = {}

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local function is_k9s(pane)
	local process_name = pane:get_foreground_process_name()
	local is_k9s_process = process_name:find("k9s") ~= nil
	return is_k9s_process
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

function module.split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META|SHIFT" or "CTRL",
		action = w.action_callback(function(win, pane)
			-- Skip the navigation override if we're in k9s and the key is 'k'
			if key == "k" and is_k9s(pane) then
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
				return
			end

			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META|SHIFT" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

return module
