-- Global foodblock namespace
foodblock = {}
foodblock.path = minetest.get_modpath("foodblock")
dofile(foodblock.path .. "/cooking.lua") -- [pudding], [applepie], [pancake], [hamburger]

-- [farming], [default]
dofile(foodblock.path .. "/foodblock.lua") -- [apple], [bread]
-- [crops], farming_plus, bushes, ethereal, plants_lib
dofile(foodblock.path .. "/farmplus.lua") -- strawberry, [tomato], orange, [carrot], [potato] 
-- [flowers]
dofile(foodblock.path .. "/plantlife.lua") -- [brown mushroom], [red mushroom]
-- [mobs_redo]
dofile(foodblock.path .. "/mobsfood.lua") -- [meatblock]
-- food
dofile(foodblock.path .. "/foodfood.lua") -- chocolate
-- moretrees, ethereal
dofile(foodblock.path .. "/moretree.lua") -- cocoblock, acorn, cone
-- bushes, farming_redo
dofile(foodblock.path .. "/berrys.lua") -- blackberry, raspberry, blueberry
-- ethereal
dofile(foodblock.path .. "/ethereal.lua") -- onion, banana
-- [crops], farming_redo, moretrees
dofile(foodblock.path .. "/farmredo.lua") -- [corn], coffee, muffin
-- farming, ethereal, fishing
dofile(foodblock.path .. "/rice.lua") -- onigiri, makisushi, nigirisushi
-- ethereal, take
dofile(foodblock.path .. "/bamboo.lua") -- bamboo, takenoko
