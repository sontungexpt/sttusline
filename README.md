## Sttusline

A very lightweight statusline plugin for neovim written in lua.

This plugin lazy load all components and only update each component when needed.

Because this plugin aim to be fast and small as possible. I don't focus on
overriding default component. I focus on creating your custom component. So
maybe you need to know a little bit of lua to create your own component.

- ❓ [Features](#features)
- 👀 [Installation](#installation)
- 💻 [Configuration](#configuration)
- 😆 [Usage](#usage)
- 😁 [Contributing](#contributing)
- ✌️ [License](#license)

## A few words to say

🎉 As you can see, this plugin is very small and fast. But maybe it't not perfect
because I'm not a lua expert. So if you have any idea to improve this plugin,
please open an issue or pull request. I'm very happy to hear from you.

🍕 The default component is written for my personal use. So maybe you need to
create your own component. I'm very happy to see your component. So if you have
any idea to create a new component, please open an issue or pull request.

🛠️ At present, the highlight feature of this plugin is very simple. So I hope you can contribute to this plugin to make it better.

🔥 I am trying to create git-branch and copilot component. But I don't have much time to do it. So I'm very happy to hear from you.

## Preview

![preview1](./docs/readme/preview1.png)

## Features

🎉 Lightweight and super fast.

🛠️ Lazy load all components

🍕 Only update each component when needed, not update all statusline

🔥 Easy to create your component with lua

## Installation

```lua
    -- lazy
    {
        "sontungexpt/sttusline",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		event = { "BufEnter" },
		config = function(_, opts)
		    require("sttusline").setup {
                -- 0 | 1 | 2 | 3
                -- recommended: 3
                laststatus = 3,
                disabled = {
                    filetypes = {
                        -- "NvimTree",
                        -- "lazy",
                    },
                    buftypes = {
                        -- "terminal",
                    },
                },
                components = {
                    -- "mode",
                    -- "filename",
                    -- "git-diff",
                    -- "diagnostics",
                    -- "%=",
                    -- "lsps-formatters",
                    -- "indent",
                    -- "encoding",
                    -- "pos-cursor",
                    -- "pos-cursor-progress",
                },
            }
        end,
    },
```

## Usage

### Create your own component

| **Command**              | **Description**                           |
| ------------------------ | ----------------------------------------- |
| `:SttuslineNewComponent` | Create the template to make new component |

or copy the template to your component module

```lua
local NewComponent = require("sttusline.set_component").new()

-- The component will be update when the event is triggered
-- To disable default event, set NewComponent.set_event = {}
NewComponent.set_event {}

-- The component will be update when the user event is triggered
-- To disable default user_event, set NewComponent.set_user_event = {}
NewComponent.set_user_event { "VeryLazy" }

-- The component will be update every time interval
NewComponent.set_timing(false)

-- The component will be update when the require("sttusline").set_setup() is called
NewComponent.set_lazy(true)

-- The config of the component
-- After set_config, the config will be available in the component
-- You can access the config by NewComponent.get_config()
NewComponent.set_config {}

-- The number of spaces to add before and after the component
NewComponent.set_padding(1)
-- or NewComponent.set_padding{ left = 1, right = 1 }

-- The colors of the component
NewComponent.set_colors {} -- { fg = colors.set_black, bg = colors.set_white }

-- The function will return the value of the component to display on the statusline
-- Must return a string
NewComponent.set_update(function() return "" end)

-- The function will return the condition to display the component when the component is update
-- Must return a boolean
NewComponent.set_condition(function() return true end)

-- The function will call on the first time component load
-- Example: You can use this function to add highlight with vim.api.nvim_set_hl()
NewComponent.set_onload(function() end)

return NewComponent
```

After you create your component, you need to add it to `components` option in
`setup` function
such as:

```lua
    -- Create new component with name Datetime
    local Datetime = require("sttusline.component").new()

    Datetime.set_config {
        style = "default",
    }

    Datetime.set_timing(true)

    Datetime.set_update(function()
        local style = Datetime.get_config().style
        local fmt = style
        if style == "default" then
            fmt = "%A, %B %d | %H.%M"
        elseif style == "us" then
            fmt = "%m/%d/%Y"
        elseif style == "uk" then
            fmt = "%d/%m/%Y"
        elseif style == "iso" then
            fmt = "%Y-%m-%d"
        end
        return os.date(fmt) .. ""
    end)

    require("sttusline").setup {
        components = {
            -- ...
            -- Add your component
            Datetime,
        }
    }
```

### Use default component

To use default component, you need to add it to `components` option in `setup` function

Note: the default component must be a string

We provide you some default component:

| **Component**         | **Description**                       |
| --------------------- | ------------------------------------- |
| `mode`                | Show current mode                     |
| `filename`            | Show current filename                 |
| `git-diff`            | Show git diff                         |
| `diagnostics`         | Show diagnostics                      |
| `lsps-formatters`     | Show lsps, formatters                 |
| `indent`              | Show indent                           |
| `encoding`            | Show encoding                         |
| `pos-cursor`          | Show position of cursor               |
| `pos-cursor-progress` | Show position of cursor with progress |

```lua

    require("sttusline").setup {
        -- 0 | 1 | 2 | 3
        -- recommended: 3
        laststatus = 3,
        disabled = {
            filetypes = {
                -- "NvimTree",
                -- "lazy",
            },
            buftypes = {
                -- "terminal",
            },
        },
        components = {
            -- "mode",
            -- "filename",
            -- "git-diff",
            -- "diagnostics",
            -- "%=",
            -- "lsps-formatters",
            -- "indent",
            -- "encoding",
            -- "pos-cursor",
            -- "pos-cursor-progress",
        },
    }
```

### Add the empty space between components

To add the empty space between components, you need to add `%=` to `components` option in `setup` function

```lua
    require("sttusline").setup {
        components = {
            -- ... your components
            "%=", -- add the empty space
            -- ... your components
        },
    }
```

### Override default component

Although this plugin is not focus on overriding default component. But you can
do it by override the default component by some functions I provide to you. But
I recommend you to create your own component to reach the best performance.

| **Function**     | Type of args                  | **Description**                                                                                         |
| ---------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------- |
| `set_event`      | table or string               | The component will be update when the event is triggered. If you call set_event{} no event will trigger |
| `set_user_event` | tableor string                | Same as set_event buf for `User` autocmd                                                                |
| `set_timing`     | boolean                       | If set_timing(true), component will update after 1 second                                               |
| `set_lazy`       | boolean                       | Load component on startup(not recommended)                                                              |
| `set_config`     | table                         | Set config to update component                                                                          |
| `set_padding`    | number or table               | The number of spaces to add before and after the component                                              |
| `set_colors`     | table                         | Colors highlight                                                                                        |
| `set_update`     | function(must return string)  | The function will return the value of the component to display on the statusline                        |
| `set_condition`  | function(must return boolean) | The function will return the condition to display the component when the component is update            |
| `set_onload`     | function                      | The function will call on the first time component load                                                 |

So to override default component you can do

```lua
local mode = require("sttusline.components.mode")

mode.set_config{
    mode_colors = {
        ["STTUSLINE_NORMAL_MODE"] = { fg = "#000000", bg = "#ffffff" },
    },
}

-- after override default component, you need to add it to components option in setup function
require("sttusline").setup {
    components = {
        -- ... your components
        mode,
        -- ... your components
    },
}
```

Some config I provide to override default component

- mode

```lua
    local mode = require("sttusline.components.mode")

    mode.set_config {
    modes = {
        ["n"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
        ["no"] = { "NORMAL (no)", "STTUSLINE_NORMAL_MODE" },
        ["nov"] = { "NORMAL (nov)", "STTUSLINE_NORMAL_MODE" },
        ["noV"] = { "NORMAL (noV)", "STTUSLINE_NORMAL_MODE" },
        ["noCTRL-V"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
        ["niI"] = { "NORMAL i", "STTUSLINE_NORMAL_MODE" },
        ["niR"] = { "NORMAL r", "STTUSLINE_NORMAL_MODE" },
        ["niV"] = { "NORMAL v", "STTUSLINE_NORMAL_MODE" },

        ["nt"] = { "TERMINAL", "STTUSLINE_NTERMINAL_MODE" },
        ["ntT"] = { "TERMINAL (ntT)", "STTUSLINE_NTERMINAL_MODE" },

        ["v"] = { "VISUAL", "STTUSLINE_VISUAL_MODE" },
        ["vs"] = { "V-CHAR (Ctrl O)", "STTUSLINE_VISUAL_MODE" },
        ["V"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
        ["Vs"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
        [""] = { "V-BLOCK", "STTUSLINE_VISUAL_MODE" },

        ["i"] = { "INSERT", "STTUSLINE_INSERT_MODE" },
        ["ic"] = { "INSERT (completion)", "STTUSLINE_INSERT_MODE" },
        ["ix"] = { "INSERT completion", "STTUSLINE_INSERT_MODE" },

        ["t"] = { "TERMINAL", "STTUSLINE_TERMINAL_MODE" },
        ["!"] = { "SHELL", "STTUSLINE_TERMINAL_MODE" },

        ["R"] = { "REPLACE", "STTUSLINE_REPLACE_MODE" },
        ["Rc"] = { "REPLACE (Rc)", "STTUSLINE_REPLACE_MODE" },
        ["Rx"] = { "REPLACEa (Rx)", "STTUSLINE_REPLACE_MODE" },
        ["Rv"] = { "V-REPLACE", "STTUSLINE_REPLACE_MODE" },
        ["Rvc"] = { "V-REPLACE (Rvc)", "STTUSLINE_REPLACE_MODE" },
        ["Rvx"] = { "V-REPLACE (Rvx)", "STTUSLINE_REPLACE_MODE" },

        ["s"] = { "SELECT", "STTUSLINE_SELECT_MODE" },
        ["S"] = { "S-LINE", "STTUSLINE_SELECT_MODE" },
        [""] = { "S-BLOCK", "STTUSLINE_SELECT_MODE" },

        ["c"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
        ["cv"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
        ["ce"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },

        ["r"] = { "PROMPT", "STTUSLINE_CONFIRM_MODE" },
        ["rm"] = { "MORE", "STTUSLINE_CONFIRM_MODE" },
        ["r?"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
        ["x"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
    },
    mode_colors = {
        ["STTUSLINE_NORMAL_MODE"] = { fg = colors.blue, bg = colors.bg },
        ["STTUSLINE_INSERT_MODE"] = { fg = colors.green, bg = colors.bg },
        ["STTUSLINE_VISUAL_MODE"] = { fg = colors.purple, bg = colors.bg },
        ["STTUSLINE_NTERMINAL_MODE"] = { fg = colors.gray, bg = colors.bg },
        ["STTUSLINE_TERMINAL_MODE"] = { fg = colors.cyan, bg = colors.bg },
        ["STTUSLINE_REPLACE_MODE"] = { fg = colors.red, bg = colors.bg },
        ["STTUSLINE_SELECT_MODE"] = { fg = colors.magenta, bg = colors.bg },
        ["STTUSLINE_COMMAND_MODE"] = { fg = colors.yellow, bg = colors.bg },
        ["STTUSLINE_CONFIRM_MODE"] = { fg = colors.yellow, bg = colors.bg },
        },
    }
```

- diagnostics

```lua
    local diagnostics = require("sttusline.components.diagnostics")
    diagnostics.set_config {
        icons = {
            ERROR = "",
            INFO = "",
            HINT = "󰌵",
            WARN = "",
        },
        diagnostics_color = {
            ERROR = "DiagnosticError",
            WARN = "DiagnosticWarn",
            HINT = "DiagnosticHint",
            INFO = "DiagnosticInfo",
        },
        order = { "ERROR", "WARN", "INFO", "HINT" },
    }
```

- encoding

```lua
local encoding = require("sttusline.components.encoding")

encoding.set_config {
	["utf-8"] = "󰉿",
	["utf-16"] = "",
	["utf-32"] = "",
	["utf-8mb4"] = "",
	["utf-16le"] = "",
	["utf-16be"] = "",
}
```

- filename

```lua
    Filename.set_config {
        color = { fg = colors.orange, bg = colors.bg },
    }
```

- git-diff

```lua
    local git_diff = require("sttusline.components.git-diff")

    git_diff.set_config {
        icons = {
            added = "",
            changed = "",
            removed = "",
        },
        colors = {
            added = "DiagnosticInfo",
            changed = "DiagnosticWarn",
            removed = "DiagnosticError",
        },
        order = { "added", "changed", "removed" },
    }
```

- indent

```lua
local indent = require("sttusline.components.indent")

indent.set_colors { fg = colors.cyan, bg = colors.bg }
```

- lsps-formatters

```lua
local lsps_formatters = require("sttusline.components.lsps-formatters")

lsps_formatters.set_colors { fg = colors.magenta, bg = colors.bg }
```

- pos-cursor

```lua
local pos_cursor = require("sttusline.components.pos-cursor")
pos_cursor.set_colors { fg = colors.fg }
```

- pos-cursor-progress

```lua
local pos_cursor_progress = require("sttusline.components.pos-cursor-progress")
pos_cursor_rogress.set_colors { fg = colors.orange, bg = colors.bg }
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
