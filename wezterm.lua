local wezterm = require("wezterm")
local keymap = require("keymap")
local theme = require("theme")
local events = require("events")

local config = wezterm.config_builder()

-- Default program
config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

config.max_fps = 120 -- 60 default, will waste cpu/gpu if monitor is only 60hz

-- Font
-- wezterm bundles nerd fonts, it will be used as fallback
config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.5
-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Dead key accented characters, é, è, à, etc.
-- glove80 right alt is actually left alt
-- config.send_composed_key_when_left_alt_is_pressed = true

-- Theme
theme.apply(config)

-- Keymap
keymap.apply(config)

-- Events
events.apply(wezterm, config)

-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 5000

-- Debug
-- launch wezterm from another terminal
-- config.debug_key_events = true

return config
