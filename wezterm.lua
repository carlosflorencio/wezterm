local wezterm = require("wezterm")
local keymap = require("keymap")
local theme = require("theme")
local config = {}

-- Default program
config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

-- Font
-- wezterm bundles nerd fonts, it will be used as fallback
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0

-- Theme
theme.apply(config)

-- Keymap
keymap.apply(config)

-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 5000

-- Debug
-- launch wezterm from another terminal
-- config.debug_key_events = true

return config
