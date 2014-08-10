--[[
Author: ZeroLimits (Mykezero)
Last Updated: 8/14/2014

---------------------------------------------------------------------------------------------------

Purpose of the program:

makes retrieving ffxi recipes easier by allow the user to specify certain characteristic of a
recipe and retrieve recipe's with those characteristics.

---------------------------------------------------------------------------------------------------

Updating the recipe data:

Step 1:
	Use this program to get the data into xml format:
	https://github.com/Mykezero/Synthesis-Recipe-Retriever/releases

Step 2:
	Unzip and run the program executable to download and parse FFXIAH's synthesis recipes.
	Recipe.xml will be generated in the same folder.

Step 2:
	Open the recipe.xml file and copy all of the data.

Step 3:
	Go to the following website:
	http://www.utilities-online.info/xmltojson/.

Step 4:
	Paste the xml data in the left pane of the window and the click the "-->" button in the
	middle to start the conversion.

Step 5:
	Copy the json data in the right pane and paste it into a text editor that supports find and
	replace.

Step 6:
	Do a find and replace to swap out all "-" characters to "" characters.

Step 7:
	Save the file as recipe.json.

---------------------------------------------------------------------------------------------------

User Manual:

To install the addon:
1. Open the directory in which ashita is located.
2. Open the addons folder.
3. Place the RecipeRetriever folder in the addon's directory.

To load the addon type:
/addon load reciperetriever

To retrieve synthesis recipes by name use:
	/recipe where name "NameOfSynth"

To retrieve synthesis recipes by a material used in the synth use:
	/recipe where material honey


---------------------------------------------------------------------------------------------------

TODO:
- 	Add support for case insensitive commands

---------------------------------------------------------------------------------------------------

Bugs:
-	Bug: Not all recipes will be found.
	Details: See Synthesis-Recipe-Retriever's issues for more information as to why not
	all the recipes were found.

-	Bug: Conversion from xml to json creates artifacts in the text.
	Details: San d'Or. Grape looks like San d&#039Or. Grape

	---------------------------------------------------------------------------------------------------
]]

-- This information will be displayed to the user when the addon is loaded.
_addon.author = 'ZeroLimits' 		-- Your name
_addon.name = 'Recipe Retriever'	-- Name of the addon.
_addon.version = '1.0'				-- Its version number

--allows access to tools in the common.lua file.
require 'common'

---------------------------------------------------------------------------------------------------
-- desc: Testing global table.
---------------------------------------------------------------------------------------------------
-- Allows global access to the recipe data retrieved.
local testing = { }

-------------------------------------------------------------------------------
-- func: load
-- desc: First called when our addon is loaded.
-------------------------------------------------------------------------------

-- Occurs when the user types "/addon load Testing"
ashita.register_event('load', function()
	-- Get the json recipe data from file and store it as a table named config
	local config = settings:load(_addon.path .. 'resources/recipes.json')

	-- Store the recipes for global access since we'll need them later.
	testing.config = config
end )


-------------------------------------------------------------------------------
-- func: command
-- desc: Handles commands that are type into the client
-------------------------------------------------------------------------------

-- Occurs when the user types "/recipes ..."
ashita.register_event('command',
	function(cmd, nType)
		-- Get the commands arguements
		local args = cmd:GetArgs()

		-- Check to see if the current command is our command.
		if(args[1] ~= "/recipes") then
			return false
		end

		-- /recipes where id = 5
		-- /recipes where level < 5 and level > 8
		if(args[2] == "where") then
			if(#args==4) then
				if(args[3] == "name") then
					getRecipeByName(args[4])
					return true
				elseif(args[3] == "material") then
					getRecipeByMaterial(args[4])
					return true
				end
			-- /recipes where Alchemy level 5
			elseif(#args==5) then
				print (#args)
				print (args[3])
				print (args[4])
				print (args[5])

				if(args[4] == "level") then
					getRecipeByLevel(args[3], args[5])
				end
			end
		end

		if(args[2] == "find" and #args==3) then
			printRecipe(args[3])
			return true
		end

		return true
	end)


--[[

-------------------------------------------------------------------------------
	Recipe Format
-------------------------------------------------------------------------------
	Antidote
		Quantity: 12
	Crafts:
		5 Alchemy
	Materials:
		1 Water Crystal
		3 Wijiruit
		3 San d' Or. Grape
		1 Distilled Water
		1 Triturator
-------------------------------------------------------------------------------

--]]

-------------------------------------------------------------------------------
-- func: printRecipe
-- desc: prints a recipe in a friendly format
-------------------------------------------------------------------------------

function printRecipe(recipe)
	-- Get the number of crafts required to perform the synth
	local crafts = table.getn(recipe.Skills.CraftSkill)

	-- Get the number of materials needed for the synth
	local materials = table.getn(recipe.Materials.Material)
	local qty = tonumber(recipe.Quantity)
	local name = recipe.Name

	if(qty ~= 1) then
		name = (name .. " x" .. recipe.Quantity)
	end

	print(string.rep("-", 30))
	-- Print recipe name
	print (name)
	print(string.rep("-", 30))

	-- Print crafts heading.
	print ("Crafts: ")

	-- Prints out craft requirement and the crafts level.
	-- Uses a for loop for synthesis recipes that need more than one craft to perform.
	if(crafts == 0) then
		print ("    " .. recipe.Skills.CraftSkill.Craft .. " (" .. recipe.Skills.CraftSkill.Level .. ")")
	else
		for i=1, crafts do
			print ("    " .. recipe.Skills.CraftSkill[i].Craft .. " (" .. recipe.Skills.CraftSkill[i].Level .. ")")
		end
	end

	print ("Materials: ")

	if(materials == 0) then
		print ("    " .. recipe.Materials.Material.Quantity .. " " .. recipe.Materials.Material.Ingredient)
	else
		for i=1, materials do
			print ("    " .. recipe.Materials.Material[i].Quantity .. " " .. recipe.Materials.Material[i].Ingredient)
		end
	end
end

-------------------------------------------------------------------------------
-- func: printRecipes
-- desc: prints a table of recipes in a friendly format
-------------------------------------------------------------------------------

function printRecipes(recipeTable)
	for i=1, table.getn(recipeTable) do
		printRecipe(recipeTable[i])
	end
end

function

function getRecipeByTableIndex(id)
		-- Convert index to a number from a string.
	local x = tonumber(id)

	-- Get the recipe by index.
	local recipe = testing.config.ArrayOfRecipe.Recipe[x]

	-- Check if the recipe exists if it does not ...
	if(recipe == nil) then
		-- Tell the user the recipe was not found.
		print("Recipe not found.")
		return
	end

	return recipe
end


-------------------------------------------------------------------------------
-- func: getRecipeByLevel
-- desc: prints a recipe in a friendly format
-------------------------------------------------------------------------------
function getRecipeByLevel(craft, level)
	local recipeTable = testing.config.ArrayOfRecipe.Recipe
	local foundTable = { }

	for i=1, table.getn(recipeTable) do
		local recipe = recipeTable[i]
		local crafts = recipe.Skills.CraftSkill
		local size = table.getn(crafts)

		print(size)

		if(size == 0) then
			if(crafts.craft == craft and crafts.level == level) then
				table.insert(foundTable, recipe)
			end
		end

		for i=1, size do
			if(crafts[i].craft == craft and crafts[i].level == level) then
				table.insert(foundTable, recipe)
			end
		end
	end


	return foundTable
end

function getRecipeByName(name)
	local recipeTable = testing.config.ArrayOfRecipe.Recipe
	local foundTable = { }

	for i=1, table.getn(recipeTable) do
		local recipe = recipeTable[i]
		if(recipe.Name == name) then
			table.insert(foundTable, recipe)
		end
	end

	printRecipes(foundTable)
end

function getRecipeByMaterial(ingredient)
	local recipeTable = testing.config.ArrayOfRecipe.Recipe
	local foundTable = { }

	for i=1, table.getn(recipeTable) do
		local recipe = recipeTable[i]
		local materials = recipe.Materials.Material;
		local size = table.getn(materials)

		if(size == 0 and materials == ingredient) then
			table.insert(foundTable, recipe)
		else
			for j=1, size do
				if(materials[j].Ingredient == ingredient) then
					table.insert(foundTable, recipe)
				end
			end
		end

		if(recipe.Name == name) then
			table.insert(foundTable, recipe)
		end
	end


	return foundTable
end
