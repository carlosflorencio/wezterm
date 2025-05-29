local wezterm = require("wezterm")
local act = wezterm.action
local nvim = require("nvim")

local module = {}

wezterm.on("trigger-vim-with-scrollback", function(window, pane)
	local function get_zone_around_cursor(pane)
		local cursor = pane:get_cursor_position()
		-- y - 2 to take in consideration the prompt format is multiline
		local zone = pane:get_semantic_zone_at(cursor.x, cursor.y - 2)
		if zone then
			return pane:get_text_from_semantic_zone(zone)
		end
		return nil
	end

	wezterm.log_info("trigger-vim-with-scrollback")
	local output = get_zone_around_cursor(pane)

	if output == nil then
		wezterm.log_info("No output found")

		-- Retrieve the text from the pane
		output = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
	end

	-- -- Create a temporary file to pass to vim
	local name = os.tmpname()
	local f = io.open(name, "w+")
	f:write(output)
	f:flush()
	f:close()

	-- Open a new window running vim and tell it to open the file
	window:perform_action(
		act.SpawnCommandInNewTab({
			args = { "/opt/homebrew/bin/nvim", name },
		}),
		pane
	)

	-- Wait "enough" time for vim to read the file before we remove it.
	-- The window creation and process spawn are asynchronous wrt. running
	-- this script and are not awaitable, so we just pick a number.
	--
	-- Note: We don't strictly need to remove this file, but it is nice
	-- to avoid cluttering up the temporary directory.
	wezterm.sleep_ms(1000)
	os.remove(name)
end)

function module.apply(config)
	config.leader = {
		key = ";",
		mods = "CMD",
	}

	config.keys = {

		-- move between split panes ctrl + h/j/k/l
		nvim.split_nav("move", "h"),
		nvim.split_nav("move", "j"),
		nvim.split_nav("move", "k"),
		nvim.split_nav("move", "l"),
		-- resize panes with meta + shift + h/j/k/l
		nvim.split_nav("resize", "h"),
		nvim.split_nav("resize", "j"),
		nvim.split_nav("resize", "k"),
		nvim.split_nav("resize", "l"),

		-- jump to previous commands/prompts
		{ key = "UpArrow", mods = "CMD", action = wezterm.action.ScrollToPrompt(-1) },
		{ key = "DownArrow", mods = "CMD", action = wezterm.action.ScrollToPrompt(1) },

		{
			key = "e",
			mods = "CMD",
			action = act.EmitEvent("trigger-vim-with-scrollback"),
		},
		{
			key = "d",
			mods = "CMD",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},

		{
			key = "d",
			mods = "CMD|SHIFT",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},

		{
			key = "w",
			mods = "CMD",
			action = act.CloseCurrentPane({ confirm = false }),
		},

		{
			-- disable default debug keybinding
			key = "L",
			mods = "CTRL",
			action = act.DisableDefaultAssignment,
		},

		{
			key = "LeftArrow",
			mods = "CMD|ALT",
			action = act.ActivateTabRelative(-1),
		},
		{
			key = "RightArrow",
			mods = "CMD|ALT",
			action = act.ActivateTabRelative(1),
		},

		-- move tabs
		{
			key = "LeftArrow",
			mods = "CMD|ALT|SHIFT",
			action = act.MoveTabRelative(-1),
		},
		{
			key = "RightArrow",
			mods = "CMD|ALT|SHIFT",
			action = act.MoveTabRelative(1),
		},

		{
			key = "/",
			mods = "CMD",
			action = act.QuickSelect,
		},

		{
			key = "y",
			mods = "CMD",
			action = act.ActivateCopyMode,
		},

		{
			key = ",",
			mods = "CMD",
			action = act.ShowDebugOverlay,
		},

		{
			key = "p",
			mods = "CMD",
			action = act.ActivateCommandPalette,
		},
		{
			key = "f",
			mods = "CMD",
			action = act.Search({ CaseInSensitiveString = "" }),
		},
		{
			key = "Enter",
			mods = "ALT",
			action = act.DisableDefaultAssignment,
		},
	}

	local search_mode = nil
	local copy_mode = nil
	if wezterm.gui then
		-- copy mode
		copy_mode = wezterm.gui.default_key_tables().copy_mode
		table.insert(
			copy_mode,
			{ key = "/", mods = "NONE", action = wezterm.action({ Search = { CaseInSensitiveString = "" } }) }
		)
		-- move commands up & down
		table.insert(copy_mode, {
			key = "UpArrow",
			mods = "CMD",
			action = act.CopyMode({ MoveBackwardZoneOfType = "Output" }),
		})
		table.insert(copy_mode, {
			key = "DownArrow",
			mods = "CMD",
			action = act.CopyMode({ MoveForwardZoneOfType = "Output" }),
		})
		table.insert(copy_mode, {
			key = "i",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "SemanticZone" }),
		})

		-- search mode
		search_mode = wezterm.gui.default_key_tables().search_mode
		table.insert(search_mode, { key = "c", mods = "CTRL", action = act.CopyMode("ClearPattern") })
		table.insert(search_mode, { key = "d", mods = "CTRL", action = act.CopyMode("NextMatchPage") })
		table.insert(search_mode, { key = "u", mods = "CTRL", action = act.CopyMode("PriorMatchPage") })
		table.insert(search_mode, {
			key = "Enter",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("ClearPattern"),
				act.CopyMode("AcceptPattern"),
				act.CopyMode({ SetSelectionMode = "Cell" }),
			}),
		})
		table.insert(search_mode, {
			key = "Escape",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("ClearPattern"),
				act.CopyMode("Close"),
			}),
		})
	end

	config.key_tables = {
		search_mode = search_mode,
		copy_mode = copy_mode,
	}
end

return module
