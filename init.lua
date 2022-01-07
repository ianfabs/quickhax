local QuickHax = require('QuickHax')
local UI = require('UI')

registerForEvent('onInit', function()
	if (QuickHax == nil) then print("QUICKHAX WAS NIL") end
	QuickHax.Init()

	UI.Init()

	UI.OnReadyCheck(QuickHax.IsReady)

	UI.OnListItems(function(filter)
		return QuickHax.GetItems(filter)
	end)

	UI.OnExecute(function(command)
		local player = Game.GetPlayer()
		-- local itemId = ItemID.FromTDBID(iconicMod.recorId)

		command.exec()
	end)
end)

registerForEvent('onOverlayOpen', function()
	UI.Show()
end)

registerForEvent('onOverlayClose', function()
	UI.Hide()
end)

registerForEvent('onDraw', function()
	UI.Draw()
end)