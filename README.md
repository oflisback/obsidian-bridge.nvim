### :lotus_position: Purpose

[Obsidian](https://obsidian.md/) is great, but it doesn't offer the first-class Neovim experience that some of us just can't seem to do without. In the scenario where we edit notes in Neovim and view them rendered in Obsidian we would also like Obsidian to automatically follow navigation we do on the Neovim side.

That's where obsidian-bridge.nvim comes in. It mirrors navigation events in Neovim in the Obsidian app. If you open a note in Neovim the Obsidian App will show the same note automatically. If you navigate to another one or navigates to another Neovim buffer, the Obsidian app will show the corresponding note.

This is accomplished by leveraging the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin for Obsidian.

### :movie_camera: Demo

![demo](assets/obsidian-bridge.gif?raw=true)

### :mechanic: Installation

1. Make sure you have [curl](https://curl.se/) installed on your system and available on your `PATH`.

2. Install and enable the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) community plugin in Obsidian. <span style="color: red;">Important:</span> The default configuration of obsidian-bridge.nvim will try to connect to the non-encrypted server variant so remember to enable that in the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) settings if you want to use it. _See SSL/HTTPS Setup below for more information._

3. Set the environment variable `OBSIDIAN_REST_API_KEY` to the API key found in the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) settings within Obsidian, for example:

```
export OBSIDIAN_REST_API_KEY=<your api key, without the brackets>
```

4. Install `obsidian-bridge.nvim`, here are examples for some popular package managers:

<details>
  <summary>Lazy</summary>

```lua
{
  "oflisback/obsidian-bridge.nvim",
  opts = {
    -- your config here
  },
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

</details>

<details>
  <summary>Packer</summary>

```lua
require('packer').startup(function()
    use {
      'oflisback/obsidian-bridge.nvim',
      requires = { "nvim-telescope/telescope.nvim" }
      config = function() require('obsidian-bridge').setup() end
      requires = {
        "nvim-lua/plenary.nvim",
      },
    }
end)
```

</details>

<details>
  <summary>vim-plug</summary>

```vim
Plug 'nvim-telescope/telescope.nvim'
Plug 'oflisback/obsidian-bridge.nvim'
  Plug 'nvim-lua/plenary.nvim'
```

</details>

### :gear: Configuration

If no config parameter is provided to the setup function this default configuration will be used:

```lua
{
  obsidian_server_address = "http://localhost:27123",
  scroll_sync = false, -- See "Sync of buffer scrolling" section below
  cert_path = nil, -- See "SSL configuration" section below
}
```

Pass a config table as parameter to the setup function to provide an alternative server address or SSL certificate, for example to use with lazy:

```lua
{
  "oflisback/obsidian-bridge.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
    obsidian_server_address = "https://localhost:27124",
    cert_path = "~/.ssl/my-bridge-cert.pem"
  },
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  lazy = true,
}
```

### :key: SSL/HTTPS Setup

To use an encrypted connection, you will need the CA certificate from the Local REST API plugin. You can find it under Local REST API settings > Advanced Settings > Certificate. Kindly select and copy and entire text field, taking care **not** to accidentally modify it!

Then, simply create a new file anywhere on your system, give it any name you please, and paste the certificate inside of it. Take note of the path to this file, because you will need to pass it to the obsidian-bridge configuration table.

Don't forget to use the HTTPS URL for the server address! For example:

```lua
{
    obsidian_server_address = "https://localhost:27124",
    cert_path = "~/.ssl/my-bridge-cert.pem",
}
```

### :keyboard: Commands

- `:ObsidianBridgeDailyNote` takes you to your daily note or generates it for you if it doesn't already exist. Make sure to have the Daily Notes core plugin enabled in Obsidian for this to work. Since it internally uses the Daily Note plugin to create the note for you, templates will work the same way as if it was triggered from within Obsidian.
- `:ObsidianBridgeOpenGraph` opens the graph view in Obsidian, as long as the Graph core plugin is enabled.
- `:ObsidianBridgeOpenVaultMenu` opens the Obsidian vault selection dialog. Obsidian does not expose a way to switch to another vault programmatically (yet?).
- `:ObsidianBridgeTelescopeCommand` lists all the executable commands in Telescope. Execute the selected one.
- `:ObsidianBridgeOn` activate plugin.
- `:ObsidianBridgeOff` deactivate plugin, this will prevent calls towards Obsidian.
- `:ObsidianBridgeToggle` toggle plugin active/inactive.

:bulb: Feel free to suggest additional useful commands via issue or PR.

### :scroll: Sync of buffer scrolling

Ideally scrolling within a note in neovim should also make the scroll position be centered in Obsidian. This is possible, but requires a patched version of [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) so we'll have to build it ourselves. For more info about the patch's status see this [discussion](https://github.com/coddingtonbear/obsidian-local-rest-api/discussions/75).

#### Two ways of doing this, either use BRAT build or build the forked version

##### A) Use BRAT to install my forked version of obsidian-local-rest-api

1. Install the Obsidian [BRAT](https://github.com/TfTHacker/obsidian42-brat) plugin.

2. In the settings for BRAT, select "Add beta plugin with frozen version".

3. Add `https://github.com/oflisback/obsidian-local-rest-api` with release version tag `v1.0.0`. The added plugin is called "Local REST API with scroll".

##### B) Build a forked version of obsidian-local-rest-api

Specifically what's required is a build based on [this fork](https://github.com/coddingtonbear/obsidian-local-rest-api/compare/main...oflisback:obsidian-local-rest-api:main) which hopefully can get integrated in the upstream project eventually.

Start off by cloning the [patched fork](https://github.com/oflisback/obsidian-local-rest-api) to a folder named obsidian-local-rest-api-with-scroll:

```
git clone https://github.com/oflisback/obsidian-local-rest-api obsidian-local-rest-api-with-scroll
```

Then do `npm install` followed by `npm run build` inside that folder.

Now that you've built your own version of the plugin, place the obsidian-local-rest-api-with-scroll in your vault's `.obsidian/plugins/` folder and enable the "Local REST API with Scroll" plugin in the Obsidian settings panel.

#### After either completing (A) or (B)

The final thing to do is to set `scroll_sync = true` in your obsidian-bridge.nvim configuration and update the `OBSIDIAN_REST_API_KEY` value to what was generated for the new version of the plugin.

Now scrolling a note in neovim should also result in scrolling in Obsidian. Note however that this only works if the note is in <b>editing mode</b> in Obsidian. Any suggestions on how to make it work also in view mode would be very appreciated, until then make sure that notes are opened in editing mode by default via the Obsidian setting Editor -> Default view for new tabs -> Editing view.

### :books: Other projects for Neovim + Obsidian

- [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) Lets us interact with Obsidian vaults directly via the filesystem. :brain:

### :people_holding_hands: Contributing

Contributions, bug reports and suggestions are very welcome.

If you have a suggestion that would make the project better, please fork the repo and create a pull request.
