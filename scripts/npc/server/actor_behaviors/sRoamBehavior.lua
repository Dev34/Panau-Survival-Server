class "RoamBehavior"
RoamBehavior.name = "RoamBehavior"

function RoamBehavior:__init(actor_profile_instance)
    self.actor_profile_instance = actor_profile_instance
    getter_setter(self, "active")
    
end

function RoamBehavior:FindNextPath()-- requires GetPosition on the actor profile to be accurate at this point in time
    local current_position = self.actor_profile_instance.actor:GetPosition()
    PathEngineManager:GetRoamPath(current_position, self.PathRequestCallback, self)
end

function RoamBehavior:PathRequestCallback(data)
    if not data or data.error then
        self:FindNextPath()
    else
        self.actor_profile_instance.actor:FireBehaviorEvent("PathAcquired", data.path)
    end
end

function RoamBehavior:GetPosition()
    if not self.path_navigation then return nil end
    return self.path_navigation:GetPosition()
end

-- returns 0.0 -> 1.0 path progress
function RoamBehavior:GetProgress()
    if not self.path_navigation then return nil end
    return self.path_navigation:GetPathProgress()
end

function RoamBehavior:PathFinishedCallback()
    self.actor_profile_instance.actor:FireBehaviorEvent("PathFinished")
end