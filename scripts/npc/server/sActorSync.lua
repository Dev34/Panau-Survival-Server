class "ActorSync"

function ActorSync:__init()
    self.cell_size = 256
    self.cell_table = CellTable()

    Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
    Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)
    Events:Subscribe("Cells/PlayerCellUpdate" .. tostring(self.cell_size), self, self.PlayerCellUpdate)
end

function ActorSync:ModuleLoad()
    self:SyncActors()
end

function ActorSync:ClientModuleLoad(args)
    Events:Fire("ForcePlayerUpdateCell", {player = args.player, cell_size = self.cell_size})
end

function ActorSync:GetActiveActorsInCells(cells)
    local actors = {}

    local actor
    local actor_cell
    local actor_cell_x, actor_cell_y
    for actor_id, actor_profile in pairs(ActorManager:GetActors()) do
        actor = actor_profile:GetActor()
        actor_cell = actor:GetCell()
        if actor.active and actor_cell then
            actor_cell_x = actor_cell.x; actor_cell_y = actor_cell.y
            for _, cell in pairs(cells) do
                if cell.x == actor_cell_x and cell.y == actor_cell_y then
                    actors[actor:GetActorId()] = actor_profile
                end
            end
        end
    end

    return actors
end

function ActorSync:SyncActors()

end

function ActorSync:PlayerCellUpdate(args)
    --[[
        {
        player,
        old_cell = current_cell,
        old_adjacent = old_adjacent,
        cell = cell,
        adjacent = new_adjacent,
        updated = updated
    }
    ]]
    local actor_data = {}
    --print("Entered new cell: ", args.cell.x, ",", args.cell.y)
    --print("updated:")
    --output_table(args.updated)
    --print("old adjacent:")
    --output_table(args.old_adjacent)

    local actors_to_sync = ActorSync:GetActiveActorsInCells(args.updated)
    actor_data.new_actors = {}
    for actor_id, actor_profile in pairs(actors_to_sync) do
        actor_data.new_actors[actor_id] = {
            actor_sync_data = actor_profile:GetActor():GetSyncData(),
            profile_sync_data = actor_profile:GetSyncData()
        }
    end
    --output_table(actors_to_sync)
    --output_table(actor_data)

    local stale_actors_to_sync = ActorSync:GetActiveActorsInCells(args.old_adjacent)
    actor_data.stale_actors = {}
    for actor_id, actor_profile in pairs(stale_actors_to_sync) do
        actor_data.stale_actors[actor_id] = {
            actor_sync_data = actor_profile:GetActor():GetSyncData(),
            profile_sync_data = actor_profile:GetSyncData()
        }
    end

    Network:Send(args.player, "npc/SyncActors", actor_data)
end

ActorSync = ActorSync()