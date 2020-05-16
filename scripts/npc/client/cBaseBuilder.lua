class "BaseBuilder"

function BaseBuilder:__init()
    self.debug_bases = {}

    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("Render", self, self.Render)

    Network:Subscribe("npc/SyncDebugBase", self, self.SyncDebugBase)
end

function BaseBuilder:LocalPlayerChat(args)
end

function BaseBuilder:SyncDebugBase(args)
    local base = Base()
    base:SetName(args.name)
    base:InitializeFromJsonData(args.serialized_data)

    output_table(args)
    self.debug_bases[args.name] = base
end

function BaseBuilder:Render()
    for base_name, base in pairs(self.debug_bases) do
        self:RenderBaseDebug(base)
    end
end

function BaseBuilder:RenderBaseDebug(base)
    local base_pos = base:GetPosition()

    if base_pos then
        -- Render the base name at base position
        if Vector3.Distance(Camera:GetPosition(), base_pos) < 800 then
            local pos = Render:WorldToScreen(base_pos)
            Render:DrawText(pos, "Base: [ " .. base:GetName() .. " ]", Color.Aqua)
        end
    end

    for spawn_point_name, spawn_point in pairs(base:GetSpawnPoints()) do
        local spawn_point_path = spawn_point:GetPath()
        if spawn_point_path then
            spawn_point_path:RenderDebug(false) -- render the Path positions

            -- render the spawn point name at first path position since there is a Path
            local first_pos = spawn_point_path:GetPositions()[1]
            if Vector3.Distance(Camera:GetPosition(), first_pos) < 600 then
                Render:DrawText(Render:WorldToScreen(first_pos), "Spawn Point: [ " .. spawn_point:GetName() .. " ]", Color.LawnGreen)
            end
        end

        -- render the spawn point name at defined sp position
        --if self.position then
        --Render:DrawText(Render:WorldToScreen(self.position), "Spawn Point: [ " .. spawn_point:GetName() .. " ]", Color.LawnGreen)
        --end
        
    end
end

if IsTest then
    BaseBuilder = BaseBuilder()
end