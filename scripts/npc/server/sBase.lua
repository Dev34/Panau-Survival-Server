class 'Base'

function Base:__init(name)
    self.name = name
end

function Base:InitializeFromJsonData(data)
    if data.position then
        self.position = Serializer:DeserializeVector3(data.position)
    end

    if data.radius then
        self.radius = data.radius
    end
end

function Base:SetPosition(position)
    self.position = position
end

function Base:SetRadius(radius)
    self.radius = radius
end

function Base:GetPosition()
    return self.position
end

function Base:GetName()
    return self.name
end

function Base:GetJsonCompatibleData()
    local json_data = {}

    if self.position then
        json_data.position = Serializer:SerializeVector3(self.position, 2)
    end

    if self.radius then
        json_data.radius = self.radius
    end

    return json_data
end