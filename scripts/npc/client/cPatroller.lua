class "Patroller"

function Patroller:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.Patroller)
end

function Patroller:GetSyncData()
    local actor_sync_data = self.actor:GetSyncData()
    local profile_sync_data = self:GetSyncData()
end

function Patroller:GetSyncData()
    local sync_data = {}
    return sync_data
end

function Patroller:InitializeFromSyncData(sync_data)
    self.path = Path()
    self.path:InitializeFromJsonData(sync_data.path)
end

function Patroller:RenderDebug()
    self.path:RenderDebug()
end

function Patroller:Remove()
    self.actor = nil
end