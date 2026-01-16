local module = {}

function module.apply(wezterm, config)
	local act = wezterm.action
	local agent_tab_colors = {
		auggie = { bg = "#14101F", fg = "white" }, -- indigo (subtle)
		claude = { bg = "#1A1208", fg = "white" }, -- orange (subtle)
		codex = { bg = "#0F1724", fg = "white" }, -- blue (subtle)
		opencode = { bg = "#1A1A1A", fg = "white" }, -- light grey (subtle)
	}

	local function tab_title(tab)
		local title = tab.tab_title
		if title and #title > 0 then
			return title
		end
		return tab.active_pane.title
	end

	wezterm.on("augment-command-palette", function(window, pane)
		return {
			{
				brief = "Rename tab",
				icon = "md_rename_box",
				action = act.PromptInputLine({
					description = "Enter new name for tab",
					action = wezterm.action_callback(function(window, pane, line)
						if line then
							window:active_tab():set_title(line)
						end
					end),
				}),
			},
		}
	end)

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local title = tab_title(tab)
		local key = string.lower(title or "")
		local colors = nil

		for name, palette in pairs(agent_tab_colors) do
			if string.find(key, name, 1, true) then
				colors = palette
				break
			end
		end

		local tab_colors = config.colors and config.colors.tab_bar or {}
		local fallback = tab.is_active and tab_colors.active_tab or tab_colors.inactive_tab or {}
		local bg = (not tab.is_active and colors and colors.bg) or fallback.bg_color or "black"
		local fg = (not tab.is_active and colors and colors.fg) or fallback.fg_color or "white"

		return wezterm.format({
			{ Background = { Color = bg } },
			{ Foreground = { Color = fg } },
			{ Text = " " .. title .. " " },
		})
	end)
end

return module
