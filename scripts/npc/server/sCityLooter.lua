class "CityLooter"

function CityLooter:__init()
    getter_setter(self, "actor")
    getter_setter(self, "path")
    getter_setter(self, "announced")
    self.actor = Actor()
    self.actor:SetActorProfileEnum(ActorProfileEnum.CityLooter)
    self.path_speed_multiplier = 1.03

    -- Configure behaviors
    self.actor:UseBehavior(self, NavigatePathBehavior)
    self.actor:UseBehavior(self, RoamBehavior)
    self.actor.behaviors.NavigatePathBehavior:SetSpeedMultiplier(self.path_speed_multiplier)
end

function CityLooter:GetSyncData()
    local sync_data = {}

    if self.path then
        sync_data.path = self.path:GetJsonCompatibleData()
        sync_data.path_progress = self.actor.behaviors.NavigatePathBehavior:GetProgress() or 0.00001
        sync_data.path_speed_multiplier = self.path_speed_multiplier
    end
    sync_data.position = self.actor:GetPosition()
    
    return sync_data
end

function CityLooter:Initialize(data)
    self.actor.position = Copy(data.position)
    if self.actor.position then
        self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    end
    
    self.actor.behaviors.RoamBehavior:FindNextPath() -- self.actor.position should be up-to-date before calling FindNextPath
end

function CityLooter:PathAcquired(path)
    if self.removed then return end
    if not self.announced then
        self.announced = true
        ActorSync:AnnounceActor(self)
    end

    self.path = Path()
    self.path:SetPositions(path)
    self.actor.position = Copy(path[1])
    self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    self.actor.behaviors.NavigatePathBehavior:SetPath(self.path)
    self.actor.behaviors.NavigatePathBehavior:StartPath()

    if count_table(self.actor.streamed_players) > 0 then
        Network:SendToPlayers(self.actor:GetStreamedPlayersSequential(), "npc/NextPath" .. tostring(self.actor:GetActorId()), {
            path = self.path:GetJsonCompatibleData(),
            path_speed_multiplier = self.path_speed_multiplier
        })
    end
end

-- "PathFinished" behavior event handler
-- could be moved to a separate behavior, but it's not much code
function CityLooter:PathFinished()
    self.actor.position = Copy(self.path.positions[#self.path.positions])
    self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    self.actor.behaviors.RoamBehavior:FindNextPath() -- self.actor.position should be up-to-date before calling FindNextPath
end

function CityLooter:Remove()
    
end