
require "math"

Fighter = {
  control="player", x=10, facing="right", currentFrame=1, state="idle", animationTime=0.0, mode = "hard" }

function Fighter:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end 

function Fighter:initGraphics()
  -- Load images
  if self.facing == "right" then
    self.strike_img = love.graphics.newImage("assets/fighter_strike.png")
    self.block_img = love.graphics.newImage("assets/fighter_block.png")
    self.death_img = love.graphics.newImage("assets/fighter1_dies.png")
    self.x = 50
  elseif self.facing == "left" then
    self.strike_img = love.graphics.newImage("assets/fighter2_strike.png")
    self.block_img = love.graphics.newImage("assets/fighter2_block.png")
    self.death_img = love.graphics.newImage("assets/fighter2_dies.png")
    self.x = 300
  end
  self.currentImage = self.strike_img
  
  -- Active/ Passive frames
  self.strike_frames = {}
  self.strike_active_frames = {false, false, false, false, false, false, true, true, true, false, false, false, false} -- length 13
  self.block_frames = {}
  self.block_active_frames = {false, false, false, false,  true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false} -- length 21
  self.death_frames = {}
  local frame_width = 128
  local frame_height = 128
  
  -- Parse sprite sheets into individual frames
  for i=0,13 do
    table.insert(self.strike_frames, 
      love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height,
        self.strike_img:getWidth(), self.strike_img:getHeight()))
  end
  for i=0,21 do
    if i < 7 then
      table.insert(self.block_frames, 
        love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height,
          self.block_img:getWidth(), self.block_img:getHeight()))
    elseif i >= 7 and i <= 15 then -- this the size of this gap (currently 9 counts) will influence how long the parry is held fully
      table.insert(self.block_frames, 
        love.graphics.newQuad(7 * frame_width, 0, frame_width, frame_height,
          self.block_img:getWidth(), self.block_img:getHeight()))
    elseif i > 15 then
      table.insert(self.block_frames, 
        love.graphics.newQuad((i-8) * frame_width, 0, frame_width, frame_height,
          self.block_img:getWidth(), self.block_img:getHeight()))
    end
  end
  for i = 0,3 do
    table.insert(self.death_frames,
      love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height,
        self.death_img:getWidth(), self.death_img:getHeight()))
  end

  
end

function Fighter:strikePressed()
  if self.state == "idle" and self.locked == 0 then
    self.state = "strike"
    self.animationTime = 0.0
    self.locked = 1
  end
end

function Fighter:blockPressed()
  if self.state == "idle" and self.locked == 0 then
    self.state = "block"
    self.animationTime = 0.0
    self.locked = 1
  end
end

function Fighter:update(dt)
  local state = self.state
  -- Mapping state to frames
  if state == "idle" then
    self.currentImage = self.strike_img
    self.frames = self.strike_frames
  elseif state == "strike" then
    self.currentImage = self.strike_img
    self.frames = self.strike_frames    
  elseif state == "block" then
    self.currentImage = self.block_img
    self.frames = self.block_frames
  elseif state == "death" then
    self.currentImage = self.death_img
    self.frames = self.death_frames
  end
  
  -- Frame updates
  if state ~= "idle" then
    self.animationTime = self.animationTime + dt
    
    if self.control == "ai" and self.mode == "easy" then
      self.frameTime = 0.11
    elseif self.control == "ai" and self.mode == "normal" then
      self.frameTime = 0.095
    elseif self.control == "ai" and self.mode == "hard" then
      self.frameTime = 0.08
    end
    if self.control == "player" then
      self.frameTime = 0.08
    end
    
    self.currentFrame = math.ceil(self.animationTime / self.frameTime)
    if state ~= "death" then
      if self.state == 'strike' and self.currentFrame > 13 then -- length of strike animation (13)
        self.currentFrame = 1
        self.animationTime = 0
        self.state = "idle"
      elseif self.state == 'block' and self.currentFrame > 21 then -- length of parry animation + hold time (21)
        self.currentFrame = 1
        self.animationTime = 0
        self.state = "idle"
      end
      
    elseif state == "death" then
      if self.currentFrame > 3 then
        self.currentFrame = 1
        self.animationTime = 0
      end
      
    end
    
  end
  
end

function Fighter:draw()
  love.graphics.setColor(255,255,255,255)
  love.graphics.draw(self.currentImage, self.frames[self.currentFrame],self.x, 25, 0, 5, 5)
end