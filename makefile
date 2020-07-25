Factorio_Mod_Location = ~/Documents/factorio/mods
ModNameRaw = CharSelect

all: CharSelect
	rm -rf $(Factorio_Mod_Location)/$(ModNameRaw)
	cp -r $(ModNameRaw) $(Factorio_Mod_Location)/$(ModNameRaw)