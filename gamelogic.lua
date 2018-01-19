require "math"

GameLogic = {
   p2_type="ai", state="input", trialTime=0.0, globalTime=0.0, 
   trialTimeout=5.0, trialNumber=0, timeoutDuration=1.0, maxTrials = 2, fighter1=nil, fighter2=nil,
   }


function GameLogic:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end 

function GameLogic:update(dt)
  local t = self.trialTime
  t = t + dt
 
  if self.state == "trial" then
    -- Is there a timeout?
    if t > self.trialTimeout then
      if not p1.state == dead and not p2.state == dead then
        player1_win[self.trialNumber] = 0
      end
      self.state = "timeout"
      self.trialTime = 0.0
      p1.state = "idle"
      p2.state = "idle"
      p1.currentFrame = 1
      p2.currentFrame = 1
      
    else
      self.trialTime = t
    end
    
  elseif self.state == "timeout" then
      
    if t > self.timeoutDuration then
      self:nextTrial()
    else
      self.trialTime = t
    end
  
  end

end

function GameLogic:ai_state(dt)
  local t = self.trialTime
  t = t + dt
  
  if self.state == "trial" then
  ------------------------------ AI Actions --------------------------------------------------
    if p2.control == "ai" then
      rt_ind = math.ceil(1000*self.trialTime/p2.strike_times)
      if rt_ind >= 1 and rt_ind <= preparation_cost.__len then
        p2.reaction_time = preparation_cost[rt_ind] -- calculate ai prep cost from player attk time
      elseif rt_ind <= 1 then
        p2.reaction_time = preparation_cost[1]
      elseif rt_ind > preparation_cost.__len then
        p2.reaction_time = preparation_cost[preparation_cost.__len]
      end
      
      -- AI Initiate Attack
      if p1.state == "idle" and p2.state == "idle"
      and self.trialTime >= p2.strike_times then
        p2:strikePressed(dt) 
        p2.strikeTime = t
        player2_strike[self.trialNumber] = p2.strikeTime
        player2_block[self.trialNumber] = 9999
      end
      
      -- AI Reacts to Player Attack
      if p1.state == "strike" and p2.state == "idle" then
        -- draw from defense/attack distributions and set p2 state to the appropriate one
        -- if block RT before planned attack & it is block RT time 

          if p2.reaction_time + t < p2.strike_times and t >= p2.reaction_time + p1.strikeTime then
            p2:blockPressed(dt)
            p2.blockTime = t
            player2_block[self.trialNumber] = p2.blockTime
            player2_strike[self.trialNumber] = 9999
            -- elseif block Rt later than plan attack & is attack time, then attack
          elseif p2.reaction_time + t >= p2.strike_times and t == p2.strike_times then
            p2:strikePressed(dt)
            p2.strikeTime = t
            player2_strike[self.trialNumber] = p2.strikeTime
            player2_block[self.trialNumber] = 9999
          end
        
      end

      -- AI Reacts to Player Defense
      -- if p1 in block and p2 idle and attack time sooner than block RT then
      if p1.state == "block" and p2.state == "idle" and p2.strike_times - t < tonumber(p2.reaction_time) then
        p2:strikePressed(dt)
        p2.strikeTime = t
        player2_strike[self.trialNumber] = p2.strikeTime
        player2_block[self.trialNumber] = 9999
      end
      
    end
    ----------------------------------------------------------------------------------------------
  end
end


function GameLogic:fighterUpdate()
  
  -- if one player in active attack and other in active defense, attacker loses
  if p1.state == "strike" and p1.strike_active_frames[p1.currentFrame] then
    if p2.state == "block" and p2.block_active_frames[p2.currentFrame] then
      p1.state = "death"
      player1_win[self.trialNumber] = 0
    end
    if p2.state == "strike" and p2.strike_active_frames[p2.currentFrame] then
      if p2.strikeTime < p1.strikeTime then
        p1.state = "death"
        player1_win[self.trialNumber] = 0
      elseif p1.strikeTime < p2.strikeTime then
        p2.state = "death"
        player1_win[self.trialNumber] = 1
      elseif p1.strikeTime == p2.strikeTime then
        if math.random() > .5 then
          p1.state = "death"
          player1_win[self.trialNumber] = 0
        else
          p2.state = "death"
          player1_win[self.trialNumber] = 1
        end
        
      end
      
    elseif not p2.block_active_frames[p2.currentFrame] and p1.strike_active_frames[p1.currentFrame] then --- this may be problematic***************-----------
      p2.state = "death"
      player1_win[self.trialNumber] = 1
    end
    
  elseif p2.state == "strike" and p2.strike_active_frames[p2.currentFrame] then
    if p1.state == "block" and p1.block_active_frames[p1.currentFrame] then
      p2.state = "death"
      player1_win[self.trialNumber] = 1
    end
    if p1.state == "strike" and p1.strike_active_frames[p1.currentFrame] then
      -- whoever striked last loses
    elseif not p1.block_active_frames[p1.currentFrame] and p2.strike_active_frames[p2.currentFrame] then----- ************************-------------------
      p1.state = "death"
      player1_win[self.trialNumber] = 0
    end
    
  end
  

end

function GameLogic:nextTrial()
  if self.trialNumber < self.maxTrials then
    -- Initiates the next trial
    self.trialNumber = self.trialNumber + 1
    self.trialTime = 0.0
    self.state = "trial"
    player1_strike[self.trialNumber] = 9999
    player1_block[self.trialNumber] = 9999
    player2_strike[self.trialNumber] = 9999
    player2_block[self.trialNumber] = 9999
    player1_win[self.trialNumber] = 9999
    
    -- update ai strike time
    nstrat = math.random(1,1000) -- hardcoded to assume 1000 strat values are provided
    if p2.strike_times + strat_dist[nstrat] > self.trialTimeout or p2.strike_times + strat_dist[nstrat] < 0 then 
      p2.strike_times = p2.strike_times - strat_dist[nstrat]
    else
      p2.strike_times = p2.strike_times + strat_dist[nstrat] -- adapt strike time w/ a draw from the strategy distribution
    end
  
  
    p1.locked = 0
    p2.locked = 0
    p2.reaction_time = preparation_cost[1]
    read = 0
  elseif self.trialNumber == self.maxTrials then
    if read == 0 then
      --[[print('p1 strike:', player1_strike)
      print('p1 block:', player1_block)
      print('p2 strike:', player2_strike)
      print('p2 block:', player2_block)
      print('p1 win:', player1_win)]]--
      
      read = 1
      
      -- Give each table a length attribute
      player1_strike.__len = self.maxTrials
      player1_block.__len = self.maxTrials
      player2_strike.__len = self.maxTrials
      player2_block.__len = self.maxTrials
      player1_win.__len = self.maxTrials
      
      -- quick clean of the data
      i = 1
      while i <= player1_strike.__len do
        if not player1_strike[i] then
          player1_strike[i] = 9999
        end
        if not player1_block[i] then
          player1_strike[i] = 9999
        end
        if not player2_strike[i] then
          player1_strike[i] = 9999
        end
        if not player2_block[i] then
          player1_strike[i] = 9999
        end
        if not player1_win[i] then
          player1_strike[i] = 9999
        end
        i = i + 1
      end
      
      print_col2tbl({player1_strike, player1_block, player2_strike, player2_block, player1_win},5,nil)
      outname = "log_"..inbox.text..".txt"
      write_column(tbl, outname) -- write data out to file
    end
  end
end

function GameLogic:draw()
  local state = self.state
  if state == "input" then
    if not inbox.answer then do
        inbox:input(text)
        inbox:activity(x,y)
        inbox:draw()
        love.graphics.print ("Click in the box, enter an integer seed, and hit enter to move on!", 300, 250)
      end
    end
    
      
    if inbox.answer then
      self.state = "intro"
    end
    
  elseif state == "intro" then
    love.graphics.print("Press space to start", 440, 260 )
    
  elseif state == "trial" then
    love.graphics.print("game.state = " .. self.state, 400, 200 )
    love.graphics.print("game.trialNumber = " .. self.trialNumber, 400, 220 )
    love.graphics.print("game.trialTime= " .. self.trialTime, 400, 240 )
  elseif state == "timeout" then
    love.graphics.print("game.state = " .. self.state, 400, 200 )
    love.graphics.print("game.trialNumber = " .. self.trialNumber, 400, 220 )
    love.graphics.print("game.trialTime= " .. self.trialTime, 400, 240 )
  elseif state == "intertrial" then
    
  end
end
function write_column(C,F)
  io.output(F)
  i = 1
  while i <= C.__len do
    if i < C.__len then
      io.write(C[i])
      io.write("\n")
    else
      io.write(C[i])
    end
    i = i + 1
  end
end

function print_col2tbl(listOfColTbls,ntbls,show)
  nels = listOfColTbls[1].__len
  tbl = {}
  i = 1
  while i <= nels do
    line = ""
    ii = 1
    while ii <= ntbls do
      if ii < ntbls then
        line = line .. listOfColTbls[ii][i] .. ","
      elseif ii == ntbls then
        line = line .. listOfColTbls[ii][i]
      end
      ii = ii + 1
    end
    tbl[i] = line
    if show then
      print(tbl[i])
    end
    i = i + 1
  end
  tbl.__len = nels
end