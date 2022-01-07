local game = {}

function game.init()
    love.graphics.setColor(1, 1, 1)
    math.randomseed(os.time())

    if player.score == 0 then player.weapons = {{name = 'pistol', dmg = 2, delay = 0.5, reload = 1.5, speed = 12, ammo = {12, 12, 100}, size = 8,
        colour = {0.7, 0.7, 0.7}, spread = 5, auto = false, reloading = false, timer = 0 , bulletsfired = 1,
         audio = love.audio.newSource('audio/pistol.wav', 'static'), decay = false}}
        player.modifiers = {health = 0, ammo = 0, speed = 0, reload = 0, dash = 0,
        damage = 0, size = 0, bullet = 0, clip = 0, dashduration = 0, spread = 0}
    end

    player.x = centre.x
    player.y = centre.y
    player.speed = 10 + player.modifiers['speed']/2
    player.timer = 0
    player.r = 30 - player.modifiers['size']*2
    player.reloading = false
    player.hp = 3 + player.modifiers['health']
    player.flash = false
    player.colour = {1, 1, 1}
    player.flashtimer = 0
    player.dashunlocked = true
    player.dashtimer = 0
    player.dashdelay = 2 - player.modifiers['dash']/4
    player.dashlength = 0.1 + player.modifiers['dashduration']/10
    player.dashing = false
    player.dashdirection = 0
    player.score = (player.passives + player.bought)*10
    player.weapon_no = 1
    player.current_weapon = player.weapons[player.weapon_no]

    for i=1, #player.weapons do
        for k=1, #upgraded do
            if upgraded[k] == 'ammo' then
                player.weapons[i]['ammo'][3] = round(player.weapons[i]['ammo'][3] + player.weapons[i]['ammo'][3]/10*(4*player.modifiers['ammo']/3), 0)
            elseif upgraded[k] == 'clip' then
                player.weapons[i]['ammo'][2] = round(player.weapons[i]['ammo'][2] + player.weapons[i]['ammo'][3]/10*(5*player.modifiers['clip']/4), 0)
            elseif upgraded[k] == 'reload' then
                player.weapons[i]['reload'] = player.weapons[i]['reload'] - player.modifiers['reload']/3
            elseif upgraded[k] == 'bullet' then
                player.weapons[i]['size'] = player.weapons[i]['size'] + player.modifiers['bullet']*2
            elseif upgraded[k] == 'damage' then
                player.weapons[i]['dmg'] = player.weapons[i]['dmg'] + player.modifiers['damage']/3
            elseif upgraded[k] == 'spread' then
                player.weapons[i]['spread'] = player.weapons[i]['spread'] - (player.modifiers['spread']/2)*player.weapons[i]['spread']
            end
        end
    end


    audio.reload = love.audio.newSource('audio/reload.mp3', 'static')
    audio.enemydead = love.audio.newSource('audio/deadenemy.wav', 'static')
    audio.switchweapons = love.audio.newSource('audio/switchweapons.wav', 'static')
    audio.enemyhit = love.audio.newSource('audio/enemyhit.wav', 'static')

    font = {}
    font.mainfont = love.graphics.newFont('mainfont.ttf', 40)
    font.smallfont = love.graphics.newFont('mainfont.ttf', 20)
    font.tinyfont = love.graphics.newFont('mainfont.ttf', 5)
    font.scorefont = love.graphics.newFont('mainfont.ttf', 500)
    font.tutfont = love.graphics.newFont('mainfont.ttf', 60)

    bullets = {} --x, y, size, speed, direction, colour, dmg

    enemy = {}
    enemy.timer = 0
    enemy.spawnwait = 1

    settings = {}
    settings.difficulty = 1
    settings.level = 1

    enemies = {}

    particles = {}
end

function intable(set, key)
    return set[key] ~= nil
end

function newenemy()
    local edge = math.random(1, 4)
    local x, y = 0, 0
    if edge == 1 then x = 0; y = math.random(0, window.y)
    elseif edge == 2 then x = window.x; y = math.random(0, window.y)
    elseif edge == 3 then x = math.random(0, window.x); y = 0
    else x = math.random(0, window.x); y = window.y end
    local etype = math.random(1, settings.level)
    if settings.level >= 5 then etype = math.random(settings.level - 5, settings.level) end
    if etype == 1 then
        table.insert(enemies, {name = 'Stalker', x = x, y = y, size = 25, 
        speed = 6, dmg = 0.5, hp = 3, colour = {0.7,0.2,0.2}, flash = false, timer = 0})
    elseif etype == 2 then
        table.insert(enemies, {name = 'Gunner', x = x, y = y, size = 20, dmg = 1,
        speed = 5, hp = 3, colour = {0.3,0.2,0.8}, flash = false, timer = 0,
        gun = {dmg = 1, delay = 0.5, reload = 1.5, speed = 8, ammo = {0, 3}, size = 6, reloading = false, timer = 0,
        audio = love.audio.newSource('audio/enemyspawn.wav', 'static')}})
    elseif etype == 3 then
        table.insert(enemies, {name = 'Sniper', x = x, y = y, size = 20, dmg = 0, speed = 2, hp = 5,
        colour = {0.2, 0.8, 0.3}, flash = false, timer = 0, gun = {dmg = 2, delay = 0, reload = 3, speed = 15,
        ammo = {0, 1}, size = 4, reloading = false, timer = 0, audio = love.audio.newSource('audio/sniper.wav', 'static')}})
    elseif etype == 4 then
        table.insert(enemies, {name = 'Charger', x = x, y = y, size = 25, dmg = 1, speed = 2, hp = 11,
        colour = {1, 102/255, 0}, flash = false, timer = 0, charging = false, chargetimer = 0, cooldown = 3,
        chargelenth = 2, chargespeed = 13})
    elseif etype == 5 then
        table.insert(enemies, {name = 'Tank', x = x, y = y, size = 50, dmg = 3, speed = 3, hp = 25,
        colour = {153/255, 102/255, 255}, flash = false, timer = 0})
    elseif etype == 6 then
        table.insert(enemies, {name = 'Machine Gunner', x = x, y = y, size = 35, dmg = 0, speed = 3, hp = 15,
        colour = {153/255, 204/255, 255}, flash = false, timer = 0, gun = {dmg = 0.5, delay = 0.1, reload = 3, speed = 12,
        ammo = {0, 20}, size = 2, reloading = false, timer = 0, audio = love.audio.newSource('audio/mgunner.wav', 'static')}})
    elseif etype == 7 then
        table.insert(enemies, {name = 'Summoner', x = x, y = y, size = 40, dmg = 0, speed = 3, hp = 17,
        colour = {102/255, 0, 102/255}, flash = false, timer = 0, summon = {amount = 3, size = 7, summontimer = 0,
        summondelay = 5, speed = 6, flash = false, timer = 0}, audio = love.audio.newSource('audio/summoner.wav', 'static')})
    elseif etype == 8 then
        table.insert(enemies, {name = 'Bomber', x = x, y = y, size = 40, dmg = 2, speed = 4, hp = 25,
        colour = {1, 0, 0}, flash = false, timer = 0, gun = {dmg = 5, delay = 0, reload = 3, speed = 7,
        ammo = {0, 1}, size = 35, reloading = false, timer = 0, audio = love.audio.newSource('audio/exploder.wav', 'static')}})
    elseif etype == 9 then
        table.insert(enemies, {name = 'Sprayer', x = x, y = y, size = 20, dmg = 1, speed = 7, hp = 31,
        colour = {0.2, 0.5, 0.8}, flash = false, timer = 0, gun = {dmg = 5, delay = 0.02, reload = 4, speed = 7,
        ammo = {0, 90}, size = 5, reloading = false, timer = 0, audio = love.audio.newSource('audio/sprayer.wav', 'static')}})
    end
end

function game.update(dt)
    settings.level = math.floor(player.score/10) + 1
    player.timer = player.timer + dt
    player.dashtimer = player.dashtimer + dt
    enemy.timer = enemy.timer + dt
    player.current_weapon = player.weapons[player.weapon_no]

    if not player.dashing then
        if love.keyboard.isDown('a') and player.x > 0 then player.x = player.x - player.speed end
        if love.keyboard.isDown('d') and player.x < window.x then player.x = player.x + player.speed end
        if love.keyboard.isDown('w') and player.y > 0 then player.y = player.y - player.speed end
        if love.keyboard.isDown('s') and player.y < window.y then player.y = player.y + player.speed end
    elseif player.dashing and player.dashtimer < player.dashlength then
        if player.x > 40 and player.x < window.x -40 then player.x = player.x + math.cos(player.dashdirection)*40 end
        if player.y > 40 and player.y < window.y - 40 then player.y = player.y + math.sin(player.dashdirection)*40 end
    else player.dashing = false end

    if love.mouse.isDown(1) and player.current_weapon['auto'] and not player.current_weapon['reloading'] then
        love.audio.stop(player.current_weapon['audio'])
        love.audio.stop(player.current_weapon['audio'])
        game.mousepressed(love.mouse.getX(), love.mouse.getY(), 1)
    end

    if enemy.timer >= enemy.spawnwait then
        newenemy()
        enemy.timer = 0
        if settings.difficulty == 1 then enemy.spawnwait = 2
        elseif settings.difficulty == 4 then enemy.spawnwait = 1.5
        elseif settings.difficulty == 6 then enemy.spawnwait = 1
        elseif settings.difficulty == 8 then enemy.spawnwait = 0.5
        elseif settings.difficulty == 9 then enemy.spawnwait = 0.3 end
    end

    if player.flash then
        player.flashtimer = player.flashtimer + dt
        if player.flashtimer >= 0.1 then
            player.flash = false
            player.flashtimer = 0
        end
    end

    if player.score % 10 == 0 and player.score ~= 0 then
        settings.difficulty = round(player.score/10, 0)
    end

    if player.current_weapon['reloading'] then
        player.current_weapon['timer'] = player.current_weapon['timer'] + dt
    end

    if player.current_weapon['reloading'] and player.current_weapon['timer'] >= player.current_weapon['reload'] then
        player.current_weapon['reloading'] = false
        if player.current_weapon['ammo'][3] >= player.current_weapon['ammo'][2] then
            player.current_weapon['ammo'][3] = player.current_weapon['ammo'][3] - (player.current_weapon['ammo'][2] - player.current_weapon['ammo'][1])
            player.current_weapon['ammo'][1] = player.current_weapon['ammo'][2]
        else 
            player.current_weapon['ammo'][1] = player.current_weapon['ammo'][1] + player.current_weapon['ammo'][3] 
            player.current_weapon['ammo'][3] = 0
        end
    end

    --update enemies
    for i=#enemies, 1, -1 do

        --flash when hit
        if enemies[i]['flash'] and enemies[i]['timer'] >= 0.15 then
            enemies[i]['flash'] = false
            enemies[i]['timer'] = 0
        elseif enemies[i]['flash'] then
            enemies[i]['flash'] = true
            enemies[i]['timer'] = enemies[i]['timer'] + dt
        end

        if enemies[i]['hp'] > 0 then
            --update pos
            local angle = math.atan((player.y-enemies[i]['y'])/(player.x-enemies[i]['x']))
            if player.x < enemies[i]['x'] then angle = angle + math.pi end
            if enemies[i]['name'] == 'Stalker' or enemies[i]['name'] == 'Tank' or enemies[i]['name'] == 'Critter' then
                enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
                enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
            elseif enemies[i]['name'] == 'Gunner' or enemies[i]['name'] == 'Sniper' or enemies[i]['name'] == 'Machine Gunner' or
            enemies[i]['name'] == 'Bomber' or enemies[i]['name'] == 'Sprayer' then

                --shoot and reload bullets
                enemies[i]['gun']['timer'] = enemies[i]['gun']['timer'] + dt
                if not enemies[i]['gun']['reloading'] then
                    if enemies[i]['gun']['ammo'][1] > 0 then
                        if enemies[i]['gun']['timer'] >= enemies[i]['gun']['delay'] then
                            love.audio.stop(enemies[i]['gun']['audio'])
                            love.audio.play(enemies[i]['gun']['audio'])
                            table.insert(bullets, {enemies[i]['x'], enemies[i]['y'], enemies[i]['gun']['size'],
                            enemies[i]['gun']['speed'], angle, enemies[i]['colour'], enemies[i]['gun']['dmg'], false})
                            enemies[i]['gun']['timer'] = 0
                            enemies[i]['gun']['ammo'][1] = enemies[i]['gun']['ammo'][1] - 1
                        end
                    else
                        enemies[i]['gun']['reloading'] = true
                        enemies[i]['gun']['timer'] = 0
                    end
                elseif enemies[i]['gun']['reloading'] and enemies[i]['gun']['timer'] >= enemies[i]['gun']['reload'] then
                    enemies[i]['gun']['reloading'] = false
                    enemies[i]['gun']['ammo'][1] = enemies[i]['gun']['ammo'][2]
                else
                    if enemies[i]['name'] == 'Gunner' then
                        if math.sqrt((enemies[i]['x'] - player.x)^2 + (enemies[i]['y'] - player.y)^2) >= 350 then
                            enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
                            enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
                        end
                    elseif enemies[i]['name'] == 'Sniper' then
                        if math.sqrt((enemies[i]['x'] - player.x)^2 + (enemies[i]['y'] - player.y)^2) >= 500 then
                            enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
                            enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
                        elseif math.sqrt((enemies[i]['x'] - player.x)^2 + (enemies[i]['y'] - player.y)^2) <= 350
                        and enemies[i]['x'] > 20 and enemies[i]['x'] < window.x - 20 and enemies[i]['y'] > 20 
                        and enemies[i]['y'] < window.x - 20 then
                            enemies[i]['x'] = enemies[i]['x'] - math.cos(angle)*enemies[i]['speed']
                            enemies[i]['y'] = enemies[i]['y'] - math.sin(angle)*enemies[i]['speed']
                        end
                    else
                        enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
                        enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
                    end
                end
            elseif enemies[i]['name'] == 'Charger' then

                enemies[i]['chargetimer'] = enemies[i]['chargetimer'] + dt

                if not enemies[i]['charging'] then
                    if enemies[i]['chargetimer'] >= enemies[i]['cooldown'] then
                        enemies[i]['speed'] = enemies[i]['chargespeed']
                        enemies[i]['charging'] = true
                        enemies[i]['chargetimer'] = 0
                        enemies[i]['colour'] = {1, 1, 1}
                    else
                        enemies[i]['speed'] = enemies[i]['chargespeed']/5
                        enemies[i]['colour'] = {1, 102/255, 0}
                        enemies[i]['charging'] = false
                    end
                else
                    if enemies[i]['chargetimer'] >= enemies[i]['chargelenth'] then
                        enemies[i]['speed'] = enemies[i]['chargespeed']/5
                        enemies[i]['colour'] = {1, 102/255, 0}
                        enemies[i]['charging'] = false
                        enemies[i]['chargetimer'] = 0
                    else
                        enemies[i]['speed'] = enemies[i]['chargespeed']
                        enemies[i]['charging'] = true
                        enemies[i]['colour'] = {1, 1, 1}
                    end
                end

                enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
                enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
            elseif enemies[i]['name'] == 'Summoner' then
                enemies[i]['summon']['summontimer'] = enemies[i]['summon']['summontimer'] + dt

                if enemies[i]['summon']['summontimer'] >= enemies[i]['summon']['summondelay'] then
                    if enemies[i]['summon']['summontimer'] >= enemies[i]['summon']['summondelay'] + 2 then
                        love.audio.stop(enemies[i]['audio'])
                        love.audio.play(enemies[i]['audio'])
                        table.insert(enemies, {name = 'Critter', x = enemies[i]['x']-100, y = enemies[i]['y'], size = enemies[i]['summon']['size'],
                        speed = enemies[i]['summon']['speed'], colour = enemies[i]['colour'], flash = false, timer = 0, hp = 2, dmg = 1})
                        table.insert(enemies, {name = 'Critter', x = enemies[i]['x']+100, y = enemies[i]['y'], size = enemies[i]['summon']['size'],
                        speed = enemies[i]['summon']['speed'], colour = enemies[i]['colour'], flash = false, timer = 0, hp = 2, dmg = 1})
                        table.insert(enemies, {name = 'Critter', x = enemies[i]['x'], y = enemies[i]['y']+100, size = enemies[i]['summon']['size'],
                        speed = enemies[i]['summon']['speed'], colour = enemies[i]['colour'], flash = false, timer = 0, hp = 2, dmg = 1})

                        enemies[i]['summon']['summontimer'] = 0
                    end
                else
                    enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
                    enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
                end

            end

            --check int w player
            if not player.dashing then
                if math.sqrt((player.x-enemies[i]['x'])^2+(player.y-enemies[i]['y'])^2) - player.r <= enemies[i]['size'] then
                    player.hp = player.hp - enemies[i]['dmg']
                    player.flash = true
                    table.remove(enemies, i)
                end
            end
        else
            for _=1, 50 do table.insert(particles, {enemies[i]['x'], enemies[i]['y'], math.random(4, 6), math.random()*math.random(0.4, 1.8),
            math.random(0, 360), 15, enemies[i]['colour']}) end
            table.remove(enemies, i)
            love.audio.stop(audio.enemydead)
            love.audio.play(audio.enemydead)
            player.score = player.score + 1
        end
    end

    for i=#bullets, 1, -1 do
        if bullets[i][3] <= 0.1 then
            table.remove(bullets, i)
        elseif bullets[i][1] < 0 or bullets[i][1] > window.x or bullets[i][2] < 0 or bullets[i][2] > window.y then
            table.remove(bullets, i)
        else
            bullets[i][1] = bullets[i][1] + math.cos(bullets[i][5])*bullets[i][4]
            bullets[i][2] = bullets[i][2] + math.sin(bullets[i][5])*bullets[i][4]
            if bullets[i][8] then
                if bullets[i][9] then
                    if bullets[i][10] > 1 then bullets[i][4] = bullets[i][4]/bullets[i][10]
                    elseif bullets[i][4] >= 10 then bullets[i][4] = bullets[i][4]*bullets[i][10] end
                    bullets[i][3] = bullets[i][3]/bullets[i][10]
                end
                for k=1, #enemies do
                    if math.sqrt((enemies[k]['x']-bullets[i][1])^2+(enemies[k]['y']-bullets[i][2])^2) - bullets[i][3] <= enemies[k]['size'] then
                        enemies[k]['hp'] = enemies[k]['hp'] - bullets[i][7]
                        enemies[k]['flash'] = true
                        enemies[k]['timer'] = 0
                        love.audio.stop(audio.enemyhit)
                        love.audio.play(audio.enemyhit)
                        table.remove(bullets, i)
                        break
                    end
                end
            elseif not player.dashing then
                if math.sqrt((player.x-bullets[i][1])^2+(player.y-bullets[i][2])^2) - bullets[i][3] <= player.r then
                    player.hp = player.hp - bullets[i][7]
                    player.flash = true
                    table.remove(bullets, i)
                    break
                end
            end

        end
    end

    for i=#particles, 1, -1 do
        if particles[i][3] <= 0.5 then
            table.remove(particles, i)
        else
            particles[i][3] = particles[i][3] - particles[i][3]/particles[i][6]
            particles[i][1] = particles[i][1] + math.cos(particles[i][5])*particles[i][4]
            particles[i][2] = particles[i][2] + math.sin(particles[i][5])*particles[i][4]
        end
    end

    if player.hp <= 0 then
        return 'dead'
    elseif player.score % 20 == 0 and player.bought ~= player.score/20 then
        return 'buy'
    elseif player.score % 10 == 0 and player.score % 20 ~= 0 and player.passives+player.bought ~= player.score/10 then
        return 'passive' end
    if player.score == 100 then
        enemy.spawnwait = 10000000000000
        return 'boss fight'
    else
        return nil
    end
end

function game.draw()
    if player.score < 5 then
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.setFont(font.tutfont)
        love.graphics.printf('WASD to move around', 0, 100, window.x, 'center')
        love.graphics.printf('Shoot with right mouse, dash with left', 0, centre.y-200, 450, 'center')
        love.graphics.printf('Space to change weapons', centre.x+160, centre.y-150, 350, 'center')
        love.graphics.printf('R to reload', centre.x-100, window.y-200, 400, 'center')
    end


    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font.mainfont)
    love.graphics.print(player.current_weapon['name'], 20, window.y-200)
    local score = ''
    for i=0, player.hp - 0.5, 0.5 do
        if i == round(i, 0) then
            score = score..'<'
        else score = score..'3 ' end
    end
    love.graphics.print(score, 50, 50)

    love.graphics.setFont(font.smallfont)
    love.graphics.print(player.current_weapon['ammo'][1]..'/'
    ..player.current_weapon['ammo'][2], 20, window.y-100)
    love.graphics.print('max:'..player.current_weapon['ammo'][3], 120, window.y-100)

    if player.current_weapon['reloading'] then
        love.graphics.print('reloading', player.x-50, player.y-player.r-40)
    end

    love.graphics.setFont(font.scorefont)
    love.graphics.printf({{1, 1, 1, 0.1}, player.score}, 0, centre.y-300, window.x, 'center')

    for i=1, #bullets do
        if not bullets[i][8] then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('line', bullets[i][1], bullets[i][2], bullets[i][3]+2)
        end
        love.graphics.setColor(bullets[i][6][1], bullets[i][6][2], bullets[i][6][3])
        love.graphics.circle('fill', bullets[i][1], bullets[i][2], bullets[i][3])
    end

    if player.flash then love.graphics.setColor(1, 0, 0)
    else love.graphics.setColor(player.colour[1], player.colour[2], player.colour[3]) end
    love.graphics.circle('fill', player.x, player.y, player.r)

    for i=1, #enemies do
        if not enemies[i]['flash'] then
            love.graphics.setLineWidth(5)
            love.graphics.setColor(enemies[i]['colour'][1], enemies[i]['colour'][2], enemies[i]['colour'][3])
            love.graphics.circle('line', enemies[i]['x'], enemies[i]['y'], enemies[i]['size'])
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('line', enemies[i]['x'], enemies[i]['y'], enemies[i]['size'])
        end
    end

    for i=1, #particles do
        love.graphics.setColor(particles[i][7])
        love.graphics.circle('fill', particles[i][1], particles[i][2], particles[i][3])
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    if love.mouse.isDown(1) and not player.current_weapon['reloading'] then
        love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 10)
    elseif player.current_weapon['reloading'] then
        love.graphics.setFont(font.smallfont)
        love.graphics.print('X', love.mouse.getX()-10, love.mouse.getY()-10)
    else love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10) end
    
end

function game.mousepressed(x, y, button)
    if button == 1 then
        if not player.current_weapon['reloading'] and player.current_weapon['ammo'][1] > 0 and
        player.timer >= player.current_weapon['delay'] then

            if not player.current_weapon['name'] == 'shotgun' then
                love.audio.stop(player.current_weapon['audio'])
                love.audio.play(player.current_weapon['audio'])
            else love.audio.play(player.current_weapon['audio']) end

            player.timer = 0
            for _=1, player.current_weapon['bulletsfired'] do
                local speed, size = player.current_weapon['speed'], player.current_weapon['size']
                if player.current_weapon['name'] == 'shotgun' or
                player.current_weapon['name'] == 'double shotgun' or
                player.current_weapon['name'] == 'super shotgun' then
                    speed = math.random(speed-6, speed + 6)
                    size = math.random(size-10, size)
                end

                if player.current_weapon['name'] ~= 'flame thrower' then
                    local direction = math.atan((y-player.y)/(x-player.x))
                    if player.x > x then direction = direction + math.pi end
                    direction = direction + math.random(-player.current_weapon['spread'],
                    player.current_weapon['spread']) * math.pi/180

                    table.insert(bullets, {player.x, player.y, size,
                    speed, direction, player.current_weapon['colour'], player.current_weapon['dmg'], true,
                    player.current_weapon['decay'], player.current_weapon['decayrate']})
                else
                    for _=1, math.random(7, 14) do
                        local direction = math.atan((y-player.y)/(x-player.x))
                        if player.x > x then direction = direction + math.pi end
                        direction = direction + math.random(-player.current_weapon['spread'],
                        player.current_weapon['spread']) * math.pi/180

                        table.insert(bullets, {player.x, player.y, math.random(player.current_weapon['size'], player.current_weapon['size']+5),
                        math.random(speed-10, speed), direction, {math.random(), 0, 0}, player.current_weapon['dmg'], true, player.current_weapon['decay'],
                        player.current_weapon['decayrate']})
                    end
                end
            end

            player.current_weapon['ammo'][1] = player.current_weapon['ammo'][1] - player.current_weapon['bulletsfired']
        elseif player.current_weapon['ammo'][1] <= 0 then
            game.keypressed('r')
        end
    end
    if button == 2 and player.dashunlocked and player.dashtimer >= player.dashdelay then
        player.dashing = true
        local direction = math.atan((y-player.y)/(x-player.x))
        if player.x > x then direction = direction + math.pi end
        player.dashdirection = direction
        player.dashtimer = 0
    end
end

function game.keypressed(key)
    if key == 'r' and player.current_weapon['ammo'][1] < player.current_weapon['ammo'][2] and
    not player.current_weapon['reloading'] then
        love.audio.play(audio.reload)
        player.current_weapon['reloading'] = true
        player.current_weapon['timer'] = 0
    end
    if key == 'space' and #player.weapons > 1 then
        love.audio.stop(audio.switchweapons)
        love.audio.play(audio.switchweapons)
        if player.weapon_no == 1 then player.weapon_no = 2 else player.weapon_no = 1 end
    end
end

return game