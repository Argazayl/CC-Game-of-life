--nahodim monitor
monitor = peripheral.find("monitor")
--podckluchaem vivod terminala k monitoru
--chtobi ispol'zovat' paintutils
term.redirect(monitor)
term.clear()

--risuet ekran
function draw_pixels(matrix)
    
    for w, i in pairs(matrix) do
        for h, v in pairs(i) do
           if v == 1 then
               paintutils.drawPixel(w, h, colors.red) 
           elseif v == 0 then
               paintutils.drawPixel(w, h, colors.white)
           end
        end
    end
end

--schitaet sosedei i vozvrashaet rezultat
function death_birth(matrix, x, y, max_x, max_y)
    
    --uznaem znachenie targeta
    state = matrix[x][y]
    
    --na granice znachenya perehodyat
    if x == 1 then
        left = max_x
        right = x + 1
    elseif x == max_x then
        left = x - 1
        right = 1
    else
        left = x - 1
        right = x + 1
    end
    
    if y == 1 then
        top = max_y
        bottom = y + 1
    elseif y == max_y then
        top = y -1
        bottom = 1
    else
        top = y - 1
        bottom = y + 1
    end
    
    --podschet sosedei
    sosedi = 
    matrix[left][top]      + matrix[x][top]    + matrix[right][top]
    + matrix[left][y]                          + matrix[right][y]
    + matrix[left][bottom] + matrix[x][bottom] + matrix[right][bottom]
    
    if state == 0 then --kletka mertva
        
        if sosedi == 3 then
            return 1 --rodilsya
        else
            return 0 --ne rodilsya
        end
    elseif state == 1 then --kletka zhiva
        
        if sosedi == 2 or sosedi == 3 then
            return 1 --ostalsya ziv
        else
            return 0 --vmer
        end
    end
    
end

--sozdaet massiv razmerom s ekran polnost'u iz nuley
function matrix_zero()
    local matrix = {}
    local w, h = term.getSize()
    for i = 1, w do
        matrix[i] = {}
        for v = 1, h do
            table.insert(matrix[i], 0)
        end
    end
    return matrix
end

--delaet glubokoe kopirovanie matrici
--chobi izbezhat' ssilok na postoyannie
function deep_copy(matrix)
    local copy = {}
    for i = 1, #matrix do
        copy[i] = {}
        for j = 1, #matrix[i] do
            copy[i][j] = matrix[i][j]
        end
    end
    return copy
end

--poluchaem razmeri monitora
local w, h = term.getSize()

--sozdaem nulevie matrici razmerom s ekran
past_state = matrix_zero()
present_state = matrix_zero()
future_state = matrix_zero()


step = 0
--chernyi' text viden na belom i krasnom
term.setTextColor(colors.black)


draw_zero = true
--risuem nachalnoe polozhenie
while draw_zero do

draw_pixels(present_state)
paintutils.drawPixel(w, h, colors.black)
    
    --poluchaem koordinati klika po ekranu
    event, side, xpos, ypos = os.pullEvent("monitor_touch")
    --esli klik ne po chernomu pixelu
    if xpos ~= w or ypos ~= h then
        --invertiruem sostoyanie pixelya
        if present_state[xpos][ypos] == 0 then
            present_state[xpos][ypos] = 1
        elseif present_state[xpos][ypos] == 1 then
            present_state[xpos][ypos] = 0
        end
    else
        draw_zero = false
    end

end

--glavni' cikl
while true do
    game_end = true
    
    --sozdaem sleduushuu iteraciu po pravilu
    for x, y_container in pairs(present_state) do
        for y, _ in pairs(y_container) do
            future_state[x][y] = death_birth(present_state, x, y, w, h)
            --proverka na stacionari
            if future_state[x][y] ~= past_state[x][y] then
                game_end = false
            end
        end
    end
    
    --delaem glubokoe kopirovanie
    past_state = deep_copy(present_state)
    present_state = deep_copy(future_state)
    
    --otrisovka ekrana
    draw_pixels(present_state)
    
    --podschet shagov
    step = step + 1
    term.setCursorPos(1,1)
    term.write(step)
    
    --okonchanie cikla
    if game_end then
        term.write(" !END!")
        return
    end
    
    sleep(0.1)
end
