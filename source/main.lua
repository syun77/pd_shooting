import "CoreLibs/graphics"
import "CoreLibs/object" -- classを使うために必要.
import "CoreLibs/sprites" -- spriteを使うために必要.
import "actor"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite
local vec2 <const> = pd.geometry.vector2D

-- Playerクラスの定義.
class("Player").extends(Actor)
-- コンストラクタ.
function Player:init(x, y)
	Player.super.init(self, x, y, 16, 16)
	-- Player.super.setCenter(self, 0.5, 0.5) -- 中心をスプライトの中央に設定.
	print("Player created at (" .. x .. ", " .. y .. ")")
end
-- 更新.
function Player:update()
	Player.super.update(self) -- Actorのupdateを呼び出す.

	-- 十字キーで移動.
	self.vx = 0
	self.vy = 0
	local v = vec2.new(0, 0)
	local moveSpeed = 5
	if pd.buttonIsPressed(pd.kButtonLeft) then
		v.x = -1
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		v.x = 1
	end
	if pd.buttonIsPressed(pd.kButtonUp) then
		v.y = -1
	elseif pd.buttonIsPressed(pd.kButtonDown) then
		v.y = 1
	end
	if v.x == 0 and v.y == 0 then
		return
	end

	v = v:normalized() -- ベクトルを正規化して斜め移動も同じ速度になるようにする.
	v *= moveSpeed -- ベクトルに移動速度を掛ける.
	self:move(v.x, v.y, true) -- 画面外に出ないように移動.
end

local player = Player(200, 120)

function pd.update()
    gfx.clear()
	sprite.update() -- すべてのスプライトを更新と描画.

    if pd.buttonJustPressed(pd.kButtonA) then
		print("A button was just pressed!")
    end

	gfx.drawText("Hello, Playdate!", 10, 10)
end
