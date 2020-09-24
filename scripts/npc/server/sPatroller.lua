class "Patroller"

function Patroller:__init(actor_id)
    getter_setter(self, "actor")
    getter_setter(self, "path")
    self.actor = Actor(actor_id)
    self.actor:SetActorProfileEnum(ActorProfileEnum.Patroller)
    self.actor:SetModelId(ActorProfileEnum:GetModelId(ActorProfileEnum.Patroller))
    self.actor:SetWeaponEnum(random_weighted_table_value({
        [WeaponEnum.Handgun] = 120,
        [WeaponEnum.Revolver] = 120,
        [WeaponEnum.SawnOffShotgun] = 30,
        [WeaponEnum.SMG] = 30,
        [WeaponEnum.Assault] = 25,
        [WeaponEnum.MachineGun] = 25,
        [WeaponEnum.Sniper] = 15
    }))
    self.path_speed_multiplier = 1.03

    self:DeclareNetworkSubscriptions()

    -- Configure behaviors
    self.actor:UseBehavior(self, NavigatePathBehavior)
    self.actor:UseBehavior(self, ShootTargetBehavior)
    self.actor:UseBehavior(self, ChasePlayerBehavior)
    self.actor.behaviors.NavigatePathBehavior:SetSpeedMultiplier(self.path_speed_multiplier)
    self.actor.behaviors.ChasePlayerBehavior:SetMaxChaseTime(45000) -- max time spent pathing towards the target before we get the timeout event (in milliseconds)
end

function Patroller:DeclareNetworkSubscriptions()
    Network:Subscribe("npc/PlayerAttackNPC" .. tostring(self.actor.actor_id), self, self.PlayerAttacked)
end

function Patroller:GetSyncData()
    local sync_data = {}

    sync_data.path = self.path:GetJsonCompatibleData()
    sync_data.path_progress = self.actor.behaviors.NavigatePathBehavior:GetProgress() or 0.0001
    sync_data.path_speed_multiplier = self.path_speed_multiplier
    
    return sync_data
end

function Patroller:InitializeFromSpawnPoint(spawn_point)
    self.spawn_point = spawn_point
    self.path = spawn_point:GetPath()
    self.actor.position = Copy(self.path:GetPositions()[1])
    if self.actor.position then
        self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    end
    self.actor.behaviors.NavigatePathBehavior:SetPath(self.path)
    self.actor.behaviors.NavigatePathBehavior:StartPath()
end


-- "PathAcquired" behavior event handler from ChasePlayerBehavior
function Patroller:PathAcquired(path)
    if self.removed then return end
    if not self.announced then
        self.announced = true
        ActorSync:AnnounceActor(self)
    end

    self.path = Path()
    self.path:SetPositions(path)
    self.actor.position = Copy(path[1])
    self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
    self.actor.behaviors.NavigatePathBehavior:SetPath(self.path)
    self.actor.behaviors.NavigatePathBehavior:StartPath()

    if count_table(self.actor.streamed_players) > 0 then
        Network:SendToPlayers(self.actor:GetStreamedPlayersSequential(), "npc/NextPath" .. tostring(self.actor:GetActorId()), {
            path = self.path:GetJsonCompatibleData(),
            path_speed_multiplier = self.path_speed_multiplier
        })
    end
end

-- "PathFinished" behavior event handler
-- could be moved to a separate behavior, but it's not much code
-- currently 
function Patroller:PathFinished()
    print("Entered PathFinished handler")
    self.actor.position = Copy(self.path.positions[#self.path.positions])
    self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)

    if self:IsChasing() then
        self:PathFinishedWhileChasing()
    else
        self:PathFinishedWhilePatrolling()
    end
end

function Patroller:PathFinishedWhilePatrolling()
    -- reverse the path and start again
    self.path = self.path:GetReversedCopy()
    self.actor.behaviors.NavigatePathBehavior:SetPath(self.path)
    self.actor.behaviors.NavigatePathBehavior:StartPath()
    if count_table(self.actor.streamed_players) > 0 then
        Network:SendToPlayers(self.actor:GetStreamedPlayersSequential(), "npc/NextPath" .. tostring(self.actor:GetActorId()), {
            path = self.path:GetJsonCompatibleData(),
            path_speed_multiplier = self.path_speed_multiplier
        })
    end
end

function Patroller:PathFinishedWhileChasing()
    self.actor.behaviors.ShootTargetBehavior:StopShootingTarget(false)
    self.actor.behaviors.ChasePlayerBehavior:StartChasing(self.target) -- self.actor.position should be up-to-date before calling StartChasing
end

function Patroller:PlayerAttacked(args, player)
    local should_acquire_target = false
    if self.target ~= player then
        should_acquire_target = true
    elseif not self.target or not IsValid(self.target) then
        should_acquire_target = true
    end
    if not self.actor:IsPlayerStreamedIn(player) then
        print("tried to set NewTarget but new target is not streamed in")
        should_acquire_target = false
    end

    if should_acquire_target then
        self:NewTarget(player)
        self.actor.behaviors.NavigatePathBehavior:Pause()
        if args.line_of_sight then
            self.actor.behaviors.ChasePlayerBehavior:StopChasing()
            self.actor.behaviors.ShootTargetBehavior:ShootTarget(self.target)
        else
            self:UpdateStoredPosition()
            self.actor.behaviors.ChasePlayerBehavior:StartChasing(player)
        end
    end

    self.actor:SyncStateEventsIfNecessary()
end

function Patroller:NewTarget(new_target)
    self.target = new_target
end

function Patroller:StoppedShootingTarget() -- happens when LoS is lost after min duration of shooting
    self:UpdateStoredPosition()
    if self.target and IsValid(self.target) then
        self.actor.behaviors.ShootTargetBehavior:StopShootingTarget(false)
        self.actor.behaviors.ChasePlayerBehavior:StartChasing(self.target)
    else
        self.target = nil
        -- TODO: do something! find path back to the path?
        --self.actor.behaviors.RoamBehavior:FindNextPath()
    end
    
    Chat:Broadcast("Entered StoppedShootingTarget", Color.Red)
    self.actor:SyncStateEventsIfNecessary()
end

function Patroller:LineOfSightGainedWhenChasing()
    self.actor.behaviors.NavigatePathBehavior:Pause()
    self.actor.behaviors.ChasePlayerBehavior:StopChasing()
    self.actor.behaviors.ShootTargetBehavior:ShootTarget(self.target)
    self.actor:SyncStateEventsIfNecessary()
end

-- from ChasePlayerBehavior
function Patroller:ChasingTimedOut()
    self.target = nil
    self:UpdateStoredPosition()
    -- TODO: do something! find path back to path or something
    --self.actor.behaviors.RoamBehavior:FindNextPath() -- self.actor.position should be up-to-date before calling FindNextPath
    self.actor.behaviors.NavigatePathBehavior:Pause()
    self.actor.behaviors.ChasePlayerBehavior:StopChasing()

    self.actor:SyncStateEventsIfNecessary()
end

function Patroller:IsChasing()
    return self.actor.behaviors.ChasePlayerBehavior.chasing
end

function Patroller:UpdateStoredPosition()
    self.actor.position = self.actor.behaviors.NavigatePathBehavior:GetPosition()
    self.actor.cell = GetCell(self.actor.position, ActorSync.cell_size)
end

function Patroller:Remove()
    
end