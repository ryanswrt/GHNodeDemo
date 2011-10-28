--require "debug_unstable"

LG = love.graphics 

goo = require 'goo/goo'
anim = require 'anim/anim'
require "specs"

activeEnt ={}
nodes = {}
drawmode="overview"
--essentially game modes
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
	LG.setColor(white)
	LG.print(j.name..j.id,j.x,j.y-10)
	LG.setColor(j.color)
	LG.circle('fill',j.x,j.y,5)
	
    end
    
    if activeEnt then
	  LG.print(getWantsButtons(activeEnt),400,10)
	  LG.print(getHasButtons(activeEnt),400,30)
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
	    drawmode="node"
	    break	    
	end
	--drawmode="overview"
    end
end
}
}
activeNode = {}
activeNode.entities = {}
activeNode.name = "blank"

function entityTurn(entity)
    calcWants(entity)
    sourceWants(entity)
    makeMakes(entity)
end

function calcWants(entity)
    for r, spec in pairs(entity.makes) do
	if spec.uses then for resource,usesspec in pairs(spec.uses) do
	    if entity.has[usesspec.resource][1]*2 < usesspec.num then
		    print(entity.name .. " wants " .. usesspec.resource) 
		    entity.wants[usesspec.resource][1] = usesspec.num
	    else
		    print(entity.name .. " doesn't want " .. usesspec.resource)
		    entity.wants[usesspec.resource][1] = 0
	    end
	    end
	end	
    end	
    
    if entity.has.food[1]<40 then entity.wants.food[1] = 1 else entity.wants.food[1] = 0 end
end

function sourceWants(entity)
--entity searches through alive local/allied entities to fulfil wants, and then searches through entities wants to find things to trade
    --for node, nents in ipairs(entity.node.links) do this searches through linked nodes, too excessive for the moment, want to restrict it to traders
    for name, data in ipairs(entity.node.entities) do
	for resource, amount in pairs(entity.wants) do
	    if amount[1]>0 and data.has[resource][1] > 0 and data.wants[resource][1]<=data.has[resource][1] and data.id ~= entity.id and data.alive then 
		print(entity.name.." wants "..resource)
		for dresource, damount in pairs(data.wants) do
		    if damount[1]>0 and entity.has[dresource][1] > 0 and entity.wants[dresource][1]*4<=entity.has[dresource][1] and resource ~= dresource then

			entity.has[dresource][1] = entity.has[dresource][1] - 1
			if entity.has[dresource].always then entity.has[dresource][1] = entity.has[dresource][1] + 1 end

			data.has[dresource][1] = data.has[dresource][1] + 1
			
			data.has[resource][1] = data.has[resource][1] - 1

			if data.has[resource].always then data.has[resource][1] = data.has[resource][1] + 1 end
			entity.has[resource][1] = entity.has[resource][1] + 1
			table.insert(data.allies,entity)
			table.insert(entity.allies,data)
			print(entity.name..entity.id.." is swapping "..dresource.." for "..data.name..data.id.."'s "..resource)
			return
		    else
			table.insert(entity.enemies,data)
			for i,j in ipairs(entity.enemies) do print(j.name) end
		    end
		end
	    end
	end
    --end
    end
end

function checkifenemy(entity,enemyid)
    
end

function getWants(entity)
    --formats a string of wants
    local wants = "Wants: "
    for i, j in pairs(entity.wants) do
	if j[1] ~= 0 then wants = wants .. i .. ":" .. j[1] .. " "end
    end
    return wants
    
end

function getWantsButtons(entity)
    --creates a list of buttons
    local wants = "Wants: "
    local x = 0
    for i, j in pairs(entity.wants) do
	if j[1] ~= 0 then 
	    x = x+1
	    local button = goo.button:new(tradepanel)
		button:setPos( 400+x*60, 10 )
		button:setText( i.." "..j[1] )
		button:sizeToText()
		local redStyle = {
		backgroundColor = {255,0,0},
		backgroundColorHover = {125,0,0},
		borderColor = {0,0,0,0},
		borderColorHover = {0,0,0,0},
	}
		button.onClick = function(self,button)
			if button == 'l' then
				self:setStyle( redStyle )
				playertrading = i
				if playergetting and player.has[i][1] > 0 then 
				player.has[playergetting][1]=player.has[playergetting][1]+1
				entity.has[playergetting][1]=entity.has[playergetting][1]-1
				end
			end
		end
	end
    end
    return wants
    
end


function getHas(entity)
    --formats a string of what the entity has
    local has = "Has: "
    for i, j in pairs(entity.has) do
	if j[1] ~= 0 then has = has .. i .. ":" .. j[1] .. " "end
    end
    return has
end

function getHasButtons(entity)
    --formats a string of what the entity has
    local has = "Has: "
    local x = 0
    for i, j in pairs(entity.has) do
	if j[1] ~= 0 then 
	  	    x = x+1
	    local button = goo.button:new(tradepanel)
		button:setPos( 400+x*60, 40 )
		button:setText( i.." "..j[1] )
		button:sizeToText()
		local redStyle = {
		backgroundColor = {255,0,0},
		backgroundColorHover = {125,0,0},
		borderColor = {0,0,0,0},
		borderColorHover = {0,0,0,0},
	}
		button.onClick = function(self,button)
			if button == 'l' then
				print "a"
				self:setStyle( redStyle )
				playergetting = i
				end
		end
	end
    end
    return has
end



function makeMakes(entity)  
    local counter = 0
    
    if entity.has.food[1] < 0 then
	entity.alive = false
    end
    
    --entity produces what they make if they have the prerequisites
    for r, spec in pairs(entity.makes) do
	if spec.uses then for resource,usesspec in pairs(spec.uses) do
	    if entity.has[usesspec.resource][1] > 0 then
	    counter = counter+1
		if counter == #spec.uses then
		    print(entity.name .. " has resources for making" .. r) 
		    entity.has[r][1] = entity.has[r][1] + spec[1]
		    entity.has[usesspec.resource][1]= entity.has[usesspec.resource][1] - usesspec.num
		end
		end
	    end
	end	
    end	    
    

    entity.has.food[1] = entity.has.food[1] -1
    if not entity.has.land.always then entity.has.land[1] = 0 end
end

function love.load()
    math.randomseed( os.time() )
    
    makeNodes(2,50,50)
    linkNodes()
    populateNode(nodes[1],7)
    goo:load()
    
end

function love.update(dt)
	goo:update(dt)
	anim:update(dt)
end

function love.draw()
    goo:draw()
    LG.print("click node to see entities, press 'a' to advance a turn",10,10)
    LG.print("press 's' to return to main map",10,20)
    LG.print("You "..getHas(player),10,500)
    mode[drawmode].draw()    
end

function love.mousepressed(x,y,button)
    mode[drawmode].click(x,y,button)
    goo:mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
	goo:mousereleased( x, y, button )
end

function love.keyreleased( key, unicode )
	goo:keyreleased( key, unicode )
end

function love.keypressed(key)
    goo:keypressed( key, unicode )
    if key == "s" then
      drawmode="overview"
    end
    if key == "a" then
	for x, y in pairs(nodes) do
	    for i, j in pairs(y.entities) do
		if j.alive then
		    entityTurn(j)
		end
	    end
	end
    end
end

function makeNodes(num,xvar,yvar)
    --creates a grid of relatively random nodes and initializes them
    nodes[1] = {x=math.random(20),y=math.random(20), color={math.random(240)+15,math.random(240)+15,math.random(240)+15},links={},entities={},name="origin"}
    for i=1, num do
      makeNode(xvar+math.random(xvar/1.5),i*yvar+math.random(yvar/1.5))
	for j=1, num do
	    makeNode((j+1)*xvar+math.random(xvar/1.2),i*yvar+math.random(yvar/1.2))
	end
    end
end

function makeNode(xi,yi)
    --takes a coordinate and creates a node at that location
    table.insert(nodes,{name=xi,x=xi,y=yi,color={math.random(240)+15,math.random(240)+15,math.random(240)+15},links={},entities={}})
    table.insert(nodes[#nodes].entities,makeEntity("lord",nodes[#nodes]))
    populateNode(nodes[#nodes],12)--math.random(10)+2)
end

function linkNodes()
    --looks through the entire node store and links up to nearby nodes
    for i, j in ipairs(nodes) do
	for k, l in ipairs(nodes) do
	    xd = j.x - l.x
	    yd = j.y - l.y
	    if  xd<60 and xd>-1 and yd<60 and yd>-60 then
		--print(j.x-l.x)
		table.insert(j.links,l)
	    end
	end
    end
end

function makeEntity(class,node)
  local e = deepcopy(entitySpec[class])
  local size = #entityStore
  e.node = node
  e.id = size
  e.x,e.y = math.random((size+1)*10)+50,math.random((size+1)*10)+50
  for i, j in ipairs(nodes) do
      while e.x - j.x < 30 and e.x - j.x > -30 and e.y - j.y < 30 and e.y - j.y > -30 do
	  e.x,e.y = math.random((5)*10)+50,math.random((5)*10)+50
      end
  end
  table.insert(entityStore,e)
  return e
end

function populateNode(node,popi)
  --Inserts a completely random selection of entities into a node
  local pop = 0
  while pop < popi do
      for i, j in pairs(entitySpec) do
	  if math.random(6)>3 then
	      pop = pop + 1
	      table.insert(node.entities,makeEntity(i,node))
	  end
      end  
  end
end

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
