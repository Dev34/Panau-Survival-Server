class "PathSerialization"

function PathSerialization:__init()
    self.directory_name = "paths"
end

function PathSerialization:GetPathDataFromFile(name)
    local filename = self.directory_name .. "/" .. name .. ".json"

    local file = io.open(filename, "r")
    
	if file ~= nil then -- file might not exist
        local contents = file:read("*all")
        file:close()

        local path_json_table = json.decode(contents)
        return path_json_table
        --output_table(base_json_table)
	else
        print("Path " .. name .. " does not exist!")
        return nil
	end
end

function PathSerialization:SavePath(path)
    local filename = self.directory_name .. "/" .. path:GetName() .. ".json"
    local path_data = path:GetJsonCompatibleData()

    local encoded_data = json.encode(path_data)
    --print("encoded data:")
    --print(encoded_data)

    local file = io.open(filename, "w")
    if file then
        file:write(encoded_data)
        file:close()
        print("Saved " .. path:GetName())
    else
        print("Opening file failed when saving path")
    end
end

function PathSerialization:CommitAllBases()

end

PathSerialization = PathSerialization()