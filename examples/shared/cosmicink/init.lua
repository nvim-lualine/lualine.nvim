-- init.lua inside lua/shared/cosmicink/

-- Require each of your modules
local colors = require("shared.cosmicink.colors")
local conditions = require("shared.cosmicink.conditions")
local config = require("shared.cosmicink.config")
local utils = require("shared.cosmicink.utils")

-- Expose the modules as part of the cosmicink module
-- Now, you can access all the files directly via cosmicink.<module_name>
local cosmicink = {
	colors = colors,
	conditions = conditions,
	config = config,
	utils = utils
}

-- Return the cosmicink module
return cosmicink
