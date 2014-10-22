function randomize(min, max)
  local i, rnd
  local t = {}
  for i = min, max, 1 do
    t[#t + 1] = i
    t[#t + 1] = i
  end
  local t2 = {}
  while #t > 0 do
    rnd = love.math.random(1, #t)
    t2[#t2 + 1] = t[rnd]
    table.remove(t, rnd)
  end
  return t2
end

function hide_all()
  local i
  for i = 1, num_images, 1 do
    if not images[i]["solved"] then
      images[i]["hidden"] = true
    end
  end
end

function count_unhidden()
  local count = 0
  local i
  for i = 1, num_images, 1 do
    if not images[i]["hidden"] then
      if not images[i]["solved"] then
        count = count + 1
      end
    end
  end
  return count
end

function count_solved()
  local count = 0
  local i
  for i = 1, num_images, 1 do
    if images[i]["solved"] then
      count = count + 1
    end
  end
  return count
end

function solution()
  local a = nil
  local b = nil
  local count = 0
  for i = 1, num_images, 1 do
    if not images[i]["solved"] then
      if not images[i]["hidden"] then
        if a then
          b = i
        else
          a = i
        end
      end
    end
    count = count + 1
  end

  if a and b and images[a]["value"] == images[b]["value"] then
    images[a]["solved"] = true
    images[b]["solved"] = true
  else
    a = nil
  end

  return a, b
end

function game_won()
  return count_solved() == num_images
end

function print_centered(text)
  love.graphics.printf(text, 0, (win_size/2)-(font_size/2), win_size, 'center')
end

function print_debug(text)
  if DEBUG then
    print(text)
  end
end

function love.load()
  DEBUG = false
  num_images = 16
  grid_size = 4
  hide_timeout = 1
  imgw = 75
  imgh = 75
  font_size = 20

  images = {}

  local img_margin = 20
  local a, b, i, j, x, y
  local imgx = img_margin
  local imgy = img_margin

  local randomized = randomize(1, (num_images/2))
  print_debug("### " .. #randomized)

  for a, b in ipairs(randomized) do
    print_debug(a .. ":" .. b)
  end

  for i = 1, num_images, 1 do
    images[#images+1] = {
      back = love.graphics.newImage("assets/back.jpg"),
      img = love.graphics.newImage("assets/0" .. randomized[i] .. ".jpg"),
      value = randomized[i],
      x = 0,
      y = 0,
      hidden = true,
      solved = false,
    }
    print_debug("i " .. i .. "# " .. #images)
  end

  local counter = 1
  for i = 1, (num_images / grid_size), 1 do
    for j = 1, (num_images / grid_size), 1 do
      x = imgx + (j-1) * ( img_margin + imgh )
      y = imgy + (i-1) * ( img_margin + imgw )
      images[counter]["x"] = x
      images[counter]["y"] = y
      counter = counter + 1
    end
  end

  win_size = (grid_size * (imgw + img_margin)) + img_margin
  local win_flags = {resizable = false}
  local font = love.graphics.newFont(font_size)
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(50, 50, 50)
  love.window.setMode(win_size, win_size, win_flags)

  timepassed = 0
  next_hide = 0
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end

function love.update(dt)
  timepassed = timepassed + dt
  if next_hide > 0 and next_hide < timepassed then
    hide_all()
    next_hide = timepassed -1
  end
end

function love.draw()
  if game_won() then
    print_centered("You won!")
  else
    local counter = 1
    local i, j, source
    for i = 1, num_images / grid_size, 1 do
      for j = 1, num_images / grid_size, 1 do
        if images[counter]["hidden"] then
          source = "back"
        else
          source = "img"
        end
        love.graphics.draw(images[counter][source], images[counter]["x"], images[counter]["y"])
        counter = counter + 1
      end
    end
  end
end

function love.mousepressed(x, y, button)
  if not game_won() and button == "l" then
    local i, unhidden
    for i = 1, num_images, 1 do
      if x >= images[i]["x"] and x <= images[i]["x"]+imgw then
        if y >= images[i]["y"] and y <= images[i]["y"]+imgh then
          print_debug("Clicked on image number " .. i .. " = " .. images[i]["x"] .. "/" .. images[i]["y"])
          print_debug("value:" .. images[i]["value"])
          unhidden = count_unhidden()
          if unhidden < 1 then
            images[i]["hidden"] = false
            next_hide = -1
          elseif unhidden < 2 then
            images[i]["hidden"] = false
            next_hide = timepassed + hide_timeout

            local a, b = solution()
            if a and b then
              print_debug("solution!")
              images[a]["solved"] = true
              images[b]["solved"] = true
            end
          else
            next_hide = timepassed + hide_timeout
          end
        end
      end
    end
  end
end
