function CopyInventory(From, To, NoClear)
	for x=1,math.min(#From, #To) do
		print(From[x].valid_for_read and From[x].name)
		print(To.insert(From[x]))
	end
	if From.supports_bar() and To.supports_bar() then
		To.set_bar(From.get_bar())
	end
	if From.is_filtered() and To.supports_filters() then
		for x=1,math.min(#From, #To) do
			To.set_filter(x, From.get_filter(x))
		end
	end
	if not NoClear then
		From.clear()
	end
end

function CopyLogistics(From, To)
	To.character_personal_logistic_requests_enabled = From.character_personal_logistic_requests_enabled
	To.character_logistic_slot_count = From.character_logistic_slot_count
	for x=1,To.character_logistic_slot_count do
		To.set_personal_logistic_slot(x, From.get_personal_logistic_slot(x))
	end
end

function CopyPlayer(LuaPlayer, NewCharacterName)
	if LuaPlayer.character and LuaPlayer.character.valid then
		if remote.interfaces["minime"] then
			remote.call("minime", "make_character_backup", LuaPlayer)
		end
		local Position = LuaPlayer.character.position
		local Surface = LuaPlayer.surface
		local Force = LuaPlayer.force

		local OldCharacter = LuaPlayer.character
		LuaPlayer.character = Surface.create_entity({name = NewCharacterName, position = Position, force = Force, fast_replace = true, raise_built = true})
		if OldCharacter.is_flashlight_enabled() then
			LuaPlayer.character.enable_flashlight()
		else
			LuaPlayer.character.disable_flashlight()
		end

		do
			local OldInventory = OldCharacter.get_inventory(defines.inventory.character_armor)
			local NewInventory = LuaPlayer.character.get_inventory(defines.inventory.character_armor)
			if OldInventory and OldInventory.valid and NewInventory and NewInventory.valid then
				CopyInventory(OldInventory, NewInventory, true)
			end
		end
		for _,inventory in pairs(defines.inventory) do repeat
			if inventory == defines.inventory.character_armor then break end
			local OldInventory = OldCharacter.get_inventory(inventory)
			local NewInventory = LuaPlayer.character.get_inventory(inventory)
			if OldInventory and OldInventory.valid and NewInventory and NewInventory.valid then
				CopyInventory(OldInventory, NewInventory)
			end
		until true end
		LuaPlayer.character.insert(OldCharacter.cursor_stack)
		CopyLogistics(OldCharacter, LuaPlayer)
		OldCharacter.destroy({raise_destroy = true})
		if remote.interfaces["minime"] then
			remote.call("minime", "player_changed_character", LuaPlayer)
		end
	end
end

function Settings_Change(event)
	if(event.setting == "Selected-Character") then
		local Player = game.players[event.player_index]
		CopyPlayer(Player, settings.get_player_settings(event.player_index)[event.setting].value)
	end
end

function PlayerJoin(event)
	local character = game.players[event.player_index].character
	if character and character.valid then
		if character.name ~= settings.get_player_settings(event.player_index)["Selected-Character"].value then
			CopyPlayer(game.players[event.player_index], settings.get_player_settings(event.player_index)["Selected-Character"].value)
		end
	end
end
script.on_event(defines.events.on_runtime_mod_setting_changed, Settings_Change)
script.on_event(defines.events.on_player_joined_game, PlayerJoin)
script.on_event(defines.events.on_player_respawned, PlayerJoin)