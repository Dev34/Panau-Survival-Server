class "CityLooter"

function CityLooter:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.CityLooter)
    self.actor:SetModelId(ActorProfileEnum:GetModelId(ActorProfileEnum.CityLooter))
end

function CityLooter:InitializeBehaviors()
    -- Configure behaviors
    self.actor:UseBehavior(self, FollowPathBehavior2)
end

function CityLooter:GetSyncData()
    local sync_data = {}
    return sync_data
end

function CityLooter:InitializeFromSyncData(sync_data)
    self.actor.position = sync_data.position
    if sync_data.path then
        self.path = Path()
        self.path:InitializeFromJsonData(sync_data.path)
    end
    self:InitializeBehaviors()

    if sync_data.path then
        self.actor.behaviors.FollowPathBehavior2:FollowNewPath(self.path, sync_data.path_progress, sync_data.path_speed_multiplier)
    end
end

function CityLooter:Spawn()
    if self.path then
        local spawn_node = self.path.positions[self.actor.behaviors.FollowPathBehavior2.current_node_index]
        local next_path_node = self.path.positions[self.actor.behaviors.FollowPathBehavior2.current_node_index + 1]
        local spawn_angle = next_path_node and Angle(Angle.FromVectors(Vector3.Forward, next_path_node - spawn_node).yaw, 0, 0) or Angle()
        local spawn_position = self.actor.behaviors.FollowPathBehavior2:GetPosition()
        self.client_actor = ClientActor.Create(1, {
            model_id = self.actor:GetModelId(),
            position = spawn_position,
            angle = spawn_angle
        })
    else
        self.client_actor = ClientActor.Create(1, {
            model_id = self.actor:GetModelId(),
            position = self.actor:GetPosition(),
            angle = Angle()
        })
    end
    self.actor:Respawned()
end

function CityLooter:Respawn(pos, ang)
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
    Chat:Print("Respawned CityLooter", Color.Red)
end

function CityLooter:RenderDebug()
    if self.path then
        self.path:RenderDebug()
    end
end

function CityLooter:Remove()
    self.actor = nil
    if IsValid(self.client_actor) then -- TODO : build actor removal queue to avoid crashes
        self.client_actor:Remove()
    end
end