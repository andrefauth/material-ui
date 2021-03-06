--[[
    A loosely based Material UI module

    mui-toast.lua : This is for creating "toast" notifications.

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

--]]--

-- corona
local widget = require( "widget" )

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.createToast( options )
    if options == nil then return end

    if muiData.widgetDict[options.name] ~= nil then return end

    if options.width == nil then
        options.width = M.getScaleVal(200)
    end

    if options.height == nil then
        options.height = M.getScaleVal(4)
    end

    if options.radius == nil then
        options.radius = M.getScaleVal(15)
    end

    local left,top = (display.contentWidth-options.width) * 0.5, display.contentHeight * 0.5
    if options.left ~= nil then
        left = options.left
    end

    if options.textColor == nil then
        options.textColor = { 1, 1, 1, 1 }
    end

    if options.fillColor == nil then
        options.fillColor = { 0.06, 0.56, 0.15, 1 }
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.top == nil then
        options.top = M.getScaleVal(80)
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "Toast"

    muiData.widgetDict[options.name]["container"] = widget.newScrollView(
        {
            top = -options.height,
            left = left,
            width = options.width + (options.width * 0.10),
            height = options.height + (options.height * 0.10),
            scrollWidth = options.width,
            scrollHeight = options.height,
            hideBackground = true,
            hideScrollBar = true,
            isLocked = true
        }
    )

    muiData.widgetDict[options.name]["touching"] = false

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local newX = muiData.widgetDict[options.name]["container"].contentWidth * 0.5
    local newY = muiData.widgetDict[options.name]["container"].contentHeight * 0.5

    muiData.widgetDict[options.name]["rrect"] = display.newRoundedRect( newX, newY, options.width, options.height, radius )
    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )

    local rrect = muiData.widgetDict[options.name]["rrect"]

    local fontSize = 24
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize

    muiData.widgetDict[options.name]["myText"] = display.newText( options.text, newX, newY, font, fontSize )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(options.textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], true )

    function rrect:touch (event)
        if muiData.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            --event.target:takeFocus(event)
            -- if scrollView then use the below
            muiData.interceptEventHandler = rrect
            M.updateUI(event)
            if muiData.touching == false then
                muiData.touching = true
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                  event.phase = "offTarget"
                  -- print("Its out of the button area")
                  -- event.target:dispatchEvent(event)
            else
                event.phase = "onTarget"
                if muiData.interceptMoved == false then
                    if options.easingOut == nil then
                        options.easingOut = 500
                    end
                    muiData.widgetDict[options.name]["container"].name = options.name
                    transition.to(muiData.widgetDict[options.name]["container"],{time=options.easingOut, y=-(options.top), transition=easing.inOutCubic, onComplete=M.removeToast})
                    event.target = muiData.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])

                    assert( options.callBack )(event)
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
    end
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", muiData.widgetDict[options.name]["rrect"] )

    if options.easingIn == nil then
        options.easingIn = 500
    end
    transition.to(muiData.widgetDict[options.name]["container"],{time=options.easingIn, y=options.top, transition=easing.inOutCubic})
end

function M.removeToast(event)
    local muiName = event.name
    if muiName ~= nil then
        M.removeWidgetToast(muiName)
    end
end

function M.removeWidgetToast(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["sliderrect"])
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

return M
