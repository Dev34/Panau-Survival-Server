class "Actor"

function Actor:__init()
    getter_setter(self, "active")
    getter_setter(self, "actor_id")
    getter_setter(self, "actor_profile_enum")
    getter_setter(self, "position")
    getter_setter(self, "cell")
    getter_setter(self, "host")
    getter_setter(self, "streamed_players")
    getter_setter(self, "behaviors")
    getter_setter(self, "actor_profile_instance")
    self.behaviors = {}
    self.streamed_players = {}
end

function Actor:StreamInPlayer(player)
    if not IsValid(player) then return end
    
    local steam_id = tostring(player:GetSteamId())
    self.streamed_players[steam_id] = player
end

function Actor:StreamOutPlayer(player)
    if not IsValid(player) then return end

    local steam_id = tostring(player:GetSteamId())
    self.streamed_players[steam_id] = nil
end

function Actor:GetStreamedPlayersSequential()
    local sequential_streamed_players = {}
    for steam_id, player in pairs(self.streamed_players) do
        table.insert(sequential_streamed_players, player)
    end
    return sequential_streamed_players
end

function Actor:GetSyncData()
    local sync_data = {}
    
    sync_data.active = self.active
    sync_data.actor_id = self.actor_id
    sync_data.actor_profile_enum = self.actor_profile_enum
    sync_data.position = self.position
    sync_data.cell = self.cell
    sync_data.host = self.host

    return sync_data
end

function Actor:UseBehavior(actor_profile_instance, behavior_class)
    local behavior_instance = behavior_class(actor_profile_instance)
    self.behaviors[behavior_class.name] = behavior_instance
    behavior_instance:SetActive(true)
end

function Actor:DeactivateAllBehaviors()
    for behavior_name, behavior_instance in pairs(self.behaviors) do
        behavior_instance:SetActive(false)
    end
end

-- map the behavior event to a function of the same name on the Agent
function Actor:FireBehaviorEvent(event_name, args)
    if self.actor_profile_instance[event_name] then
        self.actor_profile_instance[event_name](self.actor_profile_instance, args)
    end
end