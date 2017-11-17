
require "math"

Fighter = {
  control="player", x=10, facing="right", currentFrame=1, state="idle", animationTime=0.0 }

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
  self.strike_active_frames = {false, false, false, false, false, false, true, true, true, false, false, false, false}
  self.block_frames = {}
  self.block_active_frames = {false, false, false, false,  true,  true, true, true, true, false, false, false, false}
  self.death_frames = {}
  local frame_width = 128
  local frame_height = 128
  
  -- Parse sprite sheets into individual frames
  for i=0,13 do
    table.insert(self.strike_frames, 
      love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height,
        self.strike_img:getWidth(), self.strike_img:getHeight()))
    table.insert(self.block_frames, 
      love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height,
        self.block_img:getWidth(), self.block_img:getHeight()))
  end
  for i = 0,3 do
    table.insert(self.death_frames,
      love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height,
        self.death_img:getWidth(), self.death_img:getHeight()))
  end

  
end

--[[
function Fighter:initTimings()
  if self.control == "ai" then
    -- Will want to draw from distributions (sciLua?) eventually
    self.strike_times = 1
    self.block_times = .5
  end
end
]]--
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
    self.currentFrame = math.ceil(self.animationTime / 0.08)
    if state ~= "death" then
      if self.currentFrame > 13 then
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
  love.graphics.draw(self.currentImage, self.frames[self.currentFrame],self.x, 25, 0, 5, 5)
end
