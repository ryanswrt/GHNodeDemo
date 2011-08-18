LG = love.graphics 
nodes = {}

activeNode = {}
activeNode.entities = {}
activeNode.name = "blank"

entitySpec = {
    farmer = {has={},wants={},makes={}},
    woodcutter = {has={},wants={},makes={}},
    merchant = {has={},wants={},makes={}},
    miner = {has={},wants={},makes={}},
    smith = {has={},wants={},makes={}},
    smelter = {has={},wants={},makes={}},
    lord = {has={},wants={},makes={}}}

entityStore ={}

function initiateEntities()
    --base spec for every entity
    for i, j in pairs(entitySpec) do
	--print(i)
	j.name = i
	j.id = 1
	j.alive = true
	j.has={food={40},land={0},wood={0},gold={10},stone={0},ore={0},iron={0}, tools={1}}
	j.wants={land={0},wood={0},gold={1},stone={0},ore={0},iron={0}, tools={0},food={1}}
	j.makes={food={0},land={0},wood={0},gold={0},stone={0},ore={0},iron={0}, tools={0}}
	j.allies={}
	j.node={}
    end
    --print(entitySpec.farmer.name)
    
    entitySpec.farmer.wants.land={1}
    entitySpec.farmer.wants.tools={1}
    entitySpec.farmer.makes.food={uses={{resource="land",num=1},{resource="tools",num=1}},4}
    
    entitySpec.lord.has.land={always=true,4}
    
    entitySpec.woodcutter.wants.land={1}
    entitySpec.woodcutter.wants.tools={1}
    entitySpec.woodcutter.makes.wood={uses={{resource="land",num=1},{resource="tools",num=1}},4}
    
    entitySpec.miner.wants.land={1}
    entitySpec.miner.wants.tools={1}
    entitySpec.miner.makes.stone={uses={{resource="land",num=1},{resource="tools",num=1}},chance=50,4}
    entitySpec.miner.makes.ore={uses={{resource="land",num=1},{resource="tools",num=1}},chance=50,2}
    
    entitySpec.smelter.wants.ore={1}
    entitySpec.smelter.makes.iron={uses={{resource="ore",num=1},{resource="tools",num=1}},1}
    
    entitySpec.smith.wants.iron={1}
    entitySpec.smith.wants.wood={1}
    entitySpec.smith.makes.tools={uses={{resource="iron",num=1},{resource="wood",num=1}},4}
    
    for resource, value in pairs(entitySpec.merchant.wants) do
	if value[1] ~= 0 then
	    value[1] = 1
	end
    end
    
    entitySpec.merchant.has.gold={100}
    
end

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
    
    if entity.has.food[1]<4 then entity.wants.food[1] = 1 else entity.wants.food[1] = 0 end
end

function sourceWants(entity)
--entity searches through alive local/allied entities to fulfil wants, and then searches through entities wants to find things to trade
    for name, data in ipairs(entity.node.entities) do
	for resource, amount in pairs(entity.wants) do
	    if amount[1]>0 and data.has[resource][1] > 0 and data.wants[resource][1]<=data.has[resource][1] and data.id ~= entity.id and data.alive then 
		for dresource, damount in pairs(data.wants) do
		    if damount[1]>0 and entity.has[dresource][1] > 0 and entity.wants[dresource][1]<=entity.has[dresource][1] and resource ~= dresource then
			

			entity.has[dresource][1] = entity.has[dresource][1] - 1
			if entity.has[dresource].always then entity.has[dresource][1] = entity.has[dresource][1] + 1 end

			data.has[dresource][1] = data.has[dresource][1] + 1
			
			data.has[resource][1] = data.has[resource][1] - 1

			if data.has[resource].always then data.has[resource][1] = data.has[resource][1] + 1 end
			entity.has[resource][1] = entity.has[resource][1] + 1
			
			print(entity.name..entity.id.." is swapping "..dresource.." for "..data.name..data.id.."'s "..resource)
			return
		    end
		end
	    end
	end
    end
end

function getWants(entity)
    --formats a string of wants
    local wants = "Wants: "
    for i, j in pairs(entity.wants) do
	if j[1] ~= 0 then wants = wants .. i .. ":" .. j[1] .. " "end
    end
    return wants
    
end

function getHas(entity)
    --formats a string of wants
    local has = "Has: "
    for i, j in pairs(entity.has) do
	if j[1] ~= 0 then has = has .. i .. ":" .. j[1] .. " "end
    end
    return has
end

function makeMakes(entity)  
    local counter = 0
    entity.has.food[1] = entity.has.food[1] -1
    if not entity.has.land.always then entity.has.land[1] = 0 end
    --print(entity.name.." "..entitySpec[entity.name].has.land[1])
    --entity.has.land[1] = entitySpec[entity.name].has.land[1]
    if entity.has.food[1] < 0 then
	entity.alive = false
    end
    --entity produces what they make if they have the prerequisites
    for r, spec in pairs(entity.makes) do
	if spec.uses then for resource,usesspec in pairs(spec.uses) do
	    if entity.has[usesspec.resource] ~= 0 then
	    counter = counter+1
		if counter == #spec.uses then
		    print(entity.name .. " has resources for making" .. r) 
		    entity.has[usesspec.resource][1] = entity.has[usesspec.resource][1] + spec[1]
		    entity.has[usesspec.resource][1]= entity.has[usesspec.resource][1] - usesspec.num
		end
		end
	    end
	end	

    end	


end

function love.load()
    math.randomseed( os.time() )
    
    initiateEntities()
    makeNodes(2,50,50)
    linkNodes()
    populateNode(nodes[1],7)
    
end

function love.draw()
    LG.print("click node to see entities, press a to advance a turn",10,10)
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
    for i, j in ipairs(activeNode.entities) do
	LG.setColor(255,255,255)
	LG.print(j.name..j.id,400,(i-1)*50+25)
	LG.print(getWants(j),490,(i-1)*50+25)
	LG.print(getHas(j),490,(i-1)*50+50)
    end
end

function love.mousepressed(x,y,button)
    --checks if there is a node nearby, and makes it active. if not, clears the current node
    activeNode ={}
    activeNode.entities = {}
    activeNode.name = "blank"
    for i, j in ipairs(nodes) do
	if x - j.x < 10 and x - j.x > -10 and y - j.y < 10 and y - j.y > -10 then
	    activeNode=j
	end
    end
    
    
end

function love.keypressed(key)
    if key == "a" then
	for x, y in pairs(nodes) do
	    for i, j in pairs(y.entities) do
		print(j.id)
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
    populateNode(nodes[#nodes],16)--math.random(10)+2)
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
  e.node = node
  e.id = #entityStore
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
