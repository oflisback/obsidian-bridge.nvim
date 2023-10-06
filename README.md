### :lotus_position: Purpose

[Obsidian](https://obsidian.md/) is great, but it doesn't offer the first-class Neovim experience that some of us just can't seem to do without. In the scenario where we edit notes in Neovim and view them rendered in Obsidian we would also like Obsidian to automatically follow navigation we do on the Neovim side.

That's where obsidian-bridge.nvim comes in. It mirrors navigation events in Neovim in the Obsidian app. If you open a note in Neovim the Obsidian App will show the same note automatically. If you navigate to another one or navigates to another Neovim buffer, the Obsidian app will show the corresponding note.

This is accomplished by leveraging the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin for Obsidian.

### :movie_camera: Demo

![demo](assets/obsidian-bridge.gif?raw=true)

### :mechanic: Installation

1. Make sure you have [curl](https://curl.se/) installed on your system and available on your `PATH`.

2. Install and enable the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) community plugin in Obsidian. The default configuration of obsidian-bridge.nvim will try to connect to the non-encrypted server variant so remember to enable that in the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) settings if you want to use it.

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
  config = function() require("obsidian-bridge").setup() end,
  lazy = false
}
```

</details>

<details>
  <summary>Packer</summary>

```lua
require('packer').startup(function()
    use {
      'oflisback/obsidian-bridge.nvim',
      config = function() require('obsidian-bridge').setup() end
    }
end)
```
</details>

<details>
  <summary>vim-plug</summary>

```vim
Plug 'oflisback/obsidian-bridge.nvim'
```

</details>

### :gear: Configuration

If no config parameter is provided to the setup function this default configuration will be used:

```lua
{
  obsidian_server_address = "http://localhost:27123"
  scroll_sync = false -- See "Sync of buffer scrolling" section below
}
```

Pass a config table as parameter to the setup function to provide an alternative server address, for example to use with lazy:

```lua
{
  "oflisback/obsidian-bridge.nvim",
  config = function() require("obsidian-bridge").setup({
    obsidian_server_address = "https://localhost:27124"
  }) end,
  lazy = false
}
```

### :keyboard: Commands

 * `:ObsidianBridgeDailyNote` takes you to your daily note or generates it for you if it doesn't already exist. Make sure to have the Daily Notes core plugin enabled in Obsidian for this to work. Since it internally uses the Daily Note plugin to create the note for you, templates will work the same way as if it was triggered from within Obsidian.
 * `:ObsidianBridgeOpenGraph` opens the graph view in Obsidian, as long as the Graph core plugin is enabled.

:bulb: Feel free to suggest additional useful commands via issue or PR.

### :scroll: Sync of buffer scrolling

Ideally scrolling within a note in neovim should also make the scroll position be centered in Obsidian. This is possible, but requires a patched version of [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) so we'll have to build it ourselves. For more info about the patch's status see this [discussion](https://github.com/coddingtonbear/obsidian-local-rest-api/discussions/75).

Specifically what's required is a build based on [this fork](https://github.com/coddingtonbear/obsidian-local-rest-api/compare/main...oflisback:obsidian-local-rest-api:main) which hopefully can get integrated in the upstream project eventually.

Start off by cloning the [patched fork](https://github.com/oflisback/obsidian-local-rest-api) to a folder named obsidian-local-rest-api-with-scroll: 

```
git clone https://github.com/oflisback/obsidian-local-rest-api obsidian-local-rest-api-with-scroll
```

Then do `npm install` followed by `npm run build` inside that folder.

Now that you've built your own version of the plugin, place the obsidian-local-rest-api-with-scroll in your vault's `.obsidian/plugins/` folder and enable the "Local REST API with Scroll" plugin in the Obsidian settings panel.

The final thing to do is to set `scroll_sync = true` in your obsidian-bridge.nvim configuration and update the `OBSIDIAN_REST_API_KEY` value to what was generated for the new version of the plugin.

Now scrolling a note in neovim should also result in scrolling in Obsidian. Note however that this only works if the note is in <b>editing mode</b> in Obsidian. Any suggestions on how to make it work also in view mode would be very appreciated. :)

### :books: Other projects for Neovim + Obsidian

* [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) Lets us interact with Obsidian vaults directly via the filesystem. :brain:

### :people_holding_hands: Contributing

Contributions, bug reports and suggestions are very welcome.

If you have a suggestion that would make the project better, please fork the repo and create a pull request.
