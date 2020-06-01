class "Actor"

function Actor:__init()
    getter_setter(self, "active")
    getter_setter(self, "actor_id")
    getter_setter(self, "actor_profile_enum")
    getter_setter(self, "position")
    getter_setter(self, "cell")
    getter_setter(self, "host")
end

function Actor:GetSyncData()
    local sync_data = {}
    
    sync_data.actor_id = self.actor_id
    sync_data.actor_profile_enum = self.actor_profile_enum
    sync_data.position = self.position
    sync_data.cell = self.cell

    return sync_data
end

function Actor:InitializeFromSyncData(sync_data)
    if sync_data.active ~= nil then
        self.active = sync_data.active
    end
    if sync_data.actor_id then
        self.actor_id = sync_data.actor_id
    end
    if sync_data.position then
        self.position = sync_data.position
    end
    if sync_data.actor_profile_enum then
        self.actor_profile_enum = sync_data.actor_profile_enum
    end
    if sync_data.cell then
        self.cell = sync_data.cell
    end
end