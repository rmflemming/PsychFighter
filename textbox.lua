textbox = {
    x = 430,
    y = 300,
    width = 100,
    height = 50,
    text = '',
    active = false,
    answer = false,
    colors = {
        background = { 255, 255, 255,255 },
        text = { 40, 40, 40, 255 }
    }
}

function textbox:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end 

function textbox:input(text)
  function love.textinput (text)
      if textbox.active then
          textbox.text = textbox.text .. text
      end
  end
end

function textbox:activity(x,y)
  function love.mousepressed (x, y)
      if
          x >= textbox.x and
          x <= textbox.x + textbox.width and
          y >= textbox.y and 
          y <= textbox.y + textbox.height 
      then
          textbox.active = true
      elseif textbox.active then
          textbox.active = false
      end
  end
end

function textbox:draw()
    love.graphics.setColor(unpack(textbox.colors.background))
    love.graphics.rectangle('fill',
        textbox.x, textbox.y,
        textbox.width, textbox.height)

    love.graphics.setColor(unpack(textbox.colors.text))
    love.graphics.printf(textbox.text,
        textbox.x, textbox.y,
        textbox.width, 'left')
end