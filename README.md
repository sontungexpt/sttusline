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

### Components

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


To use default component use should add name of component to components options
or you can add a table with the first value is the name of component and second
value is the table that you want to override default component

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
            "mode",
            -- or
            {
                "mode",
                -- override default component
                {
                    name = "form",
                    event = {}, -- The component will be update when the event is triggered
                    user_event = { "VeryLazy" },
                    timing = false, -- The component will be update every time interval
                    lazy = true,
                    space ={}
                    configs = {},
                    padding = 1, -- { left = 1, right = 1 }
                    colors = {}, -- { fg = colors.black, bg = colors.white }
                    init = function(configs,colors,space) end,
                    update = function(configs,colors,space)return "" end,
                    condition = function(configs,colors,space)return true end,
                    on_highlight= function(configs,colors,space) end,
                }
            },
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

#### Create new component

All key is same with set_key in `main branch`

**NEW**:
- onload --> init
- onhighlight -- > on_highlight
- space : space is table or function(configs,colors) and pass to on key with
type function
- if key must be a function it will get three parameters `configs, colors,space`
  - configs: same with Component.get_config()
  - colors: is the table colors in sttsuline.utils.color
  - space is the returning value of space key function or space

```lua
    require("sttusline").setup {
        components = {
            "%=", -- add the empty space

            -- ... your components
            {
                name = "form",
                event = {}, -- The component will be update when the event is triggered
                user_event = { "VeryLazy" },
                timing = false, -- The component will be update every time interval
                lazy = true,
                --space is table or function(configs,colors)
                space ={}
                configs = {},
                padding = 1, -- { left = 1, right = 1 }
                colors = {}, -- { fg = colors.black, bg = colors.white }
                init = function(configs,colors,space) end,
                update = function(configs,colors,space)return "" end,
                condition = function(configs,colors,space)return true end,
                on_highlight= function(configs,colors,space) end,
            }
        },
    }
```



## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
