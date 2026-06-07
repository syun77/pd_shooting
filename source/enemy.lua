---@diagnostic disable
--[[
	Enemy.lua

	Enemyクラスは、ゲーム内の敵キャラクターを表すクラスです。
	Actorクラスを継承し、敵特有の動きや攻撃パターンを実装します。
--]]
import "CoreLibs/object"
import "actor"
import "game_context"

-- 遅延弾発射情報.
class ("DelayedBatteryInfo").extends()
function DelayedBatteryInfo:init(angle, speed, delay, ax, ay)
	self.angle = angle
	self.speed = speed
	self.delay = delay
	self.ax = ax or 0
	self.ay = ay or 0
end
function DelayedBatteryInfo:elapsed()
	self.delay -= 1
	if self.delay <= 0 then
		return true -- 発射可能.
	end
	return false
end

-- 敵クラスの定義.
class("Enemy").extends(Actor)

-- コンストラクタ.
function Enemy:init(x, y)
	Enemy.super.init(self, x, y, 32, 32)
	self.bullets = GameContext.getInstance().bulletManager -- 弾を管理するActorManagerへの参照.
	self.hp = 3 -- 敵のHP.
	self.timer = 0
	self.batteries = {} -- 遅延弾発射の情報を格納するテーブル.
	print("Enemy created at (" .. x .. ", " .. y .. ")")
end

-- 弾を撃つ.
--- @param angle number 角度（度）
--- @param speed number 速度
--- @param delay? integer 遅延時間（フレーム数）
--- @param ax? number 加速度X
--- @param ay? number 加速度Y
function Enemy:bullet(angle, speed, delay, ax, ay)
	if self.bullets == nil then
		return
	end
	-- デフォルト引数を設定.
	if delay == nil then delay = 0 end
	if ax == nil then ax = 0 end
	if ay == nil then ay = 0 end

	if delay > 0 then
		-- 遅延発射なのでリストに追加するだけ.
		self:_addBattery(angle, speed, delay, ax, ay)
		return
	end

	-- そのまま発射可能.
	local bullet = self.bullets:create(self.x, self.y)
	bullet:setVelocity(angle, speed)
	bullet.ax = ax
	bullet.ay = ay
end

-- 更新.
function Enemy:update()
	Enemy.super.update(self)
	self.timer += 1
	if self.timer % 30 == 0 then
		local aim = self:getAim()
		for i = 0, 5 do
			local delay = i * 3
			self:nWayBullet(3, aim, 5, 30, delay) -- 毎秒1発、プレイヤーに向かって弾を撃つ.
		end
	end
	self:_updateBatteries() -- 遅延弾発射の更新.
end

-- 敵種別を設定.
function Enemy:setType(type)
	self.type = type
end

-- 敵にダメージを与える関数.
function Enemy:damage(amount)
	self.hp = self.hp - amount
	print("Enemy damaged! HP: " .. self.hp)
	if self.hp <= 0 then
		self:despawn() -- HPが0以下になったら削除.
	end
end

-- プレイヤーへの狙い撃ち角度を取得する.
function Enemy:getAim()
	local player = GameContext.getInstance().player
	if player == nil then
		return 270 -- プレイヤーがいない場合は下方向に撃つ.
	end
	local dx = player.x - self.x
	local dy = player.y - self.y
	local angle = math.atan2(-dy, dx) * 180 / math.pi -- atan2の引数は(y, x)の順で、yは反転させる.
	return angle
end

-- N-Wayショットを撃つ.
--- @param n integer 弾の数
--- @param angle number 中心の角度（度）
--- @param speed number 速度
--- @param spread number 弾の広がり角度（度）
--- @param delay? integer 遅延時間（フレーム数）
function Enemy:nWayBullet(n, angle, speed, spread, delay)
	if self.bullets == nil then
		return
	end
	local d = spread / n
	local a = angle - (d * 0.5 * (n - 1))
	for i = 0, n - 1 do
		self:bullet(a, speed, delay)
		a += d
	end
end

-- 遅延弾発射の情報を追加する.
--- @param angle number 角度（度）
--- @param speed number 速度
--- @param delay integer 遅延時間（フレーム数）
--- @param ax number 加速度X
--- @param ay number 加速度Y
function Enemy:_addBattery(angle, speed, delay, ax, ay)
	table.insert(self.batteries, DelayedBatteryInfo(angle, speed, delay, ax, ay))
end

-- 遅延弾発射の更新.
function Enemy:_updateBatteries()
	for i = #self.batteries, 1, -1 do
		local battery = self.batteries[i]
		if battery:elapsed() then
			self:bullet(battery.angle, battery.speed, 0, battery.ax, battery.ay)
			table.remove(self.batteries, i) -- 発射したらリストから削除.
		end
	end
end
