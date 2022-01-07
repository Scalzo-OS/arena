local passives = {}

function passives.init()

    if player.score == 10 then toget = 1
    elseif player.score == 30 then toget = 2
    elseif player.score == 50 then toget = 3
    elseif player.score == 70 then toget = 4
    elseif player.score == 90 then toget = 5 end

    upgraded = {}

    passives = {{name = 'Health Upgrade', desc = 'more health', upgrade = 'health'},
    {name = 'More Ammo', desc = 'bigger ammo storages', upgrade = 'ammo'}, {name = 'Speed Upgrade', desc = 'faster movement', upgrade = 'speed'},
    {name = 'Shorter Reload', desc = 'faster reload', upgrade = 'reload'}, {name = 'Faster Dash', desc = 'less wait for dash', upgrade = 'dash'},
    {name = 'Damage', desc = 'more damage', upgrade = 'damage'}, {name = 'Size Upgrade', desc = 'smaller', upgrade = 'size'},
    {name = 'Bullet Size', desc = 'bigger bullets', upgrade = 'bullet'}, {name = 'Clip Size', desc = 'more ammo per reload', upgrade = 'clip'},
    {name = 'Dash Duration', desc = 'longer dashes', upgrade = 'dashduration'}, {name = 'More Accurate', desc = 'less spread', upgrade = 'spread'}}

    font = {}
    font.upgradefont = love.graphics.newFont('mainfont.ttf', 80)
    font.titlefont = love.graphics.newFont('mainfont.ttf', 50)
    font.descfont = love.graphics.newFont('mainfont.ttf', 25)

    local a, nums = 0, {}
    for _=1, 4 do a = math.random(1, #passives); while intable(nums, a) do a = math.random(1, #passives) end table.insert(nums, a) end

    upgrading = true

    CurrentShop = {passives[nums[1]], passives[nums[2]], passives[nums[3]], passives[nums[4]]}

    box = {}
    box[1] = {centre.x/3-centre.x/10, centre.y/2, centre.x-centre.x/3, (centre.y+centre.y/3)/2}
    box[2] = {centre.x+centre.x/8-centre.x/10, centre.y/2, centre.x-centre.x/3, (centre.y+centre.y/3)/2}
    box[3] = {centre.x/3-centre.x/10, centre.y/2 + (centre.y+centre.y/3)/2 + centre.y/8, centre.x-centre.x/3, (centre.y+centre.y/3)/2}
    box[4] = {centre.x+centre.x/8-centre.x/10, centre.y/2 + (centre.y+centre.y/3)/2 + centre.y/8, centre.x-centre.x/3, (centre.y+centre.y/3)/2}

    mouseinfo = {}
    mouseinfo.hovering = {false, false, false, false}
end

function resetpassives()
    passives = {{name = 'Health Upgrade', desc = 'more health', upgrade = 'health'},
    {name = 'More Ammo', desc = 'bigger ammo storages', upgrade = 'ammo'}, {name = 'Speed Upgrade', desc = 'faster movement', upgrade = 'speed'},
    {name = 'Shorter Reload', desc = 'faster reload', upgrade = 'reload'}, {name = 'Faster Dash', desc = 'less wait for dash', upgrade = 'dash'},
    {name = 'Damage', desc = 'more damage', upgrade = 'damage'}, {name = 'Size Upgrade', desc = 'smaller', upgrade = 'size'},
    {name = 'Bullet Size', desc = 'bigger bullets', upgrade = 'bullet'}, {name = 'Clip Size', desc = 'more ammo per reload', upgrade = 'clip'},
    {name = 'Dash Duration', desc = 'longer dashes', upgrade = 'dashduration'}, {name = 'More Accurate', desc = 'less spread', upgrade = 'spread'}}

    local a, nums = 0, {}
    for _=1, 4 do a = math.random(1, #passives); while intable(nums, a) do a = math.random(1, #passives) end table.insert(nums, a) end

    CurrentShop = {passives[nums[1]], passives[nums[2]], passives[nums[3]], passives[nums[4]]}

    mouseinfo = {}
    mouseinfo.hovering = {false, false, false, false}
end

function intable(set, key)
    local intab = false
    for i=1, #set do if set[i] == key then intab = true end end
    return intab
end

function CheckInt(m, obj)
    local mx, my = m[1], m[2]
    local x, y, w, h = obj[1], obj[2], obj[3], obj[4]
    if mx < x + w and mx > x and my < y + h and my > y then
        return true
    else return false end
end

function passives.update(dt)
    for i=1, #box do
        if CheckInt({love.mouse.getPosition()}, box[i]) then
            mouseinfo.hovering[i] = true
        else mouseinfo.hovering[i] = false end
    end

    return upgrading
end

function passives.draw()
    love.graphics.setFont(font.upgradefont)
    if toget == 1 then love.graphics.printf('GET A NEW PASSIVE', 0, 100, window.x, 'center')
    else love.graphics.printf('GET '..toget..' NEW PASSIVES', 0, 100, window.x, 'center') end

    love.graphics.setFont(font.titlefont)
    love.graphics.printf(CurrentShop[1]['name'], box[1][1], box[1][2]+30, box[1][3], 'center')
    love.graphics.printf(CurrentShop[2]['name'], box[2][1], box[2][2]+30, box[2][3], 'center')
    love.graphics.printf(CurrentShop[3]['name'], box[3][1], box[3][2]+30, box[3][3], 'center')
    love.graphics.printf(CurrentShop[4]['name'], box[4][1], box[4][2]+30, box[4][3], 'center')

    love.graphics.setFont(font.descfont)
    love.graphics.printf(CurrentShop[1]['desc'], box[1][1], box[1][2]+140, box[1][3], 'center')
    love.graphics.printf(CurrentShop[2]['desc'], box[2][1], box[2][2]+140, box[2][3], 'center')
    love.graphics.printf(CurrentShop[3]['desc'], box[3][1], box[3][2]+140, box[3][3], 'center')
    love.graphics.printf(CurrentShop[4]['desc'], box[4][1], box[4][2]+140, box[4][3], 'center')

    love.graphics.printf('Current level: '..player.modifiers[CurrentShop[1]['upgrade']], box[1][1], box[1][2]+220, box[1][3], 'center')
    love.graphics.printf('Current level: '..player.modifiers[CurrentShop[2]['upgrade']], box[2][1], box[2][2]+220, box[2][3], 'center')
    love.graphics.printf('Current level: '..player.modifiers[CurrentShop[3]['upgrade']], box[3][1], box[3][2]+220, box[3][3], 'center')
    love.graphics.printf('Current level: '..player.modifiers[CurrentShop[4]['upgrade']], box[4][1], box[4][2]+220, box[4][3], 'center')

    love.graphics.rectangle('line', box[1][1], box[1][2], box[1][3], box[1][4])
    love.graphics.rectangle('line', box[2][1], box[2][2], box[2][3], box[2][4])
    love.graphics.rectangle('line', box[3][1], box[3][2], box[3][3], box[3][4])
    love.graphics.rectangle('line', box[4][1], box[4][2], box[4][3], box[4][4])

    love.graphics.setFont(font.upgradefont)
    for i=1, #mouseinfo.hovering do if mouseinfo.hovering[i] then
        if i==1 or i == 3 then
            love.graphics.print('->', box[i][1]-centre.x/5, box[i][2]+box[i][4]/3)
        else
            love.graphics.print('<-', box[i][1]+box[i][3]+centre.x/10, box[i][2]+box[i][4]/3)
        end
    end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    if love.mouse.isDown(1) then
        love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 10)
    else love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), 10) end
end

function passives.mousepressed(x, y)
    for i=1, #box do
        if CheckInt({x, y}, box[i]) then
            player.modifiers[CurrentShop[i]['upgrade']] = player.modifiers[CurrentShop[i]['upgrade']] + 1
            table.insert(upgraded, CurrentShop[i]['upgrade'])
        end
    end
    toget = toget - 1
    if toget == 0 then upgrading = false; player.passives = player.passives + 1 else resetpassives() end
end

return passives