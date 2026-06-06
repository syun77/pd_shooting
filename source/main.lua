import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics
local musicPlayer = pd.sound.fileplayer.new("sounds/bgm")

function pd.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        if musicPlayer:isPlaying() then
            musicPlayer:stop()
        else
            musicPlayer:play(0)
        end
    end

    gfx.clear()
    if musicPlayer:isPlaying() then
        -- 再生位置の描画.
        -- 現在の位置.
        local now = musicPlayer:getOffset()
        -- 全体の長さ.
        local total = musicPlayer:getLength()
        -- 進捗バーの描画.
        local w = now / total * 400
        gfx.fillRect(0, 10, w, 16)
        -- テキストの描画.
        gfx.drawText("Playing: " .. math.floor(now) .. " / " .. math.floor(total), 10, 40)
    end
end