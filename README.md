## Sttusline

### :star2:**IMPORTANT:** As I am currently utilizing the [table_version](https://github.com/sontungexpt/sttusline/tree/table_version) branch, kindly switch to it in order to receive the latest updates regularly.

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

🛠️ At present, I feel that use table to create new component is easy to control
than creating by calling get and set function. So I recommend you to use branch
[table_version](https://github.com/sontungexpt/sttusline/tree/table_version) instead of this branch

## Preview

![preview1](./docs/readme/preview1.png)


Copilot loading

[https://github.com/sontungexpt/sttusline/assets/92097639/a6cfc4d1-9d1f-445f-a90a-90f211bb1724](https://github.com/sontungexpt/sttusline/assets/92097639/4582f45d-58e4-469b-a7ad-85f482d3ba57)






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
                -- statusline_color = "#000000",
                statusline_color = "StatusLine",

                -- | 1 | 2 | 3
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
                    "mode",
                    "filename",
                    "git-branch",
                    "git-diff",
                    "%=",
                    "diagnostics",
                    "lsps-formatters",
                    "copilot",
                    "indent",
                    "encoding",
                    "pos-cursor",
                    "pos-cursor-progress",
                },
            }
        end,
    },
```

## Usage

**NOTE**: If you want create new component by adding a table to components
please use branch [table_version](https://github.com/sontungexpt/sttusline/tree/table_version) instead of this branch

### Create your own component

| **Command**              | **Description**                           |
| ------------------------ | ----------------------------------------- |
| `:SttuslineNewComponent` | Create the template to make new component |

or copy the template to your component module

```lua
-- Change NewComponent to your component name
local NewComponent = require("sttusline.set_component").new()

-- The component will be update when the event is triggered
-- To disable default event, set NewComponent.set_event = {}
NewComponent.set_event {}

-- The component will be update when the user event is triggered
-- To disable default user_event, set NewComponent.set_user_event = {}
NewComponent.set_user_event { "VeryLazy" }

-- The component will be update every time interval
NewComponent.set_timing(false)

-- The component will be update when the require("sttusline").setup() is called
NewComponent.set_lazy(true)

-- The config of the component
-- After set_config, the config will be available in the component
-- You can access the config by NewComponent.get_config()
NewComponent.set_config {}

-- The number of spaces to add before and after the component
NewComponent.set_padding(1)
-- or NewComponent.set_padding{ left = 1, right = 1 }

-- The colors of the component. Rely on the return value of the update function, you have 3 ways to set the colors
-- If the return value is string
-- NewComponent.set_colors { fg = colors.set_black, bg = colors.set_white }
-- If the return value is table of string
-- NewComponent.set_colors { { fg = "#009900", bg = "#ffffff" }, { fg = "#000000", bg = "#ffffff" }}
-- -- so if the return value is { "string1", "string2" }
-- -- then the string1 will be highlight with { fg = "#009900", bg = "#ffffff" }
-- -- and the string2 will be highlight with { fg = "#000000", bg = "#ffffff" }
--
-- -- if you don't want to add highlight for the string1 now
-- -- because it will auto update new colors when the returning value in update function is a table that contains the color options,
-- -- you can add a empty table in the first element
-- -- {
--     colors = {
--         {},
--         { fg = "#000000", bg = "#ffffff" }
--     },
-- -- }
--
-- NOTE: The colors options can be the colors name or the colors options
-- -- colors = {
-- --  { fg = "#009900", bg = "#ffffff" },
-- --  "DiagnosticsSignError",
-- -- },
-- -- So if the return value is { "string1", "string2" }
-- -- then the string1 will be highlight with { fg = "#009900", bg = "#ffffff" }
-- -- and the string2 will be highlight with the colors options of the DiagnosticsSignError highlight
-- -- Or you can set the fg(bg) follow the colors options of the DiagnosticsSignError highlight
-- -- {
-- --  colors = {
-- --      { fg = "DiagnosticsSignError", bg = "#ffffff" },
-- --      "DiagnosticsSignError",
-- --  },
-- -- }

NewComponent.set_colors {} -- { fg = colors.set_black, bg = colors.set_white }

-- The function will return the value of the component to display on the statusline(required).
-- Must return a string or a table of string or a table of  { "string", { fg = "color", bg = "color" } }
-- NewComponent.set_update(function() return { "string1", "string2" } end)
-- NewComponent.set_update(function() return { { "string1", {fg = "#000000", bg ="#fdfdfd"} },  "string3", "string4" } end)
NewComponent.set_update(function() return "" end)


-- The function will call when the component is highlight
NewComponent.set_onhighlight(function() end)

-- The function will return the condition to display the component when the component is update
-- Must return a boolean
NewComponent.set_condition(function() return true end)

-- The function will call on the first time component load
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

| **Component**         | **Description**                                        |
| --------------------- | ------------------------------------------------------ |
| `datetime`            | Show datetime                                          |
| `mode`                | Show current mode                                      |
| `filename`            | Show current filename                                  |
| `git-branch`          | Show git branch                                        |
| `git-diff`            | Show git diff                                          |
| `diagnostics`         | Show diagnostics                                       |
| `lsps-formatters`     | Show lsps, formatters(support for null-ls and conform) |
| `copilot`             | Show copilot status                                    |
| `indent`              | Show indent                                            |
| `encoding`            | Show encoding                                          |
| `pos-cursor`          | Show position of cursor                                |
| `pos-cursor-progress` | Show position of cursor with progress                  |

```lua
    require("sttusline").setup {
        -- ...
        components = {
            -- "mode",
            -- "filename",
            -- "git-branch",
            -- "git-diff",
            -- "%=",
            -- "diagnostics",
            -- "lsps-formatters",
            -- "copilot",
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

| **Function**      | Type of args                  | **Description**                                                                                         |
| ----------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------- |
| `set_event`       | table or string               | The component will be update when the event is triggered. If you call set_event{} no event will trigger |
| `set_user_event`  | tableor string                | Same as set_event buf for `User` autocmd                                                                |
| `set_timing`      | boolean                       | If set_timing(true), component will update after 1 second                                               |
| `set_lazy`        | boolean                       | Load component on startup(not recommended)                                                              |
| `set_config`      | table                         | Set config to update component                                                                          |
| `set_padding`     | number or table               | The number of spaces to add before and after the component                                              |
| `set_colors`      | table                         | Colors highlight                                                                                        |
| `set_update`      | function(must return string)  | The function will return the value of the component to display on the statusline                        |
| `set_condition`   | function(must return boolean) | The function will return the condition to display the component when the component is update            |
| `set_onhighlight` | function                      | The function will call when the component is set highlight                                              |
| `set_onload`      | function                      | The function will call on the first time component load                                                 |

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

- datetime

```lua
    local datetime = require("sttusline.components.datetime")

    datetime.set_config {
      style = "default",
    }
```

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
        ["STTUSLINE_NORMAL_MODE"] = { fg = colors.blue },
        ["STTUSLINE_INSERT_MODE"] = { fg = colors.green },
        ["STTUSLINE_VISUAL_MODE"] = { fg = colors.purple },
        ["STTUSLINE_NTERMINAL_MODE"] = { fg = colors.gray },
        ["STTUSLINE_TERMINAL_MODE"] = { fg = colors.cyan },
        ["STTUSLINE_REPLACE_MODE"] = { fg = colors.red },
        ["STTUSLINE_SELECT_MODE"] = { fg = colors.magenta },
        ["STTUSLINE_COMMAND_MODE"] = { fg = colors.yellow },
        ["STTUSLINE_CONFIRM_MODE"] = { fg = colors.yellow },
        },
    },
    auto_hide_on_vim_resized = true,
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
    local filename = require("sttusline.components.filename")
    filename.set_config {
        color = { fg = colors.orange },
    }
```

- git-branch

```lua
    local git_branch = require("sttusline.components.git-branch")

    git_branch.set_config {
        icons =  ""
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
        order = { "added", "changed", "removed" },
    }
```

- indent

```lua
local indent = require("sttusline.components.indent")

indent.set_colors { fg = colors.cyan }
```

- lsps-formatters

```lua
local lsps_formatters = require("sttusline.components.lsps-formatters")

lsps_formatters.set_colors { fg = colors.magenta }
```

- copilot

```lua
local copilot = require("sttusline.components.copilot")

copilot.set_colors { fg = colors.yellow }
copilot.set_config {
    icons = {
        normal = "",
        error = "",
        warning = "",
        inprogress = "",
    },
}
```

- pos-cursor

```lua
local pos_cursor = require("sttusline.components.pos-cursor")
pos_cursor.set_colors { fg = colors.fg }
```

- pos-cursor-progress

```lua
local pos_cursor_progress = require("sttusline.components.pos-cursor-progress")
pos_cursor_rogress.set_colors { fg = colors.orange }
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
