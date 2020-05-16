class "BaseManager"

function BaseManager:__init()
    Events:Subscribe("ModuleLoad", self, self.LoadBases)
end

function BaseManager:LoadBases()
    --Bases:LoadBase("testbase")
end

BaseManager = BaseManager()