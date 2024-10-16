local module = {}

function module.apply(wezterm, config)
	local act = wezterm.action

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
end

return module
