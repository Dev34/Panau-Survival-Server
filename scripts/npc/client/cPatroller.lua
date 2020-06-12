class "Patroller"

function Patroller:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.Patroller)
    self.actor:SetModelId(ActorProfileEnum:GetModelId(ActorProfileEnum.Patroller))

    -- Configure behaviors
    self.actor:UseBehavior(self, FollowPathBehavior)
end

function Patroller:GetSyncData()
    local sync_data = {}
    return sync_data
end

function Patroller:InitializeFromSyncData(sync_data)
    self.path = Path()
    self.path:InitializeFromJsonData(sync_data.path)

    self.actor.behaviors.FollowPathBehavior:FollowNewPath(self.path)
end

function Patroller:Spawn()
    self.client_actor = ClientActor.Create(1, {
        model_id = self.actor:GetModelId(),
        position = self.path.positions[1],
        angle = Angle(Angle.FromVectors(Vector3.Forward, self.path.positions[2] - self.path.positions[1]).yaw, 0, 0)
    })
end

function Patroller:RenderDebug()
    self.path:RenderDebug()
end

function Patroller:Remove()
    self.actor = nil
    if IsValid(self.client_actor) then -- TODO : build actor removal queue to avoid crashes
        self.client_actor:Remove()
    end
end