---@diagnostic disable
--[[
	ActorManager.lua

	ActorManagerクラスは、ゲーム内のすべてのActorを管理するクラスです。
	Actorの生成、削除、取得などの機能を提供します。
--]]
import "CoreLibs/object"

---@generic T
class("ActorManager").extends()

--- コンストラクタ.
---@generic T
---@param actorClass fun(...): T
function ActorManager:init(actorClass)
	self.actorClass = actorClass
	self.pool = {}
end

--- Actorの生成.
---@generic T
---@param ... any
---@return T
function ActorManager:create(...)
	local actor = self.actorClass(...)
	---@cast actor any
	actor.manager = self -- Actorに自分を管理者として設定.
	table.insert(self.pool, actor)
	return actor
end

--- すべてのActorを取得.
---@generic T
---@return T[]
function ActorManager:getAll()
	return self.pool
end

--- Actorの削除.
---@generic T
---@param actor T
function ActorManager:remove(actor)
	---@cast actor any
	for i = #self.pool, 1, -1 do
		if self.pool[i] == actor then
			table.remove(self.pool, i)
			actor.manager = nil
			actor:remove()
			return true
		end
	end
	return false
end

--- Actor生成数の取得.
--- @generic T
--- @return integer
function ActorManager:getCount()
	return #self.pool
end

--- foreachで管理しているActorに処理を行う.
--- @generic T
--- @param func fun(actor: T)
function ActorManager:forEach(func)
	for _, actor in ipairs(self.pool) do
		func(actor)
	end
end

