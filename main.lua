function love.load()
  require "gamelogic"
  require "fighter"
  require "io"
  require "textbox"
  
  game = GameLogic:new()
  
  -- Init User Input
  inbox = textbox:new()
  
  -- Init Players
  p1 = Fighter:new()
  p1:initGraphics()
  p1.locked = 0
  
  p2 = Fighter:new()
  p2.control = "ai"
  p2.facing = "left"
  p2:initGraphics()
  p2.locked = 0
  

-- Load external files (ai timings)
  local a_file = io.open("assets/init_attack.txt", "r");
  init_attack = {}
  for line in a_file:lines() do
    table.insert(init_attack, line);
  end
  
  local c_file = io.open("assets/init_cost.txt", "r");
  preparation_cost = {}
  for line in c_file:lines() do
    table.insert(preparation_cost, line);
  end
  
  local s_file = io.open("assets/strat.txt","r");
  strat_dist = {}
  for line in s_file:lines() do
    table.insert(strat_dist, line);
  end
  
  --designate output file
  io.output("log.txt")
  
  -- create output tables
  player1_strike = {}
  player1_block = {}
  player2_strike = {}
  player2_block = {}
  player1_win = {}

  -- Function for counting length of a table, may be useful for setting the initial attack randomly with different length files
  function tablelength(T) -- get the length of a table
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
  
  preparation_cost.__len = tablelength(preparation_cost)
  
  -- initialize ai times
  p2.reaction_time = preparation_cost[1]
  game.fighter1 = p1
  game.fighter2 = p2
  
end

function love.keypressed(key) 
  -- Process key presses during a trial
  if game.state == "input" then
    if key == "return" then
      inbox.answer = true
      -- Random Seed for AI attack inits
      seed = math.randomseed(inbox.text) -- Currently controlled for testing
      p2.strike_times  = init_attack[math.random(1,1000)] -- hard-coded to assume that 1000 init_attack times are provided
    end
  elseif game.state == "intro" then
    if key == "space" then
      game:nextTrial()
    end
    
  elseif game.state == "trial" then
    if key == "right" then
      p1:strikePressed(dt)
      p1.strikeTime = game.trialTime
      player1_strike[game.trialNumber] = p1.strikeTime
      player1_block[game.trialNumber] = 9999
      
    elseif key == "left" then
      p1:blockPressed(dt)
      p1.blockTime = game.trialTime
      player1_strike[game.trialNumber] = 9999
      player1_block[game.trialNumber] = p1.blockTime
    end
  end
  
end

function love.update(dt)
  game:update(dt)
  game:fighterUpdate(dt)
  game:ai_state(dt)
  p1:update(dt)
  p2:update(dt)
  
end


function love.draw()
  game:draw()
  p1:draw()
  p2:draw()

--[[
love.graphics.print("p1.state = " .. p1.state, 330, 300 )

love.graphics.print("p1.animationTime = " .. p1.animationTime, 330, 320 )
love.graphics.print("p1.currentFrame = " .. p1.currentFrame,  330, 340 )
love.graphics.print("p1.facing = " .. p1.facing,  330, 360 )

love.graphics.print("p2.state = " .. p2.state, 700, 300 )
love.graphics.print("p2.animationTime = " .. p2.animationTime, 700, 320 )
love.graphics.print("p2.currentFrame = " .. p2.currentFrame,  700, 340 )
love.graphics.print("p2.facing = " .. p2.facing,  700, 360 )
--]]
end