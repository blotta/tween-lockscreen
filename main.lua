local tween = require 'libs.tween.tween'

-- SlidingSq class def

-- default values
SlidingSq = {}
SlidingSq.__index = SlidingSq

-- SlidingSq_defaults = {dv = 'dafultv'}

function setDefault(t, d)
    local default = {__index = function() return d end}
    setmetatable(t, default)
end

function SlidingSq.new(...)

    -- target sq
    local targetsq_defauts = {__index = {
        x = love.graphics.getWidth()/2 - 32,
        y = love.graphics.getHeight()/2 - 32,
        w = 64,
        h = 64}
    }
    t = select(1, ...)
    setmetatable(t, targetsq_defauts)

    -- object to return
    local o = {
        x = math.random(0, love.graphics.getWidth()),
        y = math.random(0, love.graphics.getHeight()),
        w = math.random(t.w / 4, t.w),
        h = math.random(t.h / 4, t.h),
        color = {
            r = math.random(),
            g = math.random(),
            b = math.random(),
            a = 0
        }
    }

    -- get position inside target square
    local innerTarget = {}
    innerTarget.x = t.x + math.random(t.w - o.w)
    innerTarget.y = t.y + math.random(t.h - o.h)

    -- tweeeeeens
    o.tweens = {
        -- fade in
        fade_in = tween.new(0.5, o.color, { a = 1 }, 'linear'),
        -- move to center
        move = tween.new(2, o, innerTarget, 'outExpo'),
        -- fade away
        fade_out = tween.new(math.random(), o.color, {
            a = 0
        }, 'linear')
    }

    return setmetatable( o, SlidingSq)
end

setmetatable(SlidingSq, { __call = function(_, ...) return SlidingSq.new(...) end})

-- class def end

-- target square class def

TargetSq = {}
TargetSq.__index = TargetSq

function TargetSq.new()
    local o = {
        x = love.graphics.getWidth()/2 - 32,
        y = love.graphics.getHeight()/2 - 32,
        w = 64,
        h = 64,
        -- color = {
        --     r = math.random(),
        --     g = math.random(),
        --     b = math.random(),
        --     a = 0
        -- }
    }

    o.tweens = {}

    return setmetatable(o, TargetSq)
end

function TargetSq:getSquare()
    return {x = self.x, y = self.y, w = self.w, h = self.h}
end

function TargetSq:setTween(action, ...)
    table.insert(self.tweens, { action = tween.new(...) })
    -- self.tweens = tween.new(...)
end

function TargetSq.move(self, x, y)
    self:setTween('move', 10, self, {x = x - self.w/2, y = y - self.h/2})
    -- print(#self.tweens)
end

setmetatable(TargetSq, { __call = function(_, ...) return TargetSq.new(...) end})

-- class def end


objList = {}

tq = nil
-- local obj = prot
-- local objTween = tween.new(4, obj, {x = 500, y=300}, 'inOutExpo')


function love.load()
    -- table.insert(objList, new_obj())

    tq = TargetSq()


end

function love.keypressed(key)
    if key == 'escape' then
        love.event.push('quit')
    elseif key == 'n' then
        table.insert(objList, SlidingSq(tq:getSquare()))
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        -- tq:setTween(10, tq, {x = x - tq.w/2, y = y - tq.h/2} )
        tq:move(x, y)
    end
end

function love.update(dt)
    for i, o in pairs(objList) do
        o.tweens.fade_in:update(dt)
        local mv_complete = o.tweens.move:update(dt)
        if mv_complete then
            local fo_complete = o.tweens.fade_out:update(dt)
            if fo_complete then
                table.remove(objList, i)
                table.insert(objList, SlidingSq(tq:getSquare()))
            end
        end
    end

    -- update TargetSq
    for a, t in pairs(tq.tweens) do
        -- t:update(dt)
        print(a)
        -- if a == 'move' then
        --     t:update(dt)
        -- end
    end

    -- insert more sqrs
    if #objList <= 10 and math.random(1,100) < 2 then
        table.insert(objList, SlidingSq(tq:getSquare()))
    end
end

function love.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()


    for i, o in pairs(objList) do
        love.graphics.setColor(o.color.r, o.color.g, o.color.b, o.color.a)
        love.graphics.rectangle('fill', o.x, o.y, o.w, o.h)
    end

    -- Reference lines
    love.graphics.setColor(0.5, 1, 1)
    love.graphics.line(w/2, 0, w/2, h) -- middle x
    love.graphics.line(0, h/2, w, h/2) -- middle y

    love.graphics.line(w/2 - 32, 0, w/2 - 32, h) -- top left x
    love.graphics.line(0, h/2 - 32, w, h/2 -32) -- top left y

    love.graphics.line(w/2 + 32, 0, w/2 + 32, h) -- bottom right x
    love.graphics.line(0, h/2 + 32, w, h/2 + 32) -- bottom righ y

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line', tq.x, tq.y, tq.w, tq.h)
end
