class "ActorManager"

function ActorManager:__init()
    getter_setter(self, "actors")
    self.actors = {}

    if IsTest then
        Events:Subscribe("Render", self, self.RenderDebug)
    end
    Network:Subscribe("npc/SyncActors", self, self.SyncActors)
end

function ActorManager:SyncActors(actors_data)
    for actor_id, actor_data in pairs(actors_data.new_actors) do
        local actor_profile_class = ActorProfileEnum:GetClass(actor_data.actor_sync_data.actor_profile_enum)
        local actor_profile_instance = actor_profile_class()
        local actor = actor_profile_instance:GetActor()

        actor:InitializeFromSyncData(actor_data.actor_sync_data)
        actor_profile_instance:InitializeFromSyncData(actor_data.profile_sync_data)

        self.actors[actor_id] = actor_profile_instance
    end

    for actor_id, actor_data in pairs(actors_data.stale_actors) do
        local actor_profile_instance = self.actors[actor_id]
        assert(actor_profile_instance ~= nil)
        actor_profile_instance:Remove()

        self.actors[actor_id] = nil
    end

    output_table(self.actors)
end

function ActorManager:RenderDebug()
    local base_actor
    local actor_pos
    for actor_id, actor_profile_instance in pairs(self.actors) do
        base_actor = actor_profile_instance.actor
        actor_pos = base_actor:GetPosition()
        local transform = Transform3()
        transform:Translate(actor_pos)
        transform:Rotate(Angle(0, math.pi / 2, 0))
        Render:SetTransform(transform)
        Render:FillCircle(Vector3.Zero, 1.75, Color.Chocolate)
        Render:ResetTransform()

        actor_profile_instance:RenderDebug()
    end
end

ActorManager = ActorManager()