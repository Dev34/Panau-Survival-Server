class "ActorProfileEnum"

function ActorProfileEnum:__init()
    self.Patroller = 1

    
    self.descriptions = {
        [self.Patroller] = "Patroller"
    }

    self.model_ids = {
        [self.Patroller] = 66
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

function ActorProfileEnum:GetModelId(actor_profile_enum)
    assert(self.model_ids[actor_profile_enum] ~= nil, "Actor profile enum " .. tostring(actor_profile_enum) .. " is not mapped to a model id")
    return self.model_ids[actor_profile_enum]
end

ActorProfileEnum = ActorProfileEnum()