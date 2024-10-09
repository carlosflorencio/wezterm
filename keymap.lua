local wezterm = require("wezterm")
local act = wezterm.action
local nvim = require("nvim")

local module = {}

function module.apply(config)
	config.leader = {
		key = ";",
		mods = "CMD",
	}

	config.keys = {

		-- move between split panes
		nvim.split_nav("move", "h"),
		nvim.split_nav("move", "j"),
		nvim.split_nav("move", "k"),
		nvim.split_nav("move", "l"),
		-- resize panes
		nvim.split_nav("resize", "h"),
		nvim.split_nav("resize", "j"),
		nvim.split_nav("resize", "k"),
		nvim.split_nav("resize", "l"),

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
	}
end

return module
