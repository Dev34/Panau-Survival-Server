class 'sAirStrikes'

function sAirStrikes:__init()

    self.cooldown = 10 -- Must wait 10 seconds before you can use another

    Events:Subscribe("Inventory/UseItem", self, self.UseItem)
    Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)
    Network:Subscribe("items/PlaceAirstrike", self, self.PlaceAirstrike)
    Network:Subscribe("items/CancelAirstrikePlacement", self, self.CancelAirstrikePlacement)

end

function sAirStrikes:ClientModuleLoad(args)
    args.player:SetValue("LastAirstrikeTime", Server:GetElapsedSeconds())
end

function sAirStrikes:GetAirstrikeData(airstrike)
    local data = deepcopy(airstrike)
    data.timer = data.timer:GetSeconds()
    return data
end

function sAirStrikes:PlaceAirstrike(args, player)
    Inventory.OperationBlock({player = player, change = -1})

    local using_item = player:GetValue("AirstrikeUsingItem")

    if not using_item then return end

    player:SetValue("AirstrikeUsingItem", nil)

    if args.position:Distance(player:GetPosition()) > 1000 then return end

    local sz_config = SharedObject.GetByName("SafezoneConfig"):GetValues()

    -- If they are within sz radius * 2, we don't let them place that close
    if args.position:Distance(sz_config.neutralzone.position) < sz_config.neutralzone.radius * 1.5 then
        Chat:Send(player, "Cannot use this while near the neutralzone!", Color.Red)
        return
    end

    player:SetValue("LastAirstrikeTime", Server:GetElapsedSeconds())

    Inventory.RemoveItem({
        item = using_item.item,
        index = using_item.index,
        player = player
    })

    local airstrike_item_data = ItemsConfig.airstrikes[using_item.item.name]

    local airstrike_data = {
        name = using_item.item.name,
        timer = Timer(),
        position = args.position,
        attacker_id = tostring(player:GetSteamId()),
        seed = math.random(9999999999)
    }

    local drop_position = args.position + Vector3.Up * 500
    local direction = Vector3(math.random() - 0.5, 0, math.random() - 0.5):Normalized()
    local start_position = drop_position - direction * 500
    local end_position = drop_position + direction * 500

    local vehicle = Vehicle.Create({
        position = start_position,
        angle = Angle.FromVectors(Vector3.Forward, direction),
        model_id = airstrike_item_data.plane_id,
        tone1 = Color.Black,
        tone2 = Color.Black,
        linear_velocity = direction * airstrike_item_data.plane_velo,
        invulnerable = true
    })
    vehicle:SetStreamDistance(3000)
    vehicle:SetStreamPosition(start_position)

    Network:Broadcast("items/CreateAirstrike", self:GetAirstrikeData(airstrike_data))

    local interval = Timer.SetInterval(1000, function()
        if IsValid(vehicle) then
            vehicle:SetLinearVelocity(direction * airstrike_item_data.plane_velo)
        end
    end)

    -- Remove active airstrike once it has expired
    Timer.SetTimeout(1000 * airstrike_item_data.delay, function()

        if IsValid(player) then
            Events:Fire("items/ItemExplode", {
                position = args.position,
                radius = airstrike_item_data.radius,
                player = player,
                owner_id = tostring(player:GetSteamId()),
                type = airstrike_item_data.damage_entity
            })
        end

        Timer.SetTimeout(1000 * 5, function()
            Timer.Clear(interval)
            if IsValid(vehicle) then 
                vehicle:Remove()
            end
        end)

    end)

end

function sAirStrikes:CancelAirstrikePlacement(args, player)
    Inventory.OperationBlock({player = player, change = -1})
end

function sAirStrikes:UseItem(args)

    if not ItemsConfig.airstrikes[args.item.name] then return end

    local last_time = args.player:GetValue("LastAirstrikeTime")

    if Server:GetElapsedSeconds() - last_time < self.cooldown then
        Chat:Send(args.player, "You muse wait before using this!", Color.Red)
        return
    end

    Inventory.OperationBlock({player = args.player, change = 1}) -- Block inventory operations until they finish placing or cancel
    args.player:SetValue("AirstrikeUsingItem", args)

    Network:Send(args.player, "items/StartAirstrikePlacement", {
        name = args.item.name
    })

end

sAirStrikes = sAirStrikes()