### Purpose

[Obsidian](https://obsidian.md/) is great, but it doesn't offer the first-class Neovim experience that some of us just can't seem to do without. [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) does a good job of letting us enjoy the best of both worlds by enabling users to navigate the obsidian vault inside Neovim. The main motivation for that plugin was to improve the neovim experience with Obsidian vaults, while still viewing the rendered notes in the Obsidian app.

This plugin takes that concept one step further by mirroring navigation events in Neovim in the Obsidian app. If you open a note in Neovim the Obsidian App will show the same note automatically. If you navigate to another one or navigates to another Neovim buffer, the Obsidian app will show the corresponding note.

This is accomplished by leveraging the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin for Obsidian.

### Demo

![demo](assets/obsidian-sync.gif?raw=true)

### Installation

1. Make sure you have [curl](https://curl.se/) installed on your system and available on your `PATH`.

2. Install and enable the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) community plugin in Obsidian. The default configuration of obsidian-sync.nvim will try to connect to the non-encrypted server variant so remember to enable that in the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) settings if you want to use it.

3. Set the environment variable `OBSIDIAN_REST_API_KEY` to the API key found in the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) settings within Obsidian, for example:

```
export OBSIDIAN_REST_API_KEY=<your api key, without the brackets>
```

4. Install `obsidian-sync.nvim`, here are examples for some popular package managers:

<details>
  <summary>Lazy</summary>

```lua
{
  "oflisback/obsidian-sync.nvim",
  config = function() require("obsidian-sync").setup() end,
  lazy = false
}
```

</details>

<details>
  <summary>Packer</summary>

```lua
require('packer').startup(function()
    use {
      'oflisback/obsidian-sync.nvim',
      config = function() require('obsidian-sync').setup() end
    }
end)
```
</details>

<details>
  <summary>vim-plug</summary>

```vim
Plug 'oflisback/obsidian-sync.nvim'
```

</details>

### Configuration

If no config parameter is provided to the setup function this default configuration will be used:

```lua
{
  obsidian_server_address = "http://localhost:27123"
}
```

Pass a config table as parameter to the setup function to provide an alternative server address, for example to use with lazy:

```lua
{
  "oflisback/obsidian-sync.nvim",
  config = function() require("obsidian-sync").setup({
    obsidian_server_address = "https://localhost:27124"
  }) end,
  lazy = false
}
```

### Contributing

Contributions, bug reports and suggestions are very welcome.

If you have a suggestion that would make the project better, please fork the repo and create a pull request.

### Future

- [ ] Detect if a file is located inside an Obsidian vault or not.
- [ ] Scroll to corresponding line on Neovim navigation events. If the user views line <i>n</i> in Neovim, scroll to line <i>n</i> also in Obsidian.
