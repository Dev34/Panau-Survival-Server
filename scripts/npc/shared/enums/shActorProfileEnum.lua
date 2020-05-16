class "ActorProfileEnum"

function ActorProfileEnum:__init()
    self.PanauMilitaryPatrollerBasic = 1

    
    self.descriptions = {
        [self.PanauMilitaryPatrollerBasic] = "Panau Military Patroller Basic"
    }
end

function ActorProfileEnum:GetDescription(actor_profile_enum)
    return self.descriptions[actor_profile_enum]
end

ActorProfileEnum = ActorProfileEnum()