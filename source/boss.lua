---@diagnostic disable
--[[
	boss.lua

	Bossクラスは、ゲーム内のボスキャラクターを表すクラスです。
	Enemyクラスを継承し、ボス特有の動きや攻撃パターンを実装します。
--]]
import "CoreLibs/object"
import "actor"
import "enemy"

local pd <const> = playdate
local vec2 <const> = pd.geometry.vector2D

-- ボスの定義.
class("Boss").extends(Enemy)
function Boss:init(x, y)
	Boss.super.init(self, x, y, 48, 48)
	self.hp = 20 -- ボスのHP.
	print("Boss created at (" .. x .. ", " .. y .. ")")
end
