---@diagnostic disable
--[[
	GameContext.lua

	GameContextクラスは、ゲーム全体の状態を管理するクラスです。
	プレイヤー、敵、弾などの共有オブジェクトを保持し、ゲームの初期化や状態管理を行います。
--]]
import "CoreLibs/object"
import "actor_manager"

class("GameContext").extends()

GameContext.instance = nil

-- シングルトンインスタンスを取得.
function GameContext.getInstance()
	if GameContext.instance == nil then
		GameContext.instance = GameContext()
	end
	return GameContext.instance
end

-- 初期化.
function GameContext:init()
	self.player = nil
	self.shotManager = nil
	self.enemyManager = nil
	self.bulletManager = nil
	self.boss = nil
end

-- 破棄.
function GameContext:destroy()
	self.player = nil
	self.shotManager = nil
	self.enemyManager = nil
	self.bulletManager = nil
	self.boss = nil
end

-- ゲームで使う共有オブジェクトを一度だけ初期化する.
function GameContext:setup(enemyType)
	if self.player ~= nil then
		return
	end

	-- プレイヤー生成.
	self.player = Player(200, 200)
	-- 各種管理クラスを生成.
	self.shotManager = ActorManager(Shot)
	self.enemyManager = ActorManager(Enemy)
	self.bulletManager = ActorManager(Bullet)

	-- 各種参照を登録.
	self.player.shots = self.shotManager
	-- ボスを生成して敵管理に登録.
	self.boss = Boss(200, 20)
	self.boss:setType(enemyType.Boss)
	self.enemyManager:add(self.boss)
end
