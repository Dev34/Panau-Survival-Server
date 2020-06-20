class "Patroller"

function Patroller:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.Patroller)
    self.actor:SetModelId(ActorProfileEnum:GetModelId(ActorProfileEnum.Patroller))
end

function Patroller:InitializeBehaviors()
    -- Configure behaviors
    self.actor:UseBehavior(self, FollowPathBehavior2)
end

function Patroller:GetSyncData()
    local sync_data = {}
    return sync_data
end

function Patroller:InitializeFromSyncData(sync_data)
    self.path = Path()
    self.path:InitializeFromJsonData(sync_data.path)

    self:InitializeBehaviors()
    self.actor.behaviors.FollowPathBehavior2:FollowNewPath(self.path, sync_data.path_progress, sync_data.path_speed_multiplier)
end

function Patroller:Spawn()
    local spawn_node = self.path.positions[self.actor.behaviors.FollowPathBehavior2.current_node_index]
    local next_path_node = self.path.positions[self.actor.behaviors.FollowPathBehavior2.current_node_index + 1]
    local spawn_angle = next_path_node and Angle(Angle.FromVectors(Vector3.Forward, next_path_node - spawn_node).yaw, 0, 0) or Angle()
    local spawn_position = self.actor.behaviors.FollowPathBehavior2:GetPosition()
    self.client_actor = ClientActor.Create(1, {
        model_id = self.actor:GetModelId(),
        position = spawn_position,
        angle = spawn_angle
    })
end

function Patroller:Respawn(pos, ang)
    if IsValid(self.client_actor) then
        self.client_actor:Remove()
    end
    print("self:")
    print(self)
    print(self.actor)
    self.client_actor = ClientActor.Create(1, {
        model_id = self.actor:GetModelId(),
        position = pos,
        angle = ang
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