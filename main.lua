LG = love.graphics 
nodes = {}

activeNode = {}
activeNode.entities = {}
activeNode.name = "blank"

entitySpec = {
    farmer = {has={0},wants={0},makes={0}},
    woodcutter = {has={0},wants={0},makes={0}},
    merchant = {has={},wants={},makes={}},
    miner = {has={},wants={},makes={}},
    smith = {has={},wants={},makes={}},
    lord = {has={0},wants={0},makes={0}}}

entityStore ={}

function initiateEntities()
    --base spec for every entity
    for i, j in pairs(entitySpec) do
	--print(i)
	j.name = i
	j.has={food={1},land={0},wood={0},gold={1},stone={0},ore={0},iron={0}}
	j.wants={food={1},land={0},wood={0},gold={0},stone={0},ore={0},iron={0}}
	j.makes={food={0},land={0},wood={0},gold={0},stone={0},ore={0},iron={0}}
	j.allies={}
	j.node={}
    end
    --print(entitySpec.farmer.name)
    
    entitySpec.farmer.wants.land={1}
    entitySpec.farmer.makes.food={4}
    
    entitySpec.lord.has.land={always=true,4}
    
    entitySpec.woodcutter.wants.land={1}
    entitySpec.woodcutter.makes.wood={4}
    
    entitySpec.miner.wants.land={1}
    entitySpec.miner.makes.stone={chance=50,4}
    entitySpec.miner.makes.ore={chance=50,2}
    
    entitySpec.smith.wants.ore={2}
    entitySpec.smith.makes.iron={1}
    
    for resource, value in pairs(entitySpec.merchant.wants) do
	if value[1] ~= 0 then
	    value[1] = 1
	end
    end
    
    entitySpec.merchant.makes.gold = {any=true,value=true}
    
end

function entityTurn(entity)
    getWants(entity)
    makeMakes(entity)
end

function getWants(entity)
    local wants = ""
    for i, j in pairs(entity.wants) do
	if j[1] ~= 0 then wants = wants .. i .. ":" .. j[1] .. " "end
    end
    return wants
    --entity searches through local/allied entities to fulfil wants
--     for name, data in ipairs(entity.node) do
-- 	for resource, amount in ipairs(entity.wants) do
-- 	    if data.has["resource"] ~= 0 and data.wants["resource"]=0 then
--	       
--	    end
-- 	end
--     end
end

function makeMakes(entity)
   --entity produces what they make if they have the prerequisites

end

function love.load()
    math.randomseed( os.time() )
    
    initiateEntities()
    makeNodes(5,50,50)
    linkNodes()
    populateNode(nodes[1],7)
    
end

function love.draw()
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
    LG.print(activeNode.name,400,25)
    for i, j in ipairs(activeNode.entities) do
	LG.setColor(255,255,255)
	LG.print(j.name.."  "..getWants(j),400,i*25+25)
	
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
    populateNode(nodes[#nodes],math.random(10)+2)
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
	  if math.random(6)>2 then
	      print(j)
	      pop = pop + 1
	      table.insert(entityStore,j)
	      entityStore[#entityStore].node=node
	      table.insert(node.entities,entityStore[#entityStore])
	  end
      end  
  end
end