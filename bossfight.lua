local bossfight = {}

Timer = require 'hump.chrono.Timer'

function bossfight.init()
    boss = {}
    boss.pos = {x=centre.x, y=centre.y, r=100}
    boss.colour = {0, 0.2, 1}
    boss.hp = 800
    boss.flash = false
    boss.flashtimer = 0

    attack = {}
    attack[1] = {timer = 0, angle = 0, interval = 0.05, bullets = 0}
    attack[2] = {timer = 0, chargelength = 3, charging = false, speed = 4, attacks = 0}
    attack[3] = {angle = 0, timer = 0, interval = 0.1, bullets = 0}
    attack[4] = {timer = 0, summoned = 0, interval = 0.5}
    attack[5] = {timer = 0, angle = 0, interval = 0.5, bullets = 0}

    font = {}
    font.mainfont = love.graphics.newFont('mainfont.ttf', 40)
    font.smallfont = love.graphics.newFont('mainfont.ttf', 20)
    font.tinyfont = love.graphics.newFont('mainfont.ttf', 5)
    font.scorefont = love.graphics.newFont('mainfont.ttf', 500)

    audio.bossfight = love.audio.newSource('audio/bossfight!.mp3', 'static')
    audio.bossgun = love.audio.newSource('audio/bossshoot.wav', 'static')
    audio.bossfight:setLooping(true)
    audio.bossfight:setVolume(0.3)
    love.audio.stop()
    love.audio.play(audio.bossfight)

    attacked = {1, 1}
    timer = Timer()

    current = 0
    attacking = false
    canattack = true

    bullets = {}

    enemies = {}


end

function newattack()
    current = math.random(1, #attack)
    while current == attacked[#attacked-1] or current == attacked[#attacked] do
        current = math.random(1, #attack)
    end
    table.insert(attacked, current)
    if current ~= 2 and boss.pos ~= {x = centre.x, y = centre.y, r = 100} then
        timer:tween(2, boss.pos, {x = centre.x, y = centre.y, r = 100}, 'linear')
        timer:after(2, function () canattack = true end)
    else canattack = true end
end

function bossfight.update(dt)
    timer:update(dt)
    player.timer = player.timer + dt
    player.dashtimer = player.dashtimer + dt
    player.current_weapon = player.weapons[player.weapon_no]

    if love.mouse.isDown(1) and player.current_weapon['auto'] and not player.current_weapon['reloading'] then
        love.audio.stop(player.current_weapon['audio'])
        love.audio.stop(player.current_weapon['audio'])
        bossfight.mousepressed(love.mouse.getX(), love.mouse.getY(), 1)
    end

    if canattack then
        if current == 1 then attacking = bulletspin(dt)
        elseif current == 2 then attacking = chargeattack(dt)
        elseif current == 3 then attacking = spinningbullets(dt)
        elseif current == 4 then attacking = summonattack(dt)
        elseif current == 5 then attacking = circlebullets(dt) end
        if not attacking then
            canattack = false
            timer:after(3, function () bullets, enemies = {}, {} end)
            attacking = true
            timer:after(2, newattack)
        end
    end

    if player.current_weapon['reloading'] then
        player.current_weapon['timer'] = player.current_weapon['timer'] + dt
    end

    if love.keyboard.isDown('space') then boss.hp = boss.hp - 1 end

    if not player.dashing then
        if love.keyboard.isDown('a') and player.x > 0 then player.x = player.x - player.speed end
        if love.keyboard.isDown('d') and player.x < window.x then player.x = player.x + player.speed end
        if love.keyboard.isDown('w') and player.y > 0 then player.y = player.y - player.speed end
        if love.keyboard.isDown('s') and player.y < window.y then player.y = player.y + player.speed end
    elseif player.dashing and player.dashtimer < player.dashlength then
        if player.x > 40 and player.x < window.x -40 then player.x = player.x + math.cos(player.dashdirection)*40 end
        if player.y > 40 and player.y < window.y - 40 then player.y = player.y + math.sin(player.dashdirection)*40 end
    else player.dashing = false end

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

            enemies[i]['x'] = enemies[i]['x'] + math.cos(angle)*enemies[i]['speed']
            enemies[i]['y'] = enemies[i]['y'] + math.sin(angle)*enemies[i]['speed']
            --check int w player
            if not player.dashing then
                if math.sqrt((player.x-enemies[i]['x'])^2+(player.y-enemies[i]['y'])^2) - player.r <= enemies[i]['size'] then
                    player.hp = player.hp - enemies[i]['dmg']
                    player.flash = true
                    table.remove(enemies, i)
                end
            end
        else
            player.hp = player.hp + 0.1
            table.remove(enemies, i)
            love.audio.stop(audio.enemydead)
            love.audio.play(audio.enemydead)
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
            if not player.dashing and not bullets[i][8] then
                if math.sqrt((player.x-bullets[i][1])^2+(player.y-bullets[i][2])^2) - bullets[i][3] <= player.r then
                    player.hp = player.hp - bullets[i][7]
                    player.flash = true
                    table.remove(bullets, i)
                    break
                end
            end
        end
    end

    for i=#bullets, 1, -1 do
        if bullets[i][8] then
            if bullets[i][9] then
                if bullets[i][10] > 1 then bullets[i][4] = bullets[i][4]/bullets[i][10]
                elseif bullets[i][4] >= 10 then bullets[i][4] = bullets[i][4]*bullets[i][10] end
                bullets[i][3] = bullets[i][3]/bullets[i][10]
            end
            if math.sqrt((boss.pos['x']-bullets[i][1])^2+(boss.pos['y']-bullets[i][2])^2) - bullets[i][3] <= boss.pos['r'] then
                boss['hp'] = boss['hp'] - bullets[i][7]
                boss['flash'] = true
                boss['flashtimer'] = 0
                table.remove(bullets, i)
                break
            else
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
            end
        end
    end

    if boss.hp <= 0 then return 'win'
    elseif player.hp <= 0 then return 'dead' end

end

function bossfight.draw()

    local score = ''
    for i=0, player.hp - 0.5, 0.5 do
        if i == round(i, 0) then
            score = score..'<'
        else score = score..'3 ' end
    end
    love.graphics.printf(score,0 , 0, 150, 'center')


    love.graphics.setFont(font.mainfont)
    love.graphics.print(player.current_weapon['name'], 20, window.y-200)

    love.graphics.setColor(boss.colour[1], boss.colour[2], boss.colour[3])
    love.graphics.setLineWidth(10)
    love.graphics.circle('line', boss.pos.x, boss.pos.y, boss.pos.r)

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', centre.x-400, 30, boss.hp, 50)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', centre.x-400, 30, boss.hp, 50)

    love.graphics.print('THE KILLER', centre.x-100, 120)

    love.graphics.setFont(font.smallfont)
    love.graphics.print(player.current_weapon['ammo'][1]..'/'
    ..player.current_weapon['ammo'][2], 20, window.y-100)
    love.graphics.print('max:'..player.current_weapon['ammo'][3], 120, window.y-100)

    if player.current_weapon['reloading'] then
        love.graphics.print('reloading', player.x-50, player.y-player.r-40)
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

    for i=1, #bullets do
        if not bullets[i][8] then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('line', bullets[i][1], bullets[i][2], bullets[i][3]+2)
        end
        love.graphics.setColor(bullets[i][6][1], bullets[i][6][2], bullets[i][6][3])
        love.graphics.circle('fill', bullets[i][1], bullets[i][2], bullets[i][3])
    end

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

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', player.x, player.y, player.r)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    if love.mouse.isDown(1) and not player.current_weapon['reloading'] then
        love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 10)
    elseif player.current_weapon['reloading'] then
        love.graphics.setFont(font.smallfont)
        love.graphics.print('X', love.mouse.getX()-10, love.mouse.getY()-10)
    else love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10) end
end

function playeffect()
    love.audio.stop(audio.bossgun)
    love.audio.play(audio.bossgun)
end

function bossfight.mousepressed(x, y, button)
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
            bossfight.keypressed('r')
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

function bossfight.keypressed(key)
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


function bulletspin(dt)
    attack[1].timer = attack[1].timer + dt
    attack[1].angle = attack[1].angle + 0.1

    if attack[1].timer >= attack[1].interval then
        playeffect()
        table.insert(bullets, {centre.x, centre.y, 5, 8, attack[1].angle, {0, 0.2, 0.7}, 0.5, false})
        attack[1].timer = 0
        attack[1].bullets = attack[1].bullets + 1
        if attack[1].bullets >= 100 and attack[1].bullets <= 200 then
            table.insert(bullets, {centre.x, centre.y, 5, 8, attack[1].angle+math.pi, {0, 0.2, 0.7}, 0.5, false})
        elseif attack[1].bullets > 200 then
            table.insert(bullets, {centre.x, centre.y, 5, 8, attack[1].angle+math.pi, {0, 0.2, 0.7}, 0.5, false})
            table.insert(bullets, {centre.x, centre.y, 15, 12, attack[1].angle+45, {1, 0.6, 0.2}, 2, false})
        end
    end
    if attack[1].bullets >= 300 then attack[1] = {timer = 0, angle = 0, interval = 0.05, bullets = 0}; return false
    else return true end
end

function chargeattack(dt)
    attack[2].timer = attack[2].timer + dt

    local angle = math.atan((player.y-boss.pos['y'])/(player.x-boss.pos['x']))
    if player.x < boss.pos['x'] then angle = angle + math.pi end

    boss.pos['x'] = boss.pos['x'] + math.cos(angle)*attack[2]['speed']
    boss.pos['y'] = boss.pos['y'] + math.sin(angle)*attack[2]['speed']

    if attack[2].timer >= attack[2].chargelength and not attack[2].charging then
        attack[2].charging = true
        attack[2].timer = 0
        attack[2].speed = 10
    elseif attack[2].timer >= attack[2].chargelength and attack[2].charging then
        attack[2].charging = false
        attack[2].timer = 0
        attack[2].speed = 4
        attack[2].attacks = attack[2].attacks + 1
        if attack[2].attacks <= 2 then
            playeffect()
            for _=1, math.random(10, 15) do
                table.insert(bullets, {boss.pos['x'], boss.pos.y, math.random(2, 7), math.random()*math.random(14, 18),
                math.random(angle-15, angle + 15), {0.2, 0, 0.8}, 1, false})
            end
        elseif attack[2].attacks <= 4 then
            playeffect()
            for _=1, math.random(35, 65) do
                table.insert(bullets, {boss.pos['x'], boss.pos.y, math.random(2, 7), math.random()*math.random(14, 18),
                math.random(angle-15, angle + 15), {0.2, 0, 0.8}, 0.5, false})
            end
        elseif attack[2].attacks > 4 then
            playeffect()
            for _=1, math.random(35, 65) do
                table.insert(bullets, {boss.pos['x'], boss.pos.y, math.random(2, 7), math.random()*math.random(14, 18),
                math.random(angle-15, angle + 15), {0.2, 0, 0.8}, 0.5, false})
            end
            for i=0, 5 do
                table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 4, i*45, {1, 0.6, 0.2}, 4, false})
            end
        end
    end

    if attack[2].attacks >= 7 then attack[2] = {timer = 0, chargelength = 3, charging = false, speed = 4, attacks = 0}; return false
    else return true end
end

function spinningbullets(dt)
    attack[3].timer = attack[3].timer + dt

    if attack[3].timer >= attack[3].interval then
        playeffect()
        for i=0, 5 do
            table.insert(bullets, {boss.pos.x, boss.pos.y, 5, 12, i*45+attack[3].angle, {0, 0.7, 0.2}, 3, false})
        end
        attack[3].timer = 0
        attack[3].bullets = attack[3].bullets + 1
        attack[3].angle = attack[3].angle + 20
        if attack[3].bullets >= 50 and attack[3].bullets % 2 == 0 then
            local angle = math.atan((player.y-boss.pos['y'])/(player.x-boss.pos['x']))
            if player.x < boss.pos['x'] then angle = angle + math.pi end
            playeffect()
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 5, angle, {1, 0.6, 0.2}, 2, false})
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 5, angle+math.pi/2, {1, 0.6, 0.2}, 2, false})
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 5, angle-math.pi/2, {1, 0.6, 0.2}, 2, false})
        end
    end

    if attack[3].bullets >= 100 then attack[3] = {angle = 0, timer = 0, interval = 0.1, bullets = 0}; return false
    else return true end
end

function summonattack(dt)
    attack[4].timer = attack[4].timer + dt

    local angle = math.atan((player.y-boss.pos['y'])/(player.x-boss.pos['x']))
    if player.x < boss.pos['x'] then angle = angle + math.pi end


    if attack[4].timer >= attack[4].interval then
        love.audio.stop(love.audio.newSource('audio/summoner.wav', 'static'))
        love.audio.play(love.audio.newSource('audio/summoner.wav', 'static'))
        attack[4].timer = 0
        attack[4].summoned = attack[4].summoned + 1
        table.insert(enemies, {x = boss.pos.x-120, y = boss.pos.y, size = math.random(8, 12),
        speed = 5, colour = {0.7, 0.1, 0.5}, flash = false, timer = 0, hp = 2, dmg = 1})
        if attack[4].summoned >= 10 and attack[4].summoned <= 20 then
            table.insert(enemies, {x = boss.pos.x+120, y = boss.pos.y, size = math.random(8, 12),
            speed = 5, colour = {0.7, 0.1, 0.5}, flash = false, timer = 0, hp = 2, dmg = 1})
        end
        if attack[4].summoned > 20 then
            table.insert(enemies, {x = boss.pos.x+120, y = boss.pos.y-120, size = math.random(8, 12),
            speed = 5, colour = {0.7, 0.1, 0.5}, flash = false, timer = 0, hp = 2, dmg = 1})
        end
        if attack[4].summoned >= 30 then
            playeffect()
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 4, angle, {1, 0.6, 0.2}, 2, false})
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 4, angle+math.pi, {1, 0.6, 0.2}, 2, false})
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 4, angle+math.pi/2, {1, 0.6, 0.2}, 2, false})
            table.insert(bullets, {boss.pos.x, boss.pos.y, 15, 4, angle-math.pi/2, {1, 0.6, 0.2}, 2, false})
        end
    end

    if attack[4].summoned >= 50 then attack[4] = {timer = 0, summoned = 0, interval = 0.5}; return false
    else return true end
end

function circlebullets(dt)
    attack[5].timer = attack[5].timer + dt

    attack[5].angle = attack[5].angle + 1

    local angle = math.atan((player.y-boss.pos['y'])/(player.x-boss.pos['x']))
    if player.x < boss.pos['x'] then angle = angle + math.pi end

    if attack[5].timer >= attack[5].interval then
        attack[5].timer = 0
        attack[5].bullets = attack[5].bullets + 1
        playeffect()
        for i=0, 13 do
            table.insert(bullets, {centre.x, centre.y, 15, 12, i*30*(math.pi/180), {1, 0.6, 0.2}, 2, false})
        end
        if attack[5].bullets >= 10 then
            playeffect()
            for i=0, 13 do
                table.insert(bullets, {centre.x, centre.y, 15, 8, i*30*(math.pi/180)-10*(math.pi/180), {1, 0.1, 0.2}, 2, false})
            end
        end
        if attack[5].bullets >= 20 then
            playeffect()
            table.insert(bullets, {centre.x, centre.y, 6, 4, angle, {0, 0.2, 0.7}, 2, false})
        end
    end

    if attack[5].bullets >= 30 then attack[5] = {timer = 0, angle = 0, interval = 0.5, bullets = 0}; return false
    else return true end
end

return bossfight