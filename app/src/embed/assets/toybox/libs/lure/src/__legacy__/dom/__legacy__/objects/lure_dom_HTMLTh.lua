function lure.dom.createHTMLThElement()
	local self = lure.dom.nodeObj.new(1)
	
	--===================================================================
	-- PROPERTIES                                                       =
	--===================================================================
	self.tagName 	= "th"
	---------------------------------------------------------------------
	self.nodeName 	= "TH"	
	---------------------------------------------------------------------
	self.nodeDesc	= "HTMLThElement"
	---------------------------------------------------------------------
	self.style		= lure.dom.HTMLNodeStyleobj.new(self)
	---------------------------------------------------------------------
	
	--===================================================================
	-- MUTATORS                                                         =
	--===================================================================
	
	--===================================================================
	-- METHODS	                                                        =	
	--===================================================================
	self.update = function()
		
	end
	---------------------------------------------------------------------
	self.draw = function()
		
	end
	---------------------------------------------------------------------
	
	return self
end