Menu = require 'menu'
Game = require 'game'
Upgrade = require 'upgrade'
Passives = require 'passives'
Boss = require 'bossfight'

function love.load()
    love.window.setFullscreen(true)
    love.mouse.setVisible(false)
    love.window.setTitle('ARENA')
    window = {}
    window.x, window.y = love.graphics.getDimensions()
    centre = {}
    centre.x, centre.y = window.x/2, window.y/2
    mouse = {0, 0}

    player = {}
    player.bought = 0
    player.passives = 0
    player.score = 0

    audio = {}
    audio.music = love.audio.newSource('audio/arena.mp3', 'static')
    audio.music:setLooping(true)

    game = {}
    game.menu = true
    game.play = false
    game.buy = false
    game.over = false
    game.passives = false
    game.boss = false
    game.state = ''
    game.info = {}
    game.mainfont = love.graphics.newFont('mainfont.ttf', 40)

    upgraded = {}

    Menu.init()
end

function CheckInt(m, obj)
    local mx, my = m[1], m[2]
    local x, y, w, h = obj[1], obj[2], obj[3], obj[4]
    if mx < x + w and mx > x and my < y + h and my > y then
        return true
    else return false end
end

function love.update(dt)
    if game.menu then
        game.menu = Menu.update(dt)
        if not game.menu then
            game.play = true
            love.audio.play(audio.music)
            player.score = 0
            player.bought = 0
            player.passives = 0
            Game.init()
        end
    end
    if game.play then game.state = Game.update(dt) end
    if game.state ~= nil then
        game.play = false
        if game.state == 'buy' then game.buy = true; Upgrade.init()
        elseif game.state == 'dead' then game.over = true 
        elseif game.state == 'passive' then game.passives = true; Passives.init()
        elseif game.state == 'boss fight' then game.boss = true; Boss.init() end
        game.state = nil
    end
    if game.buy then
        game.buy = Upgrade.update(dt)
        if not game.buy then
            game.play = true
            Game.init()
        end
    end
    if game.passives then
        game.passives = Passives.update(dt)
        if not game.passives then
            game.play = true
            Game.init()
        end
    end
    if game.boss then
        game.state = Boss.update(dt)
        if game.state ~= nil then game.boss = false end
        if game.state == 'win' then game.win = true
        elseif game.state == 'dead' then game.over = true end
    end
end

function love.draw()
    if game.menu then Menu.draw() end
    if game.play then Game.draw() end
    if game.buy then Upgrade.draw() end
    if game.passives then Passives.draw() end
    if game.boss then Boss.draw() end

    if game.over or game.win then
        love.graphics.setFont(love.graphics.newFont('mainfont.ttf', 60))
        if game.over then
            love.graphics.printf('Game over', 0, centre.y, window.x, 'center')
        else
            love.graphics.printf('You win!', 0, centre.y, window.x, 'center')
            love.graphics.setFont(love.graphics.newFont('mainfont.ttf', 20))
            love.graphics.printf("Thanks for playing! This is one of my first games and it was made in Love2D."..
            "Please don't hesitate to leave a comment on the itch.io page (good or bad, I'd love feedback!). Hope you enjoyed :)", 
            0, window.y-100, window.x, 'center')
        end
        local n = 0
        love.graphics.setFont(love.graphics.newFont('mainfont.ttf', 40))

        for k, v in pairs(player.modifiers) do
            love.graphics.print(k..' level'..' : '..v, 30, n*70)
            n = n + 1
        end
        for i=1, #player.weapons do
            love.graphics.print(player.weapons[i]['name'], centre.x+300, 100+i*200)
        end
    end
end

function love.keypressed(key)
    if key == 'escape' and not game.menu then
        game.play, game.buy, game.passives, game.boss, game.over, game.win = false, false, false, false, false, false
        love.audio.stop()
        game.menu = true
        Menu.init()
    end
    if game.play then Game.keypressed(key) end
    if game.boss then Boss.keypressed(key) end
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num*mult+0.5)/mult
end

function love.mousepressed(x, y, button)
    if game.menu then Menu.mousepressed(x, y) end
    if game.play then Game.mousepressed(x, y, button) end
    if game.buy then Upgrade.mousepressed(x, y) end
    if game.passives then Passives.mousepressed(x, y) end
    if game.boss then Boss.mousepressed(x, y, button) end
end