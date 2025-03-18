# Overview of `shared/` Directory

The `shared/` directory contains essential Lua modules used across the configuration. These modules provide color management, condition checking, utility functions, and integration with the `lua-color` package for color manipulation.

## Directory Structure

```
lua/shared/
├── cosmicink/
│   ├── colors.lua
│   ├── conditions.lua
│   ├── config.lua
│   ├── init.lua
│   ├── utils.lua
├── lua-color/
├── init.lua
├── PaletteGen.lua
```

### 1. `cosmicink/` Directory

This directory contains the core modules for configuring the `cosmicink` theme and related utilities.

#### `colors.lua`
- **Purpose**: Defines the color palette and color-related functions for the theme. It includes predefined color sets and functions to generate mode-specific colors and interpolate between them.
- **Functions**: 
  - `get_mode_color()`: Returns the color associated with the current mode.
  - `get_opposite_color(mode_color)`: Returns the opposite color of the current mode's color.
  - `get_animated_color(mode_color)`: Provides a random animated color from the color palette.
  - `interpolate_color(color1, color2, step)`: Interpolates between two colors for smooth transitions.

#### `conditions.lua`
- **Purpose**: Defines useful conditions that can be used in configuring Lualine or other status line components. It contains checks like whether the current buffer is empty or if the window width is greater than a certain value.
- **Functions**:
  - `buffer_not_empty()`: Checks if the current buffer has content.
  - `hide_in_width()`: Checks if the window width is above a threshold (useful for hiding certain components on smaller screens).
  - `check_git_workspace()`: Checks if the current directory is a Git repository.

#### `config.lua`
- **Purpose**: Holds the main configuration for the `cosmicink` theme, combining the settings for colors, icons, separators, and more. It serves as the entry point for the Lualine configuration.
  
#### `init.lua`
- **Purpose**: The initialization file that requires and exports all the modules inside the `cosmicink/` directory as a single API. It ensures that everything is imported correctly when the `cosmicink` module is required elsewhere.

#### `utils.lua`
- **Purpose**: Contains general utility functions that are helpful across different modules, such as shuffling tables and reversing them.

### 2. `lua-color` Directory
- **Purpose**: A [Lua package](https://github.com/Firanel/lua-color) used for working with colors. This package simplifies the management of color codes, especially for generating dynamic themes and handling color adjustments.

### 3. `PaletteGen.lua`
- **Purpose**: A utility module that works with the `lua-color` package to generate color palettes based on an external color source (such as a wallpaper). It ensures that colors are consistent and dynamically generated across various configurations.

### 4. `init.lua`
- **Purpose**: The main entry point of the shared modules. It initializes the setup by requiring the necessary files from the `cosmicink` and `lua-color` directories, making the modules available for use.

---

## Usage Example

To use the `cosmicink` module in your Lualine configuration, you would typically do the following in your Neovim setup:

```lua
local cosmicink = require("shared.cosmicink.config")

require('lualine').setup(cosmicink.cfg)
```

This will load the `cosmicink` configuration and apply it to the Lualine status line.

---

## Additional Notes

- **Customization**: You can modify the color palette or the condition checks in the `cosmicink/` directory to suit your theme preferences.
- **Palette Generation**: The `PaletteGen` module helps generate and customize color palettes dynamically based on external input.
- **Note**: The `PaletteGen` module is fairly simple at the moment. If you see any areas for improvement or optimization, feel free to help out and contribute!

### Importing the Modules

- **Location**: For this setup to work, the `shared/` directory should be placed inside the `lua/` directory of your Neovim configuration folder. This is necessary because Neovim's Lua module system expects to find the files under `~/.config/nvim/lua/`.

- **Alternative**: If you prefer to keep `shared/` elsewhere, you will need to adjust the import paths accordingly. For instance, you could modify the import statements to reflect the new path, like so:
  
  ```lua
  local cosmicink = require("path.to.shared.cosmicink")
  ```
---
