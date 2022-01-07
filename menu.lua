local menu = {}

function menu.init()
    buttons = {}
    buttons.play = {'play', centre.y + 100, false}
    buttons.quit = {'quit', centre.y + 300, false}

    for k, _ in pairs(buttons) do
        buttons[k][4] = {centre.x - 80*round((#buttons[k][1])/2, 0), buttons[k][2]-25, 80*round(#buttons[k][1], 0), 100}
    end

    title = {name = 'ARENA', x = centre.x-600, y = 50}

    font = {}
    font.mainfont = love.graphics.newFont('mainfont.ttf', 40)
    font.titlefont = love.graphics.newFont('mainfont.ttf', 400)
    
    audio.menu = love.audio.newSource('audio/mainmenu.mp3', 'static')
    audio.button = love.audio.newSource('audio/pistol.wav', 'static')

    love.audio.play(audio.menu)

    menu = true
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(mult * num + 0.5)/mult
end

function quit()
    love.event.quit()
end

function play()
    love.audio.stop(audio.menu)
    menu = false --confusing lol but its returning false because we want to close the menu
end

function menu.update(dt)
    mouse[1], mouse[2] = love.mouse.getPosition()
    for k, _ in pairs(buttons) do
        if CheckInt(mouse, buttons[k][4]) then
            buttons[k][3] = true
        else buttons[k][3] = false end
    end
    return menu
end

function menu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font.titlefont)
    love.graphics.print(title.name, title.x, title.y)

    love.graphics.setFont(font.mainfont)
    for k, _ in pairs(buttons) do
        if buttons[k][3] then love.graphics.setColor(0.7, 0.7, 0.7)
        else love.graphics.setColor(1, 1, 1) end
        love.graphics.rectangle('fill', buttons[k][4][1], buttons[k][4][2], buttons[k][4][3], buttons[k][4][4])
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(buttons[k][1], 0, buttons[k][2], window.x, 'center')
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    if love.mouse.isDown(1) then
        love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 10)
    else love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10) end
end

function menu.mousepressed(x, y)
    for k, _ in pairs(buttons) do
        if CheckInt({x, y}, buttons[k][4]) then
            love.audio.play(audio.button)
            _G[buttons[k][1]]()
        end
    end
end

return menu