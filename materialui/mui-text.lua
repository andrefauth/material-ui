--[[
    A loosely based Material UI module

    mui-text.lua : This is for creating text widgets.

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

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

-- define methods here
function M.createBasicText(options)
	if options == nil then return end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "BasicText"
    muiData.widgetDict[options.name]["options"] = options

    muiData.widgetDict[options.name]["text"] = display.newText( options )
    muiData.widgetDict[options.name]["text"]:setFillColor( unpack(options.fillColor) )
end

function M.removeWidgetBasicText(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["text"]:removeSelf()
    muiData.widgetDict[widgetName]["text"] = nil
    muiData.widgetDict[widgetName] = nil
end


return M
