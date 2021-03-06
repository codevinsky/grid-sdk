--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Bind List Panel class
--
--============================================================================--

require( "engine.client.gui.optionsmenu.bindlistheader" )
require( "engine.client.gui.optionsmenu.bindlistitem" )

class "bindlistpanel" ( gui.scrollablepanel )

function bindlistpanel:bindlistpanel( parent, name )
	gui.scrollablepanel.scrollablepanel( self, parent, name )
end

function bindlistpanel:draw()
	if ( not self:isVisible() ) then
		return
	end

	self:drawBackground()

	gui.panel.draw( self )

	self:drawForeground()
end

function bindlistpanel:drawBackground()
	local property = "bindlistpanel.backgroundColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "fill", 0, 0, width, height )
end

function bindlistpanel:drawForeground()
	local property = "bindlistpanel.outlineColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "line", 0, 0, width, height )
end

local function getLastY( self )
	local children = self:getChildren()
	if ( children ) then
		local y = 0
		for _, v in ipairs( children ) do
			y = y + v:getHeight()
		end
		return y
	end
	return 0
end

function bindlistpanel:addHeader( label )
	local panel = self:getInnerPanel()
	local name  = label .. " Bind List Header"
	local y     = getLastY( panel )
	local label = gui.bindlistheader( panel, name, label )
	label:setY( y )
	self:setInnerHeight( getLastY( panel ) )
end

function bindlistpanel:addBinding( text, key, concommand )
	local panel   = self:getInnerPanel()
	local name    = text .. " Bind List Item"
	local y       = getLastY( panel )
	local binding = gui.bindlistitem( panel, name, text, key, concommand )
	binding:setY( y )
	self:setInnerHeight( getLastY( panel ) )
end

function bindlistpanel:onBindChange( item, key, concommand )
	print( key, concommand )
end

function bindlistpanel:readBinds()
	if ( not filesystem.exists( "cfg/binds.lst" ) ) then
		return
	end

	local list = {}
	for line in filesystem.lines( "cfg/binds.lst" ) do
		table.insert( list, line )
	end

	for i, line in ipairs( list ) do
		if ( string.len( line ) > 0 ) then
			local nextLine = list[ i + 1 ]
			if ( nextLine and string.len( nextLine ) > 0 and
			     not string.find( nextLine, "[^=]" ) ) then
				self:addHeader( line )
			elseif ( string.find( line, "[^=]" ) ) then
				local name, concommand = string.match( line, "\"(.+)\"%s(.+)" )
				concommand             = string.trim( concommand )
				local key              = bind.getKeyForBind( concommand )
				self:addBinding( name, key or '', concommand )
			end
		end
	end
end

gui.register( bindlistpanel, "bindlistpanel" )
