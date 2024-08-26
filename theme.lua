local wezterm = require("wezterm")
local module = {}

local function custom_theme()
	local my_theme = wezterm.color.get_builtin_schemes()["Ayu Dark (Gogh)"]
	my_theme.background = "black"

	return my_theme
end

function module.apply(config)
	config.color_schemes = {
		["My Theme"] = custom_theme(),
	}
	config.color_scheme = "My Theme"

	config.window_decorations = "RESIZE"

	-- Set coloring for inactive panes to be less bright than your active pane
	config.inactive_pane_hsb = {
		hue = 0.5,
		saturation = 0.5,
		brightness = 0.6,
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
		active_titlebar_bg = "black",
	}

	config.colors = {
		tab_bar = {
			active_tab = {
				bg_color = "#223E55",
				fg_color = "white",
			},
			inactive_tab = {
				bg_color = "black",
				fg_color = "#808080",
			},
			new_tab = {
				bg_color = "black",
				fg_color = "#808080",
			},
			-- The color of the inactive tab bar edge/divider
			inactive_tab_edge = "black",
		},
	}
end

return module
