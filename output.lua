Output = {player1_strike = {}, player1_block = {},
  player2_strike = {}, player2_block = {}, player1_win = {}}
  
function Output:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end 