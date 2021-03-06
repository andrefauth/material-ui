--[[
    A loosely based Material UI module

    mui-base.lua : The base module all other modules include.

    The MIT License (MIT)

    Copyright (C) 2016 Anedix Technologies, Inc.  All Rights Reserved.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    For other software and binaries included in this module see their licenses.
    The license and the software must remain in full when copying or distributing.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

--]]

-- corona
local composer = require( "composer" )
local widget = require( "widget" )

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = {} -- for module array/table

function M.init_base(data)
  muiData.M = M -- all modules need access to parent methods
  muiData.environment = system.getInfo("environment")
  muiData.value = data
  muiData.circleSceneSwitch = nil
  muiData.circleSceneSwitchComplete = false
  muiData.touching = false
  muiData.masterRatio = nil
  muiData.masterRemainder = nil
  muiData.tableCircle = nil
  muiData.widgetDict = {}
  muiData.progressbarDict = {}
  muiData.currentNativeFieldName = ""
  muiData.currentTargetName = ""
  muiData.lastTargetName = ""
  muiData.interceptEventHandler = nil
  muiData.interceptMoved = false
  muiData.dialogInUse = false
  muiData.dialogName = nil
  muiData.navbarHeight = 0
  muiData.navbarSupportedTypes = { "BasicText", "CircleButton", "RRectButton", "RectButton", "IconButton", "Slider", "TextField", "Generic" }
  muiData.onBoardData = nil
  muiData.slideData = nil
  muiData.currentSlide = 0

  muiData.scene = composer.getScene(composer.getSceneName("current"))
  muiData.scene.name = composer.getSceneName("current")
  Runtime:addEventListener( "touch", M.eventSuperListner )
end

function M.eventSuperListner(event)
    if (event.phase == "ended" or event.phase == "cancelled") and muiData.currentTargetName ~= nil and muiData.currentTargetName ~= muiData.lastTargetName then
        muiData.lastTargetName = muiData.currentTargetName
        -- find name in list and type, if slider then force the end!
        for widget in pairs(muiData.widgetDict) do
            widgetType = muiData.widgetDict[widget]["type"]
            if widgetType == "Slider" and muiData.widgetDict[widget].name == muiData.currentTargetName then
                muiData.widgetDict[widget]["sliderrect"]:dispatchEvent(event)
                break
            elseif widgetType == "Selector" and muiData.widgetDict[widget].name == muiData.currentTargetName then
                if muiData.widgetDict[muiData.currentTargetName]["mygroup"] ~= nil then
                    muiData.currentTargetName = nil
                    muiData.lastTargetName = ""
                    M.removeWidgetSelector(widget, "listonly")
                end
                break
            elseif widgetType == "Selector" and muiData.widgetDict[widget] ~= nil then
                if muiData.widgetDict[widget]["mygroup"] ~= nil and muiData.widgetDict[widget]["mygroup"].isVisible == true then
                    M.removeWidgetSelector(widget, "listonly")
                end
            end
        end
    end
end

function M.updateEventHandler( event )
    if muiData.interceptEventHandler ~= nil then
        muiData.interceptEventHandler:touch(event)
    end
    if event.phase == "moved" then
        muiData.interceptMoved = true
    elseif event.phase == "ended" then
        muiData.interceptMoved = false
    end
end

function M.updateUI(event, skipName)
    local widgetType = ""

    for widget in pairs(muiData.widgetDict) do
        if widget ~= skipName or skipName == nil then
            widgetType = muiData.widgetDict[widget]["type"]
            if (widgetType == "TextField" or widgetType == "TextBox") and muiData.widgetDict[widget]["textfield"].isVisible == true then
                -- hide the native field
                timer.performWithDelay(100, function() native.setKeyboardFocus(nil) end, 1)
                muiData.widgetDict[widget]["textfieldfake"].isVisible = true
                muiData.widgetDict[widget]["textfield"].isVisible = false
            elseif (widgetType == "TextField" or widgetType == "TextBox") and muiData.widgetDict[widget]["textfield"].isVisible == true then
               --  timer.performWithDelay(100, function() native.setKeyboardFocus(nil) end, 1)
            end
        end
    end
end

function M.addBaseEventParameters(event, options)
    if event == nil or options == nil or event.muiDict ~= nil then return end
    M.setEventParameter(event, "name", options.name)
    M.setEventParameter(event, "basename", options.basename)
    M.setEventParameter(event, "targetName", options.name)
    M.setEventParameter(event, "targetPrimary", event.target)
    M.setEventParameter(event, "callBackData", options.callBackData)
    muiData.currentTargetName = options.name
    muiData.lastTargetName = ""
end

function M.setEventParameter(event, key, value)
    if event == nil or key == nil then return end
    if event.muiDict == nil then event.muiDict = {} end
    event.muiDict[key] = value
end

function M.getEventParameter(event, key)
    if event ~= nil and event.muiDict ~= nil and key ~= nil then
        return event.muiDict[key]
    else
      print("nothing for key "..key)
    end
    return nil
end

function M.getWidgetByName(name)
    if name ~= nil and string.len(name) > 1 then
        return muiData.widgetDict[name]
    end
    return nil
end

function M.getWidgetBaseObject(name)
    local widgetData = nil

    if name ~= nil and string.len(name) > 1 then
        for widget in pairs(muiData.widgetDict) do
          local widgetType = muiData.widgetDict[widget]["type"]
          if widgetType ~= nil and widget == name then
            if widgetType == "BasicText" then
               widgetData = muiData.widgetDict[widget]["text"]
            elseif widgetType == "CircleButton" then
               widgetData = muiData.widgetDict[widget]["circlemain"]
            elseif widgetType == "DatePicker" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "RRectButton" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "RectButton" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "IconButton" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "RadioButton" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "Toolbar" then
               -- widgetData = muiData.widgetDict[widget]["container"]
               print("getWidgetForInsert: Toolbar not supported at this time.")
            elseif widgetType == "TableView" then
               widgetData = muiData.widgetDict[widget]["tableview"]
            elseif widgetType == "TextField" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "TextBox" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "TimePicker" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "ProgressBar" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "ToggleSwitch" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "Dialog" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "Slider" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "Toast" then
               widgetData = muiData.widgetDict[widget]["container"]
            end
          end
        end
    end
    return widgetData
end

function M.getWidgetValue(widgetName)
    if widgetName == nil then return end
    return muiData.widgetDict[widget]["value"]
end

function M.getScaleVal(n)
    if n == nil then n = 1 end
    return mathFloor(M.getSizeRatio() * n)
end

function M.getSizeRatio()
  if muiData.masterRatio ~= nil then
    return muiData.masterRatio
  end
  local divisor = 1
  if string.find(system.orientation, "portrait") ~= nil then
    divisor = 640
  elseif string.find(system.orientation, "landscape") ~= nil then
    divisor = 960
  end

  muiData.masterRatio = display.contentWidth / divisor
  muiData.masterRemainder = mathMod(display.contentWidth, divisor)
  return muiData.masterRatio
end

function M.split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

function M.getTextWidth(options)
  local width = display.contentWidth

  if options == nil then return display.contentWidth end

  local lines = M.split(options.text, "\n")
  local longest = 0
  local lineLength = 0
  local text = ""
  for _,line in ipairs(lines) do
     lineLength = string.len(line)
     if lineLength > longest then
        longest = lineLength
        text = line
     end
  end
  -- scale font
  -- Calculate a font size that will best fit the given text field's height
  local textToMeasure = display.newText( text, 0, 0, options.font, options.fontSize )
  width = textToMeasure.contentWidth
  textToMeasure:removeSelf()
  textToMeasure = nil
  return width
end

function M.tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function M.getColor(colorArray, index)
  local color = 1
  if colorArray == nil or index == nil then return end

  if colorArray[index] ~= nil then
    color = colorArray[index]
  end

  return color
end

function M.subtleRadius(e)
    transition.fadeOut( e, { time=500, onComplete=M.subtleRadiusDone } )
end

function M.subtleRadiusDone(e)
    e.isVisible = false
    transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
    muiData.touching = false
    if muiData.tableCircle ~= nil then
        muiData.tableCircle:toBack()
    end
end

function M.subtleRadius2(e)
    transition.fadeOut( e, { time=300, onComplete=M.subtleRadiusDone2 } )
end

function M.subtleRadiusDone2(e)
    e.isVisible = false
    transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
    muiData.touching = false
end

function M.subtleGlowRect( e )
    transition.to( e, { time=300,alpha=1 } )
end

--[[ switch scene action ]]

function M.actionSwitchScene( e )
    if muiData.circleSceneSwitchComplete == true or muiData.circleSceneSwitch ~= nil then return end
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")
    local muiTargetCallBackData = M.getEventParameter(e, "muiTargetCallBackData")
    if muiTargetCallBackData == nil then
      muiTargetCallBackData = e.callBackData
    end

    local circleColor = { 1, 0.58, 0 }
    M.hideNativeWidgets()

    if muiTargetCallBackData ~= nil and muiTargetCallBackData.sceneTransitionColor ~= nil then
        circleColor = muiTargetCallBackData.sceneTransitionColor
    end
    muiData.circleSceneSwitch = display.newCircle( 0, 0, display.contentWidth + (display.contentWidth * 0.25))
    muiData.circleSceneSwitch:setFillColor( unpack(circleColor) )
    muiData.circleSceneSwitch.alpha = 1
    muiData.circleSceneSwitch.callBackData = muiTargetCallBackData
    transition.to( muiData.circleSceneSwitch, { time=0, width=M.getScaleVal(100), height=M.getScaleVal(100), onComplete=M.postActionForSwitchScene }) --, onComplete=postActionForButton } )
end

function M.postActionForSwitchScene(e)
    -- enlarge circle
    if muiData.circleSceneSwitch == nil then return end
    transition.to( muiData.circleSceneSwitch, { time=900, xScale=2, yScale=2, onComplete=M.finalActionForSwitchScene } )
end

function M.finalActionForSwitchScene(e)
    -- switch to scene
    if muiData.circleSceneSwitch == nil then return end
    muiData.circleSceneSwitch.isVisible = false
    muiData.circleSceneSwitch:removeSelf()
    muiData.circleSceneSwitch = nil
    muiData.circleSceneSwitchComplete = true
    if e.callBackData ~= nil and e.callBackData.sceneDestination ~= nil then
        composer.removeScene( muiData.scene.name )
        composer.gotoScene( e.callBackData.sceneDestination )
    end
end

function M.goToScene(callBackData)
    if muiData.circleSceneSwitchComplete == true then return end
    if callBackData ~= nil and callBackData.onCompleteData ~= nil then
        local e = {
            callBackData = callBackData.onCompleteData
        }
        M.actionSwitchScene( e )
    end
end

--[[ end switch scene action ]]

function M.isTouchPointOutOfRange( event )
    local success = false

    if event ~= nil then
        if event.x < event.target.contentBounds.xMin or
           event.x > event.target.contentBounds.xMax or
           event.y < event.target.contentBounds.yMin or
           event.y > event.target.contentBounds.yMax then
           success = true
        end
    end

    return success
end

function M.getWidthForFontWithText(options)
  if options == nil then return 125 end

  local textToMeasure = display.newText( options.text, 0, 0, options.font, options.fontSize )
  local width = textToMeasure.contentWidth
  textToMeasure:removeSelf()
  textToMeasure = nil

  return width
end

function M.scrollListener( event )
    local phase = event.phase
    if event.phase == nil then return end

    M.updateEventHandler( event )

    if ( phase == "began" ) then
        -- skip it
    elseif ( phase == "moved" ) then
        M.updateUI(event)
    elseif ( phase == "ended" ) then
        -- print( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    --[[--
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end
    --]]--

    return true
end

function M.showNativeInput(event)
    local name = event.target.name
    local dialogName = event.target.dialogName
    muiData.currentNativeFieldName = name

    if muiData.dialogInUse == true and dialogName == nil then return end
    if event.phase == "began" then

        local madeAdjustment = false
        if muiData.widgetDict[name]["scrollView"] ~= nil then
            madeAdjustment = M.adjustNativeInputIntoView(event)
        end

        muiData.widgetDict[name]["textfieldfake"].isVisible = false
        muiData.widgetDict[name]["textfield"].isVisible = true
        muiData.widgetDict[name]["textfield"].isSecure = muiData.widgetDict[name]["isSecure"]
        if madeAdjustment == false then
            timer.performWithDelay(100, function() native.setKeyboardFocus(muiData.widgetDict[name]["textfield"]) end, 1)
        end
    end
end

function M.adjustNativeInputIntoView(event)
    local name = event.target.name
    local height = muiData.widgetDict[name]["textfield"].contentHeight
    local scrollViewHeight = muiData.widgetDict[name]["scrollView"].contentHeight
    local topMargin = mathFloor(scrollViewHeight * 0.25)
    local bottomMargin = mathFloor(scrollViewHeight * 0.9)
    local x, y = muiData.widgetDict[name]["scrollView"]:getContentPosition()
    local scrollDuration = 500
    local destY = nil
    local scrollOptions = nil
    local madeAdjustment = false


    if event.y > bottomMargin then
        destY = y - height
        scrollOptions = {
            y = destY
        }
    elseif event.y < topMargin then
        local offset = 0
        local widgetY = muiData.widgetDict[name]["container"].y
        local diffY = mathABS(widgetY) - mathABS(y)
        local scrollAmount = height - diffY
        destY = y + scrollAmount
        if muiData.widgetDict[name]["type"] == "TextField" then
            offset = height
        end
        scrollOptions = {
            y = destY + offset
        }
    end
    if destY ~= nil then
        scrollOptions.time = scrollDuration
        scrollOptions.onComplete = M.adjustScrollViewComplete
        madeAdjustment = true
        muiData.widgetDict[name]["scrollView"]:scrollToPosition(scrollOptions)
    end

    return madeAdjustment
end

function M.adjustScrollViewComplete(event)
    local name = muiData.currentNativeFieldName
    timer.performWithDelay(100, function() native.setKeyboardFocus(muiData.widgetDict[name]["textfield"]) end, 1)
end

function M.hideWidget(widgetName, options)
  if showWidget == nil then showWidget = false end
  for widget in pairs(muiData.widgetDict) do
      local widgetType = muiData.widgetDict[widget]["type"]
      if widgetType ~= nil then
        if widgetType == "CircleButton" then
            muiData.widgetDict[widget]["circlemain"].isVisible = showWidget
        elseif widgetType == "RRectButton" or widgetType == "RectButton" then
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        elseif widgetType == "IconButton" or widgetType == "RadioButton" then
            muiData.widgetDict[widget]["mygroup"].isVisible = showWidget
        elseif widgetType == "Toolbar" then
            -- not yet supported
        elseif widgetType == "TableView" then
            muiData.widgetDict[widget]["tableview"].isVisible = showWidget
        elseif widgetType == "TextField" or widgetType == "TextBox" then
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        elseif widgetType == "ProgressBar" or widgetType == "ToggleSwitch" then
            muiData.widgetDict[widget]["mygroup"].isVisible = showWidget
        elseif widgetType == "Slider" then
            muiData.widgetDict[widget]["sliderrect"].isVisible = showWidget
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        elseif widgetType == "Toast" or widgetType == "Selector" then
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        end
      end
  end
end

function M.hideNativeWidgets()
  for widget in pairs(muiData.widgetDict) do
      local widgetType = muiData.widgetDict[widget]["type"]
      if widgetType ~= nil then
        if widgetType == "TextField" or widgetType == "TextBox" then
            muiData.widgetDict[widget]["textfield"].isVisible = false
        end
      end
  end
end

function M.removeWidgets()
  print("Removing widgets")
  for widget in pairs(muiData.widgetDict) do
      local widgetType = muiData.widgetDict[widget]["type"]
      if widgetType ~= nil and muiData.widgetDict[widget] ~= nil then
        if widgetType == "CircleButton" then
            M.removeWidgetCircleButton(widget)
        elseif widgetType == "DatePicker" then
            M.removeWidgetDatePicker(widget)
        elseif widgetType == "RRectButton" then
            M.removeWidgetRRectButton(widget)
        elseif widgetType == "RectButton" then
            M.removeWidgetRectButton(widget)
        elseif widgetType == "IconButton" then
            M.removeWidgetIconButton(widget)
        elseif widgetType == "RadioButton" then
            M.removeWidgetRadioButton(widget)
        elseif widgetType == "Toolbar" then
            M.removeWidgetToolbar(widget)
        elseif widgetType == "TableView" then
            M.removeWidgetTableView(widget)
        elseif widgetType == "TextField" then
            M.removeWidgetTextField(widget)
        elseif widgetType == "TextBox" then
            M.removeWidgetTextBox(widget)
        elseif widgetType == "TimePicker" then
            M.removeWidgetTimePicker(widget)
        elseif widgetType == "ProgressBar" then
            M.removeWidgetProgressBar(widget)
        elseif widgetType == "ToggleSwitch" then
            M.removeWidgetToggleSwitch(widget)
        elseif widgetType == "Slider" then
            M.removeWidgetSlider(widget)
        elseif widgetType == "Toast" then
            M.removeWidgetToast(widget)
        elseif widgetType == "Selector" then
            M.removeWidgetSelector(widget)
        elseif widgetType == "Navbar" then
            M.removeNavbar(widget)
        elseif widgetType == "BasicText" then
            M.removeWidgetBasicText(widget)
        end
      end
  end

  -- remove onBoarding if used.
  if muiData.onBoardData ~= nil then
    M.removeWidgetOnBoarding()
  end

  -- remove circle if present
  if muiData.tableCircle ~= nil then
    muiData.tableCircle.isVisible = false
    muiData.tableCircle:removeSelf()
  end

  Runtime:removeEventListener( "touch", M.eventSuperListner )

end

return M
