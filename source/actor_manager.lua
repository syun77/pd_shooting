--[[
	ActorManager.lua

	ActorManagerクラスは、ゲーム内のすべてのActorを管理するクラスです。
	Actorの生成、削除、取得などの機能を提供します。
--]]
import "CoreLibs/object"

---@generic T: Actor
class("ActorManager").extends()

---@generic T: Actor
---@param actorClass fun(...): T
function ActorManager:init(actorClass)
	self.actorClass = actorClass
	self.pool = {}
end

---@brief Actorの生成.
---@generic T: Actor
---@param ... any
---@return T
function ActorManager:create(...)
	local actor = self.actorClass(...)
	table.insert(self.pool, actor)
	return actor
end

---@generic T: Actor
---@return T[]
function ActorManager:getAll()
	return self.pool
end

---@generic T: Actor
---@param actor T
function ActorManager:remove(actor)
	for i = #self.pool, 1, -1 do
		if self.pool[i] == actor then
			table.remove(self.pool, i)
			return true
		end
	end
	return false
end