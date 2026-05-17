local module = {}

function module.apply(wezterm, config)
	local act = wezterm.action
	local agent_tab_colors = {
		auggie = { bg = "#14101F", fg = "white" }, -- indigo (subtle)
		claude = { bg = "#1A1208", fg = "white" }, -- orange (subtle)
		codex = { bg = "#0F1724", fg = "white" }, -- blue (subtle)
		opencode = { bg = "#1A1A1A", fg = "white" }, -- light grey (subtle)
	}

	local ssh_tab_colors = { bg = "#1A0F1F", fg = "white" } -- purple (subtle, inactive only)

	local function tab_title(tab)
		local title = tab.tab_title
		if title and #title > 0 then
			return title
		end
		return tab.active_pane.title
	end

	local function is_ssh_pane(pane)
		local proc = pane and pane.foreground_process_name or ""
		if proc == "" then
			return false
		end
		-- match basename == "ssh" (covers /usr/bin/ssh, /opt/homebrew/bin/ssh, etc.)
		return proc:match("/ssh$") ~= nil or proc == "ssh"
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
		local ssh = is_ssh_pane(tab.active_pane)

		if ssh then
			colors = ssh_tab_colors
		else
			for name, palette in pairs(agent_tab_colors) do
				if string.find(key, name, 1, true) then
					colors = palette
					break
				end
			end
		end

		local tab_colors = config.colors and config.colors.tab_bar or {}
		local fallback = tab.is_active and tab_colors.active_tab or tab_colors.inactive_tab or {}
		-- custom (ssh/agent) coloring only applies when inactive; active tabs use the theme highlight
		local use_custom = colors and not tab.is_active
		local bg = (use_custom and colors.bg) or fallback.bg_color or "black"
		local fg = (use_custom and colors.fg) or fallback.fg_color or "white"

		local display = ssh and ("[SSH] " .. title) or title

		return wezterm.format({
			{ Background = { Color = bg } },
			{ Foreground = { Color = fg } },
			{ Text = " " .. display .. " " },
		})
	end)
end

return module
