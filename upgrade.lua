local upgrade = {}

function upgrade.init(info)
    Weapons, Score = player.weapons, player.score

    if #Weapons == 1 then Weapons[2] = {name = 'empty'} end

    local shop = {
        {{name = 'machine gun', dmg = 1, delay = 0.1, reload = 2, speed = 25,
        ammo = {60, 60, 400}, size = 3, colour = {1, 0.7, 0.8}, spread = 10, auto = true, reloading = false, timer = 0,
        audio = love.audio.newSource('audio/machinegun.wav', 'static'), decay = false, desc = 'shoots fast but low dmg', bulletsfired = 1},
        {name = 'assault rifle', dmg = 3, delay = 0.2, reload = 1, speed = 15, ammo = {40, 40, 250}, size = 8,
        colour = {0.3, 0.1, 0.6}, spread = 5, auto = true, reloading = false, decay = false,
        audio = love.audio.newSource('audio/assaultrifle.wav', 'static'), desc = 'the classic', bulletsfired = 1},
        {name = 'shotgun', dmg = 2, delay = 0.5, reload = 2, speed = 25, ammo = {16, 16, 220}, size = 15,
        colour = {0.1, 1, 1}, spread = 30, auto = false, reloading = false, decay = true, decayrate = 1.05,
        audio = love.audio.newSource('audio/shotgun.wav', 'static'), desc = 'great for close range', bulletsfired = 8}},
        {{name = 'minigun', dmg = 0.5, delay = 0.01, reload = 2, speed = 20, ammo = {80, 80, 540}, size = 3,
        colour = {1, 0.7, 0}, spread = 15, auto = true, reloading = false, timer = 0 , bulletsfired = 1,
         audio = love.audio.newSource('audio/machinegun.wav', 'static'), decay = false, desc = 'shoots super fast'},
        {name = 'double shotgun', dmg = 2, delay = 0.5, reload = 2, speed = 25, ammo = {32, 32, 440}, size = 9,
        colour = {0.6, 1, 1}, spread = 50, auto = false, reloading = false, decay = true, decayrate = 1.1,
        audio = love.audio.newSource('audio/shotgun.wav', 'static'), desc = 'a better shotgun', bulletsfired = 16},
        {name = 'sniper', dmg = 10, delay = 1, reload = 3, speed = 40, ammo = {5, 5, 100}, size = 7, colour = {1, 1, 1},
        spread = 0, auto = false, reloading = false, decay = false, audio = love.audio.newSource('audio/sniper.wav', 'static'),
        desc = 'fast, high dmg and accurate', bulletsfired = 1}},
        {{name = 'flame thrower', dmg = 0.5, delay = 0.05, reload = 2, speed = 25, ammo = {60, 60, 300}, size = 15,
        colour = {1, 0, 0}, spread = 30, auto = true, reloading = false, decay = true, decayrate = 1.13,
        audio = love.audio.newSource('audio/flamethrower.wav', 'static'), desc = 'let it burn', bulletsfired = 1},
        {name = 'quad minigun', dmg = 0.7, delay = 0.03, reload = 2, speed = 20, ammo = {160, 160, 1500}, size = 3,
        colour = {1, 0.7, 0}, spread = 30, auto = true, reloading = false, decay = false,
        audio = love.audio.newSource('audio/flamethrower.wav', 'static'), desc = 'spray and pray', bulletsfired = 4},
        {name = 'growing pistol', dmg = 8, delay = 0.3, reload = 1, speed = 12, ammo = {30, 30, 500}, size = 3,
        colour = {1, 0.7, 0}, spread = 30, auto = true, reloading = false, decay = true, decayrate = 0.95,
        audio = love.audio.newSource('audio/flamethrower.wav', 'static'), desc = 'growth', bulletsfired = 4}},
        {{name = 'super shotgun', dmg = 2, delay = 0.5, reload = 2, speed = 20, ammo = {48, 48, 600}, size = 15,
        colour = {0.1, 1, 1}, spread = 30, auto = false, reloading = false, decay = false,
        audio = love.audio.newSource('audio/shotgun.wav', 'static'), desc = 'shotgun but the bullets are better', bulletsfired = 24},
        {name = 'auto sniper', dmg = 10, delay = 0.5, reload = 2.5, speed = 40, ammo = {10, 10, 250}, size = 7, colour = {1, 1, 1},
        spread = 0, auto = true, reloading = false, decay = false, audio = love.audio.newSource('audio/sniper.wav', 'static'),
        desc = 'faster and better', bulletsfired = 1}}
    }

    for i=1, #shop do
        for k=1, #shop[i] do
            if player.weapons[1]['name'] == shop[i][k]['name'] then
                player.weapons[1]['ammo'][3] = shop[i][k]['ammo'][3]
            end
            if player.weapons[2]['name'] == shop[i][k]['name'] then
                player.weapons[2]['ammo'][3] = shop[i][k]['ammo'][3]
            end
        end
    end

    local level = Score/20
    if level == 5 then level = 4 end
    local levelpick = math.random(1, level)
    local levelpick2 = math.random(1, level)
    local gunpick, gunpick2 = 0, 0
    while gunpick == gunpick2 do
        gunpick = shop[levelpick][math.random(1, #shop[levelpick])]
        gunpick2 = shop[levelpick2][math.random(1, #shop[levelpick2])]
    end
    CurrentShop = {}
    CurrentShop[1], CurrentShop[2] = gunpick, gunpick2

    font = {}
    font.upgradefont = love.graphics.newFont('mainfont.ttf', 80)
    font.titlefont = love.graphics.newFont('mainfont.ttf', 40)
    font.descfont = love.graphics.newFont('mainfont.ttf', 20)

    box = {}
    box[1] = {centre.x/3, centre.y/2, centre.x-centre.x/3-centre.x/8, centre.y+centre.y/3}
    box[2] = {centre.x+centre.x/8, centre.y/2, centre.x-centre.x/3-centre.x/8, centre.y+centre.y/3}
    
    hovering = {false, false}
    hoveringweapon = {false, false}
    selected = {false, false}
    upgrading = true
end

function upgrade.update(dt)
    mouse[1], mouse[2]= love.mouse.getPosition()
    for i=1, #box do
        if CheckInt(mouse, box[i]) then
            hovering[i] = true
        else hovering[i] = false end
    end

    if selected[1] then
        if CheckInt(mouse, {centre.x + centre.x/4, centre.y-centre.y/4, #Weapons[1]['name']*50, 100}) then
            hoveringweapon[1] = true
        else hoveringweapon[1] = false end
        if CheckInt(mouse, {centre.x + centre.x/4, centre.y+centre.y/4, #Weapons[2]['name']*50, 100}) then
            hoveringweapon[2] = true
        else hoveringweapon[2] = false end
    elseif selected[2] then
        if CheckInt(mouse, {centre.x - centre.x/2, centre.y-centre.y/4, #Weapons[1]['name']*50, 100}) then
            hoveringweapon[1] = true
        else hoveringweapon[1] = false end
        if CheckInt(mouse, {centre.x - centre.x/2, centre.y+centre.y/4, #Weapons[2]['name']*50, 100}) then
            hoveringweapon[2] = true
        else hoveringweapon[2] = false end
    end

    if not upgrading then player.bought = player.bought + 1
        for i=1, #player.weapons do
            if player.weapons[i]['name'] == 'empty' then table.remove(player.weapons, i) end
        end
    end
    return upgrading
end

function upgrade.draw()
    if not selected[1] and not selected[2] then
        love.graphics.setFont(font.upgradefont)
        love.graphics.printf('GET A NEW GUN', 0, 100, window.x, 'center')

        love.graphics.setFont(font.titlefont)
        love.graphics.print(CurrentShop[1]['name'], centre.x-1.28*centre.x/2, centre.y/2)
        love.graphics.print(CurrentShop[2]['name'], centre.x+centre.x/7, centre.y/2)

        love.graphics.setFont(font.descfont)
        love.graphics.print('dmg: '..round(CurrentShop[1]['dmg'] + player.modifiers['damage']/2, 1), centre.x-1.28*centre.x/2, centre.y/2+80)
        love.graphics.print('reload time: '..round(CurrentShop[1]['reload']- player.modifiers['reload']/3, 1), centre.x-1.28*centre.x/2, centre.y/2+160)
        love.graphics.print('max ammo: '..round(CurrentShop[1]['ammo'][3] + CurrentShop[1]['ammo'][3]/10*(4*player.modifiers['ammo']/3), 0), centre.x-1.28*centre.x/2, centre.y/2+240)
        love.graphics.printf(CurrentShop[1]['desc'], box[1][1], centre.y/2+320, box[1][3], 'center')

        love.graphics.print('dmg: '..round(CurrentShop[2]['dmg'] + player.modifiers['damage']/2, 1), centre.x+centre.x/6, centre.y/2+80)
        love.graphics.print('reload time: '..round(CurrentShop[2]['reload'] - player.modifiers['reload']/3, 1), centre.x+centre.x/6, centre.y/2+160)
        love.graphics.print('max ammo: '..round(CurrentShop[2]['ammo'][3] + CurrentShop[1]['ammo'][3]/10*(4*player.modifiers['ammo']/3), 0), centre.x+centre.x/6, centre.y/2+240)
        love.graphics.printf(CurrentShop[2]['desc'], box[2][1], centre.y/2+320, box[2][3], 'center')

        love.graphics.rectangle('line', box[1][1], box[1][2], box[1][3], box[1][4])
        love.graphics.rectangle('line', box[2][1], box[2][2], box[2][3], box[2][4])

        love.graphics.setFont(font.upgradefont)
        if hovering[1] then
            love.graphics.print('->', centre.x/8, centre.y)
        elseif hovering[2] then
            love.graphics.print('<-', window.x-centre.x/4, centre.y)
        end
    else
        love.graphics.setFont(font.upgradefont)
        love.graphics.printf('CHOOSE A GUN TO REPLACE', 0, 100, window.x, 'center')
        if selected[1] then
            love.graphics.setFont(font.titlefont)
            love.graphics.print(CurrentShop[1]['name'], centre.x-1.28*centre.x/2, centre.y/2)
            love.graphics.print(Weapons[1]['name'], centre.x + centre.x/4, centre.y-centre.y/4)
            love.graphics.print(Weapons[2]['name'], centre.x + centre.x/4, centre.y+centre.y/4)

            love.graphics.setFont(font.descfont)
            love.graphics.print('dmg: '..CurrentShop[1]['dmg'], centre.x-1.28*centre.x/2, centre.y/2+80)
            love.graphics.print('reload time: '..CurrentShop[1]['reload'], centre.x-1.28*centre.x/2, centre.y/2+160)
            love.graphics.print('max ammo: '..CurrentShop[1]['ammo'][3], centre.x-1.28*centre.x/2, centre.y/2+240)
            love.graphics.printf(CurrentShop[1]['desc'], box[1][1], centre.y/2+320, box[1][3], 'center')

            love.graphics.rectangle('line', box[1][1], box[1][2], box[1][3], box[1][4])

            if hoveringweapon[1] then
                love.graphics.line(centre.x + centre.x/4-#Weapons[1]['name']*20, centre.y-centre.y/4+70, centre.x + centre.x/4+#Weapons[1]['name']*30, centre.y-centre.y/4+70)
            elseif hoveringweapon[2] then
                love.graphics.line(centre.x + centre.x/4-#Weapons[1]['name']*20, centre.y+centre.y/4+70, centre.x + centre.x/4+#Weapons[2]['name']*30, centre.y+centre.y/4+70)
            end
        else
            love.graphics.setFont(font.titlefont)
            love.graphics.print(CurrentShop[2]['name'], centre.x+centre.x/7, centre.y/2)
            love.graphics.print(Weapons[1]['name'], centre.x - centre.x/2, centre.y-centre.y/4)
            love.graphics.print(Weapons[2]['name'], centre.x - centre.x/2, centre.y+centre.y/4)

            love.graphics.setFont(font.descfont)
            love.graphics.print('dmg: '..CurrentShop[2]['dmg'], centre.x+centre.x/6, centre.y/2+80)
            love.graphics.print('reload time: '..CurrentShop[2]['reload'], centre.x+centre.x/6, centre.y/2+160)
            love.graphics.print('max ammo: '..CurrentShop[2]['ammo'][3], centre.x+centre.x/6, centre.y/2+240)
            love.graphics.printf(CurrentShop[2]['desc'], box[2][1], centre.y/2+320, box[2][3], 'center')

            love.graphics.rectangle('line', box[2][1], box[2][2], box[2][3], box[2][4])

            if hoveringweapon[1] then
                love.graphics.line(centre.x - centre.x/2-#Weapons[1]['name']*20, centre.y-centre.y/4+70, centre.x - centre.x/3+#Weapons[1]['name']*30, centre.y-centre.y/4+70)
            elseif hoveringweapon[2] then
                love.graphics.line(centre.x - centre.x/2-#Weapons[1]['name']*20, centre.y+centre.y/4+70, centre.x - centre.x/3+#Weapons[2]['name']*30, centre.y+centre.y/4+70)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    if love.mouse.isDown(1) then
        love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 10)
    else love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10) end
end

function upgrade.mousepressed(x, y)
    if not selected[1] and not selected[2] then
        for i=1, #box do
            if CheckInt({x, y}, box[i]) then
                selected[i] = true
            end
        end
    end
    if selected[1] then
        if hoveringweapon[1] then
            player.weapons[1] = CurrentShop[1]
            upgrading = false
        elseif hoveringweapon[2] then
            player.weapons[2] = CurrentShop[1]
            upgrading = false
        end
    elseif selected[2] then
        if hoveringweapon[1] then
            player.weapons[1] = CurrentShop[2]
            upgrading = false
        elseif hoveringweapon[2] then
            player.weapons[2] = CurrentShop[2]
            upgrading = false
        end
    end
end

return upgrade