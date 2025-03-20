-- CosmicInk config for lualine
-- Author: Yeeloman
-- MIT license, see LICENSE for more details.

-- Main configuration for setting up lualine.nvim statusline plugin
return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	-- Configuration function that runs when the plugin is loaded
	config = function()
		-- Import cosmicink configuration
		-- 'cosmicink' is a custom module containing the actual settings for lualine
		local cosmicink = require("shared.cosmicink")
		local config = cosmicink.config

		-- Set up lualine with the cosmicink configuration
		-- The cosmicink.cfg holds the actual configuration values for lualine
		require('lualine').setup(config.cfg)
	end,
}
