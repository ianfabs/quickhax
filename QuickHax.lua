local utils = require('utils')
QuickHax = {}

local ready = false
local items = {}

local function newItem (label, fn, defaultQuantity, max, min, formatString--[[string]])
  local item = {}
  item.label = label
  item.filter = item.label:upper()
  item.exec = fn
  item.value = defaultQuantity
  item.defaultValue = defaultQuantity
  item.min = min or 0
  item.max = max or ((defaultQuantity * 10) % 100000)
  item.formatString = formatString or "%d"

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
      local params = utils.map(cmd.args, function(v) return string.gsub(v, "%$(%w+)%$", cmd.params) end)
      -- params[#params] = tonumber(params[#params])
      params[#params+1] = 0
      
      return function(n)
        params[#params] = n
        print("params:")
        utils.print_r(params)
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

  local rarityTypes = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}
  local devPointTypes = {"Primary", "Attribute"}

	for _, command in pairs(commands) do
		local cmdName = command.name
    local cmdFn = CommandToLuaFn(command)
    local cmdMin, cmdMax = command.quantityLimits.min, command.quantityLimits.max

    local fn = function() print("fake fn called") end
    
    if cmdName == 'Add Material' then
      for _, rarity in pairs(rarityTypes) do
        local lastPart = ' Components'
        fn = cmdFn(rarity, 1)
        newItem('Add ' .. rarity .. lastPart, fn, 100, cmdMax, cmdMin)
        if rarity == rarityTypes[#rarityTypes] or rarity == rarityTypes[#rarityTypes-1] or rarity == rarityTypes[#rarityTypes-2] then
          lastPart = ' Upgrade'..lastPart
          fn = cmdFn(rarity, 2)
          newItem('Add '.. rarity .. lastPart, fn, 100, cmdMax, cmdMin)
        end
        
      end
		elseif cmdName == 'Give Dev Points' then
      for _, pointType in pairs(devPointTypes) do
        fn = cmdFn(pointType)
        newItem('Give ' .. pointType .. ' points', fn, 12, cmdMax, cmdMin)
      end
    else
      fn = cmdFn()
      newItem('Add' .. ' money', fn, 1000, cmdMax, cmdMin, "$%d")
    end
	end

	-- table.sort(items, function(a, b)
	-- 	return a.label < b.label
	-- end)
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
      },
      paramOrder = {"rarity", "isUpgrade"},
      args = {'Items.$rarity$Material$isUpgrade$', '$quantity$'},
      quantityLimits = {min = 1, max = 1000},
    },
    {
      name = 'Give Dev Points', 
      func = function(t,q) Game.GiveDevPoints(t,q) end, 
      params = {
        pointType = "string",
      },
      paramOrder = {"pointType"},
      args = {'$pointType$'},
      quantityLimits = {min = 1, max = 30},
    },
    {
      name = 'Add Money', 
      func = function(q) Game.AddToInventory('Items.money', q) end,
      params = {},
      paramOrder = {},
      args = {},
      quantityLimits = {min = 1, max = 50000},
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