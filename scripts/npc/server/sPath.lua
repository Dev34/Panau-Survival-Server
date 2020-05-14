class "Path"

function Path:__init()
    
end

function Path:SetName(name)
    self.name = name
end

function Path:GetName(name)
    return self.name
end

function Path:SetPositions(positions)
    self.positions = positions
end

function Path:InitializeFromJsonData(data)
    if data.positions then
        self.positions = {}

        for _, serialized_position in pairs(data.positions) do
            table.insert(self.positions, Serializer:DeserializeVector3(serialized_position))
        end
    end
end

function Path:GetJsonCompatibleData()
    local json_data = {}
    
    
    local serialized_positions = {}
    if self.positions then
        for index, position in ipairs(self.positions) do
            table.insert(serialized_positions, Serializer:SerializeVector3(position, 2))
        end
    end
    json_data['positions'] = serialized_positions


    return json_data
end

