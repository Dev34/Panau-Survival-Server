class "BaseManager"

function BaseManager:__init()
    Events:Subscribe("ModuleLoad", self, self.LoadBases)
end

function BaseManager:LoadBases()
    self:LoadBase("testbase")
end

function BaseManager:LoadBase(base_name)
    local base = Bases:LoadBase(base_name)
    base:SpawnActors()
end

BaseManager = BaseManager()