Commander = require "commander"


EditorCommander = Class{
    __includes = Commander,
    init = function(self, pos, tms)
        Commander.init(self, pos)
        self.selected = 1
        self.selected_tm = 1
        self.tms = tms
        self:updateSelectedTM()
        self.tile_info = nil
        self.quad = nil
        self.image = self.tm.tileset.image
        self:updateTileInfo()
    end,
    updateSelectedTM = function(self)
        self.tm = self.tms[math.floor(1 + (self.selected_tm + 0.5) % #self.tms)]
    end,
    updateTileInfo = function(self)
        if self.selected < 1 then
            self.selected = #self.tm.tileset.tiles
        end
        if self.selected > #self.tm.tileset.tiles then
            self.selected = 1
        end
        local c = self.tm.tileset.tiles[math.floor(self.selected + 0.5)].char
        self.tile_info = self.tm.tileset:getTileInfo(c)
        self.quad = self.tile_info:getQuad()
    end,
    update = function(self, dt, editor)
        Commander.update(self, dt, editor)

        if not self.joystick then
            return
        end

        if self.joystick:isGamepadDown("leftshoulder") then
            self.selected = self.selected - 0.1
        end
        if self.joystick:isGamepadDown("rightshoulder") then
            self.selected = self.selected + 0.1
        end

        self:updateTileInfo()

        if self.joystick:isGamepadDown("x") then
            self.selected_tm = self.selected_tm + 0.1
        end

        self:updateSelectedTM()

        if self.joystick:isGamepadDown("a") then
            self:place()
        end
    end,
    place = function(self)
        self.tm:setTile(math.floor(self.pos.x / 24 + 0.5) + 1,
                        math.floor(self.pos.y / 24 + 0.5) + 1,
                        self.tile_info.char)
    end,
    erase = function(self)
        self.tile_info = self.tm.tileset.tiles[43]
        self:place()
        self:updateTileInfo()
    end,
    pick = function(self)
        local c = self.tm:getTileChar(math.floor(self.pos.x / 24 + 0.5) + 1,
                                      math.floor(self.pos.y / 24 + 0.5) + 1)
        for i, info in ipairs(self.tm.tileset.tiles) do
            if info.char == c then
                self.selected = i
                self:updateTileInfo()
                return
            end
        end

    end,
    draw = function(self)
        love.graphics.setColor(255, 255, 255)
        local rpos = self.pos:clone()
        rpos.x = math.floor(rpos.x / 24 + 0.5) * 24
        rpos.y = math.floor(rpos.y / 24 + 0.5) * 24
        love.graphics.draw(self.image, self.quad, rpos.x, rpos.y)

        if 1 == math.floor(1 + (self.selected_tm + 0.5) % #self.tms) then
            love.graphics.setColor(127, 0, 0)
        else
            love.graphics.setColor(0, 0, 255)
        end

        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("rough")
        love.graphics.line(rpos.x, rpos.y-1,
                           rpos.x + self.width+1, rpos.y-1,
                           rpos.x + self.width+1, rpos.y + self.height,
                           rpos.x, rpos.y + self.height,
                           rpos.x, rpos.y-1)
    end
}

return EditorCommander
