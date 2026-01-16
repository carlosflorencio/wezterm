local wezterm = require("wezterm")
local module = {}

local bg_color = "black"

local function custom_theme()
	local my_theme = wezterm.color.get_builtin_schemes()["Vs Code Dark+ (Gogh)"]
	my_theme.background = bg_color

	return my_theme
end

function module.apply(config)
	config.color_schemes = {
		["My Theme"] = custom_theme(),
	}
	config.color_scheme = "My Theme"

	-- hide title bar
	config.window_decorations = "RESIZE"

	-- Don't dim inactive panes
	config.inactive_pane_hsb = {
		saturation = 1,
		brightness = 1,
	}

	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}

	-- Tabs
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = true

	config.window_frame = {
		active_titlebar_bg = bg_color,
	}

	config.colors = {
		tab_bar = {
			active_tab = {
				bg_color = "#D0D0D0",
				fg_color = "blue",
			},
			inactive_tab = {
				bg_color = bg_color,
				fg_color = "#808080",
			},
			new_tab = {
				bg_color = bg_color,
				fg_color = "#808080",
			},
			-- The color of the inactive tab bar edge/divider
			inactive_tab_edge = bg_color,
		},
	}
end

return module
