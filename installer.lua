-- Menu API
--
-- Written By: GhastTearz
-- Version: 2.0.0
--
-- This program is a simple and flexible way to get
-- menus in your program.
--
-- The format of menu strings is very simple. Each
-- line of the string is a line in the menu. To add
-- a "link" to a function or screen just as a tag
-- somewhere in the line e.g. "@tag". See the demo
-- program for more information at
-- https://pastebin.com/ZNYdQzaR
--
-- KEYBINDINGS
-- w, k, up           =  move up the menu
-- a, h, left         =  go to previous screen
-- s, j, down         =  move down the menu
-- d, l, right, enter = select an item
-- q, x = quit
-- page up = go up a page
-- page down = go down a page
--
---------------------------------------------------

function addFunc(menu, tag, func, ...)

  if menu == nil or type(menu) ~= "table" then
    error("Expected a menu table.")
  end
  if tag == nil or type(tag) ~= "string" then
    error("Expected a tag string.")
  end
  if func == nil or type(func) ~= "function" then
    error("Expected a function.")
  end
  
  if menu[tag] ~= nil then
    error("The tag "..tag.." is already in use.")
  end
  
  local args = ...
  menu[tag] = function() func(args) end
  
end

function addScreen(menu, tag, screen)

  if menu == nil or type(menu) ~= "table" then
    error("Expected a menu table.")
  end
  if tag == nil or type(tag) ~= "string" then
    error("Expected a tag string.")
  end
  if screen == nil or type(screen) ~= "string" then
    error("Expected a screen string.")
  end
  
  if menu[tag] ~= nil then
    error("The tag "..tag.." is already in use.")
  end
  
  menu[tag] = {}
  
  -- parse the screen string into a table    
  local line = 1
  local text = ""
  local ref  = ""
  
  local i = 1
  while i < #screen do
    
    if screen:sub(i,i) == '@' then
      if screen:sub(i+1,i+1) == '@' then
      --escape two @s by skipping a char
        i = i + 1
      else
        if ref ~= "" then
          error("On input line "..line
                .." for screen "..tag
                .." there is more than one tag.")
        end
      
        i = i + 1
        while screen:sub(i,i) ~= "" and
              screen:sub(i,i) ~= ' ' and
              screen:sub(i,i) ~= '\t' and
              screen:sub(i,i) ~= '\n' do
            
          ref = ref..screen:sub(i,i)
          i = i + 1      
        end
      
        if ref == "" then
          error("On input line "..line
                .." for screen "..tag
                .." the tag is empty.")
        end
      end
    end
    
    if screen:sub(i,i) == '\n' or
       screen:sub(i,i) == "" then
       
      menu[tag][line] = {}
      menu[tag][line].text = text
      menu[tag][line].ref  = ref
      text = ""
      ref  = ""
      line = line + 1
      
    else
      text = text..screen:sub(i,i)
      
    end
    
    i = i + 1

  end
end

function displayScreen(menu, tag)
  
  if menu == nil or type(menu) ~= "table" then
    error("Expected a menu table.")
  end
  if tag == nil or type(tag) ~= "string" then
    error("Expected a tag string.")
  end
  if menu[tag] == nil then
    error("The tag "..tag.." does not exist.")
  end
  if type(menu[tag]) ~= "table" then
    error("The tag "..tag.." is not a screen.")
  end
  
  --Check that all the tags refer to something
  for k, v in pairs(menu) do
    if type(menu[k]) == "table" then
      for l = 1, #menu[k] do
        local r = menu[k][l].ref
        if r ~= "" and menu[r] == nil then
          error("The tag "..r.." is not defined.")
        end
      end
    end
  end


  local currentScreen = menu[tag]

  local screenStack = {}
  screenStack[1] = menu[tag]

  local width, height = term.getSize()


  -- These are indexes into the screen.
  -- Top is the first line to be printed.
  -- Bottom is the last line to be printed.
  -- Selection is the line the user might select.
  local top = 1
  local bottom = height
  local selection = 0
  
  local function printScreen()
    
    term.clear()
    term.setCursorPos(1,1)
    
    for i = top, bottom do
      if i > #currentScreen then
        break
      end

      local y = (i % height)
      if y == 1 then
        y = height
      end
	  
      term.setCursorPos(1, y)
	  if i == selection then
        term.setTextColor(colors.black)
		term.setBackgroundColor(colors.white)
      else
        term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
      end
	  term.clearLine()
      if i == selection then
        write("  "..currentScreen[i].text)
      else
        write("  "..currentScreen[i].text)
      end
	  term.setTextColor(colors.white)
      term.setBackgroundColor(colors.black)
    end
  end
  
  local function setSelection()
    selection = 0
    for i = top, bottom do
      if i > #currentScreen then
        break
      end
      if currentScreen[i].ref ~= "" then
        selection = i
        break
      end
    end
  end

  local function pageUp()
    if top > 1 then
      top = top - height
      bottom = bottom - height
      setSelection()
    end
  end

  local function pageDown()
    if #currentScreen > bottom then
      top = top + height
      bottom = bottom + height
      setSelection()
   end
  end


  setSelection()
  printScreen()
  
  while true do
  
    local e, key = os.pullEvent("key")
  
    -- go up the screen
    if key == 17 or
       key == 37 or
       key == 200 then
       
      -- find prev item with a ref
      local prevItem
      for i = selection - 1, 1, -1 do    
        if currentScreen[i].ref ~= "" then
          prevItem = i
          break
        end      
      end
      
      if prevItem == nil then
        pageUp()
      else
        selection = prevItem
        if prevItem < top then    
          pageUp()
        end
      end
       
    end
    
    -- go down the screen
    if key == 31 or
       key == 36 or
       key == 208 then
       
      -- find the next item with a ref
      local nextItem
      for i = selection + 1, #currentScreen do
        if currentScreen[i].ref ~= "" then
          nextItem = i
          break
        end
      end
      
      if nextItem == nil then
        pageDown()
      else
        selection = nextItem
        if nextItem > bottom then
          pageDown()
        end
      end

    end
    
    -- select the current item
    if (key == 32 or
       key == 38 or
       key == 205 or
       key == 28 ) and
       currentScreen[selection] ~= nil then
       
      local r = currentScreen[selection].ref

      if type(menu[r]) == "function" then
        term.clear()
        term.setCursorPos(1,1)
        return menu[r]   
      else
        screenStack[#screenStack + 1] = menu[r]
        currentScreen = menu[r]
        top = 1
        bottom = height
        setSelection()
      end

    end
    
    -- Go back to previous screen
    if (key == 30 or
       key == 35 or
       key == 203) and
       #screenStack > 1 then
     
      screenStack[#screenStack] = nil
      currentScreen = screenStack[#screenStack]
      top = 1
      bottom = height
      setSelection()
    end
    
    -- quit the menu
    if key == 16 or
       key == 45 then
      term.clear()
      term.setCursorPos(1,1)
      return
    end
    
    if key == 201 then
      pageUp()    
    end
    
    if key == 209 then
      pageDown()
    end

    printScreen()
    
  end
  
end


function new()
  local t = {}
  t.addFunc       = addFunc
  t.addScreen     = addScreen
  t.displayScreen = displayScreen
  return t
end

local m = new()


m:addScreen("page1",
[[

                   INSTALLER
                   
Welcome to the connection utility installer.
When ready, select "Next" using your keyboard.

Next @page2
Quit @quit

]])


m:addScreen("page2",
[[

                   INSTALLER
                   
Please agree to the license.

--[ DiamondLicense for Computercraft ]--
While using this copy of this software,
you agree that
a) Your modifications have NO WARRANTY,
   meaning you'll have to reinstall if
   you mess up.
b) To use this software responsibly,
   and to ensure that it is not misused.
c) To not modify and place malicous code
   while using.
Agreeing to these terms also agress to
the GNU GENERAL PUBLIC LICENSE 3.0.

I agree @page3
I disgree @quit

]])

m:addScreen("page1",
[[

                   INSTALLER
                   
You are ready to install. Select Install to
start.

Install @install
Cancel and Quit @quit

]])

function quit()
	term.setCursorPos(1, 1)
	term.clear()
end

function install()
	term.setCursorPos(1, 1)
	term.clear()
	for k, in pairs({
		"wget https://cloud-catcher.squiddev.cc/cloud.lua /.connectTool/cloud.lua",
		"https://raw.githubusercontent.com/QM8782/personalCCremote-bin/refs/heads/main/connectTool.lua /.connectTool/main.lua",
	} do	
		shell.run(v)
	end
	term.setCursorPos(1, 1)
	term.clear()
	print("Installed. The launcher is located at the root of the computer. Type \"/connectTool\" to launch.")
end

m:addFunc("quit", quit)
m:addFunc("install", install)

local f = m:displayScreen("page1")
if f ~= nil then
	f()
end
  
