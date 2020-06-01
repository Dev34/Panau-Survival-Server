class "ActorManager"

function ActorManager:__init()
    getter_setter(self, "actors")
    self.actors = {}
    self.current_actor_id = 1

    if IsTest then
        Events:Subscribe("PlayerChat", self, self.PlayerChatDebug)
        Events:Subscribe("ModuleLoad", self, self.ModuleLoadDebug)
    end
end

function ActorManager:PlayerChatDebug(args)
    if args.text:find("/actor") then
        local chat_tokens = split(args.text, " ")
        local actor_profile_enum = tonumber(chat_tokens[2])

        if not actor_profile_enum or type(actor_profile_enum) ~= "number" then
            args.player:SendChatMessage("Specify an actor profile!", Color.Red)
            return
        end
        
        local actor = ActorManager:CreateActor(actor_profile_enum, args.player:GetPosition())
    end
end

function ActorManager:ModuleLoadDebug()
    self.actor1 = self:CreateActor(ActorProfileEnum.Patroller)
    self.actor2 = self:CreateActor(ActorProfileEnum.Patroller)

    self.actor1:GetActor():SetPosition(Vector3(662, 298.99, -3997.2))
    self.actor1:GetActor():SetCell(GetCell(Vector3(662, 298.99, -3997.2), ActorSync.cell_size))

    self.actor1:GetActor():SetPosition(Vector3(662, 298.99, -3997.2))
    self.actor1:GetActor():SetCell(GetCell(Vector3(662, 298.99, -4000.2), ActorSync.cell_size))
end

function ActorManager:CreateActor(actor_profile_enum)
    local actor_id = self.current_actor_id
    self.current_actor_id = self.current_actor_id + 1
    local actor_profile_class = ActorProfileEnum:GetClass(actor_profile_enum)
    local actor_profile_instance = actor_profile_class()
    local actor = actor_profile_instance:GetActor()

    actor:SetActorId(actor_id)

    self.actors[actor_id] = actor_profile_instance

    print("Created Actor")

    return actor_profile_instance
end

ActorManager = ActorManager()