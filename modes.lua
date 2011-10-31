mode = {
overview ={ --when you see all the nodes/cities

draw=function()
    --draws the nodes
    for i, j in ipairs(nodes) do
	LG.setColor(j.color[1],j.color[2],j.color[3])
	if activeNode == j then LG.setColor(255,255,255) end
	LG.circle('fill',j.x,j.y,5)
	--draws the links between nodes
	for k, l in ipairs(j.links) do
	    LG.line(j.x,j.y,l.x,l.y)
	end
    end
    --draws the entities in a node
    LG.print(activeNode.name,400,10)

end,

click=function(x,y,button)
      --checks if there is a node nearby, and makes it active. if not, clears the current node
    activeNode ={}
    activeNode.entities = {}
    activeNode.name = "blank"
    for i, j in ipairs(nodes) do
	if x - j.x < 10 and x - j.x > -10 and y - j.y < 10 and y - j.y > -10 then
	    initNodeShapes(j)
	    activeNode=j
	    drawmode="node"
	end
    end
    activeEnt =nil
    
end
},

node={ --when you are looking at a specific city
draw=function()
    for i, j in ipairs(activeNode.entities) do
	LG.setColor(changeTone(j.color,-30))
	j.house:draw('fill')
	LG.setColor(white)
	LG.print(j.name..j.id,j.x,j.y-10)
	LG.setColor(j.color)
	LG.circle('fill',j.x,j.y,5)
	
    end
    
    if activeEnt then
	  for i,ally in ipairs(activeEnt.allies) do
	      LG.line(activeEnt.x,activeEnt.y,ally.x,ally.y)
	      LG.print(ally.name..ally.id,400,30+i*10)
	  end
	end

end,
click=function(x,y,button)
    
    
    for i, j in ipairs(activeNode.entities) do
	if x - j.x < 10 and x - j.x > -10 and y - j.y < 10 and y - j.y > -10 then
	    if tradepanel then tradepanel:destroy() end
	    tradepanel = goo.panel:new()
	    
	    activeEnt=j
	    getWantsButtons(activeEnt)
	    getHasButtons(activeEnt)
	    drawmode="node"
	    break	    
	end
	--drawmode="overview"
    end
end
}
} 
