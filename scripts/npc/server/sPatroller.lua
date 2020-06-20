class "Patroller"

function Patroller:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.Patroller)
    self.path_speed_multiplier = 1.03

    -- Configure behaviors
    self.actor:UseBehavior(self, NavigatePathBehavior)
    self.actor.behaviors.NavigatePathBehavior:SetSpeedMultiplier(self.path_speed_multiplier)
end

function Patroller:GetSyncData()
    local sync_data = {}

    sync_data.path = self.path:GetJsonCompatibleData()
    sync_data.path_progress = self.actor.behaviors.NavigatePathBehavior:GetProgress() or 0.0001
    sync_data.path_speed_multiplier = self.path_speed_multiplier
    
    return sync_data
end

function Patroller:InitializeFromSpawnPoint(spawn_point)
    self.spawn_point = spawn_point
    self.path = spawn_point:GetPath()
    self.actor.position = Copy(self.path:GetPositions()[1])
    if self.actor.position then
        self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    end
    self.actor.behaviors.NavigatePathBehavior:SetPath(self.path)
    self.actor.behaviors.NavigatePathBehavior:StartPath()
end

-- "PathFinished" behavior event handler
-- could be moved to a separate behavior, but it's not much code
function Patroller:PathFinished()
    print("Entered PathFinished handler")
    -- reverse the path and start again
    self.path = self.path:GetReversedCopy()
    self.actor.behaviors.NavigatePathBehavior:SetPath(self.path)
    self.actor.behaviors.NavigatePathBehavior:StartPath()
    if count_table(self.actor.streamed_players) > 0 then
        Network:SendToPlayers(self.actor:GetStreamedPlayersSequential(), "npc/NextPath" .. tostring(self.actor:GetActorId()), {
            path = self.path:GetJsonCompatibleData()
        })
    end
end

function Patroller:Remove()
    
end