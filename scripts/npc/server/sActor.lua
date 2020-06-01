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
    
    sync_data.active = self.active
    sync_data.actor_id = self.actor_id
    sync_data.actor_profile_enum = self.actor_profile_enum
    sync_data.position = self.position
    sync_data.cell = self.cell
    sync_data.host = self.host

    return sync_data
end