class "Patroller"

function Patroller:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.Patroller)
end

function Patroller:GetSyncData()
    local sync_data = {}

    sync_data.path = self.path:GetJsonCompatibleData()
    
    return sync_data
end

function Patroller:InitializeFromSpawnPoint(spawn_point)
    self.spawn_point = spawn_point
    self.path = spawn_point:GetPath()
    self.actor.position = Copy(self.path:GetPositions()[1])
    if self.actor.position then
        self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    end
end

function Patroller:Remove()
    
end