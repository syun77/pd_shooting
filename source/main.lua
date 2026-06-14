---@diagnostic disable
import "CoreLibs/graphics"
import "CoreLibs/object" -- classを使うために必要.
import "CoreLibs/sprites" -- spriteを使うために必要.
import "actor"
import "player"
import "shot"
import "actor_manager"
import "enemy"
import "boss"
import "bullet"
import "game_context"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sprite <const> = gfx.sprite

local gameContext = GameContext.getInstance()
gameContext:setup()

function pd.update()
    gfx.clear()
	sprite.update() -- すべてのスプライトを更新と描画.

	-- shot vs enemy.
	gameContext.shotManager:forEach(function(shot)
		gameContext.enemyManager:forEach(function(enemy)
			if shot:isCollidingCircle(enemy) then
				print("Hit!")
				shot:despawn() -- 当たったショットを削除.
				enemy:damage(1) -- 敵にダメージを与える.
			end
		end)
	end)
	
	-- bossを取得.
	local boss = gameContext.enemyManager:findFirst(function(enemy)
		return enemy.type == eEnemyType.Boss
	end)
	-- ボスのHPを画面に表示.
	if boss then
		gfx.drawText("Boss HP: " .. boss.hp, 10, 10)
	end
	-- ショットの数を画面に表示.
	gfx.drawText("shot: " .. gameContext.shotManager:getCount(), 10, 30)
	-- 敵弾の数を画面に表示.
	gfx.drawText("bullet: " .. gameContext.bulletManager:getCount(), 10, 50)
	-- 敵の数を画面に表示.
	gfx.drawText("enemy: " .. gameContext.enemyManager:getCount(), 10, 70)
end
