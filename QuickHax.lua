local utils = require('utils')
QuickHax = {}

local ready = false
local items = {}

local function newItem (label, fn)
  local item = {}
  item.label = label
  item.filter = item.label:upper()
  item.exec = fn
  table.insert(items, item)
  return item
end

local function CommandToLuaFn(cmd)
  return function (...)
    local args = {...}
    if args ~= nil then
      if args == nil then print("still nil :(") end
      for i,v in pairs(args) do
        -- local pType = cmd.params[params[i]]
        cmd.params[cmd.paramOrder[i]] = tostring(v)
      end
      -- local paramsString = 
      -- print("function params:  " .. paramsString)
      local params = utils.map(cmd.args, function(v) return string.gsub(v, "%$(%w+)%$", cmd.params) end)
      params[#params] = tonumber(params[#params])
      -- utils.print_r(params)
      -- print("yay!")
      return function()
        print("running")
        cmd.func(table.unpack(params))
        print("done")
      end
    else
      print("something is bad")
    end
  end
end

local function prepareItemList(commands)
	items = {}

  local defaultQuantity = 100
  local rarityTypes = {"Legendary", "Epic", "Rare", "Uncommon", "Common"}
  local devPointTypes = {"Primary", "Attribute"}

	for _, command in pairs(commands) do
		local cmdName = command.name
    local cmdFn = CommandToLuaFn(command)
    print("looping through commands")
    local fn = function() print("fake fn called") end
    if cmdName == 'Add Material' then
      defaultQuantity = 100
      for _, rarity in pairs(rarityTypes) do
        lastPart = ' Components'
        if rarity == rarityTypes[0] or rarity == rarityTypes[1] then
          fn = cmdFn(rarity, 2, defaultQuantity)
          lastPart = ' Upgrade' .. lastPart
          newItem('Add ' .. tostring(defaultQuantity) .. ' ' .. rarity .. lastPart, fn)
        else
          fn = cmdFn(rarity, 1, defaultQuantity)
          newItem('Add ' .. tostring(defaultQuantity) .. ' ' .. rarity .. lastPart, fn)
        end
      end
		elseif cmdName == 'Give Dev Points' then
      defaultQuantity = 12
      for _, pointType in pairs(devPointTypes) do
        fn = cmdFn(pointType, defaultQuantity)
        newItem('Give ' .. tostring(defaultQuantity) .. ' ' .. pointType .. ' points', fn)
      end
    else
      defaultQuantity = 1250
      fn = cmdFn(defaultQuantity)
      newItem('Add ' .. tostring(defaultQuantity) .. ' money', fn)
    end
	end

	table.sort(items, function(a, b)
		return a.label < b.label
	end)
end



function QuickHax.Init()
  print("initializing quickhax")
  local commands = {
    {
      name = 'Add Material', 
      func = function(m, q) print(m); Game.AddToInventory(m,q) end,
      params = {
        rarity = "string", -- could be enum
        isUpgrade = "boolean", -- true == upgrade component, false == regular
        quantity = "number"
      },
      paramOrder = {"rarity", "isUpgrade", "quantity"},
      args = {'Items.$rarity$Material$isUpgrade$', '$quantity$'},
      fmt = '"Items.$rarity$Material$isUpgrade$", $quantity$'
    },
    {
      name = 'Give Dev Points', 
      func = function(t,q) Game.GiveDevPoints(t,q) end, 
      params = {
        pointType = "string",
        quantity = "number"
      },
      paramOrder = {"pointType", "quantity"},
      args = {'$pointType$', '$quantity$'},
      fmt = '"$pointType$", $quantity$'
    },
    {
      name = 'Add Money', 
      func = function(q) Game.AddToInventory('Items.money', q) end,
      params = {
        quantity = "number"
      },
      paramOrder = {"quantity"},
      args = {'$quantity$'},
      fmt = "'Items.money', $quantity$"
    }
  }
  print("preparing item list")
  prepareItemList(commands)

  print("getting player info")
	local player = Game.GetPlayer()
	local isPreGame = Game.GetSystemRequestsHandler():IsPreGame()
	ready = player and player:IsAttached() and not isPreGame

	Observe('QuestTrackerGameController', 'OnInitialize', function()
		ready = true
	end)

	Observe('QuestTrackerGameController', 'OnUninitialize', function()
		ready = Game.GetPlayer() ~= nil
	end)
end

function QuickHax.IsReady()
	return ready
end

function QuickHax.GetItems(filter)
	if not filter or filter == '' then
		return items
	end

	local filterEsc = filter:gsub('([^%w])', '%%%1'):upper()
	local filterRe = filterEsc:gsub('%s+', '.* ') .. '.*'

	local filtered = {}

	for _, item in ipairs(items) do
		if item.filter:find(filterRe) then
			table.insert(filtered, item)
		end
	end

	return filtered
end

if (QuickHax == nil) then print("cannot return quickhax") end

return QuickHax