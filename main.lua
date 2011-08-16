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
    lord = {has={},wants={},makes={}}}

entityStore ={}

function initiateEntities()
    --base spec for every entity
    for i, j in pairs(entitySpec) do
	--print(i)
	j.name = i
	j.id = ""
	j.alive = true
	j.has={food={40},land={0},wood={0},gold={10},stone={0},ore={0},iron={0}}
	j.wants={food={1},land={0},wood={0},gold={1},stone={0},ore={0},iron={0}}
	j.makes={food={0},land={0},wood={0},gold={0},stone={0},ore={0},iron={0}}
	j.allies={}
	j.node={}
    end
    --print(entitySpec.farmer.name)
    
    entitySpec.farmer.wants.land={1}
    entitySpec.farmer.makes.food={uses={resource="land",num=1},4}
    
    entitySpec.lord.has.land={always=true,4}
    
    entitySpec.woodcutter.wants.land={1}
    entitySpec.woodcutter.makes.wood={uses={resource="land",num=1},4}
    
    entitySpec.miner.wants.land={1}
    entitySpec.miner.makes.stone={uses={resource="land",num=1},chance=50,4}
    entitySpec.miner.makes.ore={uses={resource="land",num=1},chance=50,2}
    
    entitySpec.smith.wants.ore={1}
    entitySpec.smith.makes.iron={uses={resource="ore",num=2},1}
    
    for resource, value in pairs(entitySpec.merchant.wants) do
	if value[1] ~= 0 then
	    value[1] = 1
	end
    end
    
    entitySpec.merchant.has.gold={100}
    
end

function entityTurn(entity)
    sourceWants(entity)
    makeMakes(entity)
end

function sourceWants(entity)
--entity searches through alive local/allied entities to fulfil wants, and then searches through entities wants to find things to trade
    for name, data in ipairs(entity.node.entities) do
    --print("checking "..name)
	for resource, amount in pairs(entity.wants) do
	    --print(entity.name .. " wants "..amount[1] .. resource)
	    if amount[1]>0 and data.has[resource][1] > 0 and data.wants[resource][1]<=data.has[resource][1] and data.id ~= entity.id and data.alive then
	      --print(name .. " has wants for " .. entity.name) 
		for dresource, damount in pairs(data.wants) do
		    if damount[1]>0 and entity.has[dresource][1] > 0 and entity.wants[dresource][1]<=entity.has[dresource][1] and resource ~= dresource then
			
			--if entity.has[dresource].always then
			--    entity.has[dresource][1] = entitySpec[entity.name].has[dresource][1]
			--else
			entity.has[dresource][1] = entity.has[dresource][1] - 1
			if entity.has[dresource].always then entity.has[dresource][1] = entity.has[dresource][1] + 1 end
			--end
			data.has[dresource][1] = data.has[dresource][1] + 1
			
			--if data.has[resource].always then
			--    data.has[resource][1] = entitySpec[data.name].has[resource][1]
			--else
			data.has[resource][1] = data.has[resource][1] - 1
			--end
			if data.has[resource].always then data.has[resource][1] = data.has[resource][1] + 1 end
			entity.has[resource][1] = entity.has[resource][1] + 1
			
			print(entity.name..entity.id.." is swapping "..dresource.." for "..data.name..data.id.."'s "..resource)
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
    print("gotcalled")
    --entity produces what they make if they have the prerequisites
    for resource, spec in pairs(entity.makes) do
	if spec.uses then
	    if entity.has[spec.uses.resource][1] ~= 0 then
	       print(entity.name .. " has resources for making" .. resource) 
	       entity.has[resource][1] = entity.has[resource][1] + spec[1]
	       entity.has[spec.uses.resource][1] = entity.has[spec.uses.resource][1] - spec.uses.num
	    end
	end
    end
    entity.has.food[1] = entity.has.food[1] -1
    if not entity.has.land.always then entity.has.land[1] = 0 end
    --print(entity.name.." "..entitySpec[entity.name].has.land[1])
    --entity.has.land[1] = entitySpec[entity.name].has.land[1]
    if entity.has.food[1] < 0 then
	entity.alive = false
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
	for i, j in pairs(entityStore) do
	    --print(i)
	    if j.alive then
		entityTurn(j)
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
    table.insert(nodes,{name=xi,x=xi,y=yi,color={math.random(240)+15,math.random(240)+15,math.random(240)+15},links={},entities={entitySpec.lord}})
    populateNode(nodes[#nodes],4)--math.random(10)+2)
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

function populateNode(node,popi)
  --Inserts a completely random selection of entities into a node
  local pop = 0
  while pop < popi do
      for i, j in pairs(entitySpec) do
	  if math.random(6)>3 then
	      pop = pop + 1
	      local copy = j
	      copy.id = #entityStore
	      table.insert(entityStore,copy)
	      entityStore[#entityStore].node=node
	      table.insert(node.entities,entityStore[#entityStore])
	  end
      end  
  end
end