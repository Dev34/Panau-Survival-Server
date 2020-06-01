class "ActorProfileEnum"

function ActorProfileEnum:__init()
    self.Patroller = 1

    
    self.descriptions = {
        [self.Patroller] = "Patroller"
    }
end

function ActorProfileEnum:GetDescription(actor_profile_enum)
    assert(self.descriptions[actor_profile_enum] ~= nil)
    return self.descriptions[actor_profile_enum]
end

function ActorProfileEnum:GetClass(actor_profile_enum)
    local actor_profiles = {
        [self.Patroller] = Patroller
    }
    assert(actor_profiles[actor_profile_enum] ~= nil)
    return actor_profiles[actor_profile_enum]
end

ActorProfileEnum = ActorProfileEnum()