function GenFiles(CharName)
    if not string.match(CharName, "^[a-zA-Z0-9_]+$") then
        print(CharName, "is an invalid name, must match regex: ^[a-zA-Z0-9_]+$")
        return
    end
    os.execute("mkdir Characters")
    os.execute("mkdir Characters/"..CharName)
    os.execute("mkdir Characters/"..CharName.."/Assets")
    local settings = io.open("Characters/"..CharName.."/settings.lua", "w")
    settings:write([[table.insert(data.raw["string-setting"]["Selected-Character"].allowed_values, "]]..CharName..[[")]])
    settings:close()
    local data = io.open("Characters/"..CharName.."/data.lua", "w")
    data:write([[local Character = util.table.deepcopy(data.raw["character"]["character"])
local Character_Corpse = util.table.deepcopy(data.raw["character-corpse"]["character-corpse"])

Character.name = "]]..CharName..[["
Character.character_corpse = "]]..CharName..[[-corpse"
Character_Corpse.name = "]]..CharName..[[-corpse"

--Replace Assets Here

data:extend({Character_Corpse, Character})]])
    data:close()

    local GlobalSettings = io.open("settings.lua", "a")
    GlobalSettings:write([[require("Characters.]]..CharName..[[.settings")]].."\n")
    GlobalSettings:close()
    local GlobalData = io.open("data.lua", "a")
    GlobalData:write([[require("Characters.]]..CharName..[[.data")]].."\n")
    GlobalData:close()
end

for _,Arg in ipairs(arg) do
    GenFiles(Arg)
end