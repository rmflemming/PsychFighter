require "math"

GameLogic = {
   p2_type="ai", state="intro", trialTime=0.0, globalTime=0.0, 
   trialTimeout=5.0, trialNumber=0, timeoutDuration=1.0, maxTrials = 1, fighter1=nil, fighter2=nil,
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
      -- AI Initiate Attack
      if p1.state == "idle" and p2.state == "idle"
      and self.trialTime >= p2.strike_times then
        p2:strikePressed(dt) 
        p2.strikeTime = t
        player2_strike[self.trialNumber] = p2.strikeTime
        player2_block[self.trialNumber] = none
      end
      
      -- AI Reacts to Player Attack
      if p1.state == "strike" and p2.state == "idle" then
        -- draw from defense/attack distributions and set p2 state to the appropriate one
        -- if block RT before planned attack & it is block RT time 

          if p2.reaction_time + t < p2.strike_times and t >= p2.reaction_time + p1.strikeTime then
            p2:blockPressed(dt)
            p2.blockTime = t
            player2_block[self.trialNumber] = p2.blockTime
            player2_strike[self.trialNumber] = none
            -- elseif block Rt later than plan attack & is attack time, then attack
          elseif p2.reaction_time + t >= p2.strike_times and t == p2.strike_times then
            p2:strikePressed(dt)
            p2.strikeTime = t
            player2_strike[self.trialNumber] = p2.strikeTime
            player2_block[self.trialNumber] = none
          end
        
      end

      -- AI Reacts to Player Defense
      -- if p1 in block and p2 idle and attack time sooner than block RT then
      if p1.state == "block" and p2.state == "idle" and p2.strike_times - t < tonumber(p2.reaction_time) then
        p2:strikePressed(dt)
        p2.strikeTime = t
        player2_strike[self.trialNumber] = p2.strikeTime
        player2_block[self.trialNumber] = none
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
      print('p1 strike:',player1_strike[1])
      print('p1 block:', player1_block[1])
      print('p2 strike:', player2_strike[1])
      print('p2 block:', player2_block[1])
      print('p1 win:', player1_win[1])
      read = 1
    end
  end
end

function GameLogic:draw()
  local state = self.state
  love.graphics.print("game.state = " .. self.state, 400, 200 )
  love.graphics.print("game.trialNumber = " .. self.trialNumber, 400, 220 )
  love.graphics.print("game.trialTime= " .. self.trialTime, 400, 240 )
  if state == "intro" then
    love.graphics.print("Press space to start", 400, 260 )
  if not inbox.answer then do
      inbox:input(text)
      inbox:activity(x,y)
      inbox:draw()
    end
  end
    
  elseif state == "trial" then
    
  elseif state == "timeout" then
    
  elseif state == "intertrial" then
    
  end
end