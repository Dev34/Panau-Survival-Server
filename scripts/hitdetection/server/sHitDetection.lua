class 'sHitDetection'

function sHitDetection:__init()

    Network:Subscribe("HitDetectionSyncHit", self, self.SyncHit)
end

function sHitDetection:SyncHit(args, player)

    for _, v in pairs(args.pending) do

        if v.type == WeaponHitType.Explosive then
            self:ExplosionHit(v, player)
        else
            self:BulletHit(v, player)
        end

    end

end

function sHitDetection:ExplosionHit(args, player)

    if not IsValid(args.attacker) then return end

    if args.attacker:GetValue("InSafezone") or player:GetValue("InSafezone") then return end

    local weapon = args.attacker:GetEquippedWeapon()
    if not weapon then return end

    local percent = 1
    if not args.damage then args.damage = 100 end

    if weapon.id == Weapon.GrenadeLauncher then
        percent = args.damage / 350
    elseif weapon.id == Weapon.RocketLauncher then
        percent = args.damage / 1000
    else
        percent = args.damage / 1000
    end

    percent = math.clamp(percent, 0, 1)

    if not WeaponBaseDamage[weapon.id] then return end
    
    local hit_type = WeaponHitType.Explosive
    local original_damage = WeaponBaseDamage[weapon.id] * percent
    local damage = original_damage
    damage = self:GetArmorMod(player, hit_type, damage, original_damage)

    local old_hp = player:GetHealth()
    player:SetValue("LastHealth", old_hp)
    player:Damage(damage / 100, DamageEntity.Explosion, args.attacker)

    print(string.format("%s shot %s for %s damage [%s]",
    args.attacker:GetName(), player:GetName(), tostring(damage), tostring(weapon.id)))

    Events:Fire("HitDetection/PlayerExplosionHit", {
        player = player,
        attacker = args.attacker,
        damage = damage
    })

    --self:CheckHealth(player, damage)

end

function sHitDetection:CheckHealth(player, damage)

    local timeout = player:GetPing() * 2 + 1000
    -- If their health doesn't change after being shot

    Timer.SetTimeout(timeout, function()
        if not IsValid(player) then return end
        if IsValid(player) and player:GetHealth() >= player:GetValue("LastHealth") and damage > 0 and player:GetHealth() > 0 then
            Events:Fire("KickPlayer", {
                player = player,
                reason = string.format("Health hacks. Current health %s, last known health: %s", 
                    tostring(player:GetHealth()), tostring(player:GetValue("LastHealth"))),
                p_reason = "Health hacks"
            })
        end
    end)

end

function sHitDetection:BulletHit(args, player)
    if not args.bone or not BoneModifiers[args.bone.name] then return end
    if not IsValid(args.attacker) then return end

    if args.attacker:GetValue("InSafezone") or player:GetValue("InSafezone") then return end

    local weapon = args.attacker:GetEquippedWeapon()
    if not weapon then return end
    
    if not WeaponBaseDamage[weapon.id] then return end

    local hit_type = BoneModifiers[args.bone.name].type
    local original_damage = WeaponBaseDamage[weapon.id] * BoneModifiers[args.bone.name].mod
    local damage = original_damage
    damage = self:GetArmorMod(player, hit_type, damage, original_damage)

    local old_hp = player:GetHealth()
    player:SetValue("LastHealth", old_hp)
    player:Damage(damage / 100, DamageEntity.Bullet, args.attacker)

    print(string.format("%s shot %s for %s damage [%s]",
    args.attacker:GetName(), player:GetName(), tostring(damage), tostring(weapon.id)))

    Events:Fire("HitDetection/PlayerBulletHit", {
        player = player,
        attacker = args.attacker,
        damage = damage
    })

    -- If their health doesn't change after being shot
    --self:CheckHealth(player, damage)

end

function sHitDetection:GetArmorMod(player, hit_type, damage, original_damage)

    local equipped_items = player:GetValue("EquippedItems")

    for armor_name, mods in pairs(ArmorModifiers) do
        if equipped_items[armor_name] and ArmorModifiers[armor_name][hit_type] > 0 then

            damage = damage * (1 - ArmorModifiers[armor_name][hit_type])

            -- If the armor prevented some damage, then modify its durability
            if ArmorModifiers[armor_name][hit_type] > 0 then
                Events:Fire("HitDetection/ArmorDamaged", {
                    player = player,
                    armor_name = armor_name,
                    damage_diff = original_damage - original_damage * (1 - ArmorModifiers[armor_name][hit_type])
                })
            end

        end
    end

    return damage

end

sHitDetection = sHitDetection()