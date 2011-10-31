red={255,50,50}
green={50,255,50}
blue={50,50,255}
grey={200,200,200}
yellow={250,250,50}
brown={200,120,50}
white={255,255,255}

redStyle = {
backgroundColor = {255,0,0},
backgroundColorHover = {125,0,0},
borderColor = {0,0,0,0},
borderColorHover = {0,0,0,0},
}

defaultStyle = {
backgroundColor = {100,100,100},
backgroundColorHover = {125,0,0},
borderColor = {0,0,0,0},
borderColorHover = {0,0,0,0},
}


player={
has={food={40},land={0}, swords={0},wood={0},gold={10},stone={0},ore={0},iron={0}, tools={0}}
}

entitySpec = {
    farmer = {has={},wants={},makes={}},
    woodcutter = {has={},wants={},makes={}},
    merchant = {has={},wants={},makes={}},
    miner = {has={},wants={},makes={}},
    smith = {has={},wants={},makes={}},
    smelter = {has={},wants={},makes={}},
    lord = {has={},wants={},makes={}}}

entityStore ={}


--base spec for every entity
for i, j in pairs(entitySpec) do
    --print(i)
    j.name = i
    j.id = 1
    j.alive = true
    j.x, j.y = 0,0
    j.has={food={40},land={0}, swords={0},wood={0},gold={10},stone={0},ore={0},iron={0}, tools={1}}
    j.wants={land={0},swords={0},wood={0},gold={1},stone={0},ore={0},iron={0}, tools={0},food={1}}
    j.makes={food={0},land={0},wood={0},gold={0},stone={0},ore={0},iron={0}, tools={0}, swords={0}}
    j.allies={}
    j.enemies={}
    
    j.node={}
    j.color=white
    j.draw=function(self) LG.setColor(j.color) LG.circle("fill",j.x,j.y,5) end
end
--print(entitySpec.farmer.name)

entitySpec.farmer.color=green
entitySpec.farmer.wants.land={1}
entitySpec.farmer.wants.tools={1}
entitySpec.farmer.makes.food={uses={{resource="land",num=1},{resource="tools",num=1}},8}

entitySpec.lord.color=yellow
entitySpec.lord.has.land={always=true,8}

entitySpec.woodcutter.color=brown
entitySpec.woodcutter.wants.land={1}
entitySpec.woodcutter.wants.tools={1}
entitySpec.woodcutter.makes.wood={uses={{resource="land",num=1},{resource="tools",num=1}},4}

entitySpec.miner.color=grey
entitySpec.miner.wants.land={1}
entitySpec.miner.wants.tools={1}
entitySpec.miner.makes.ore={uses={{resource="land",num=1},{resource="tools",num=1}},chance=50,2}
--entitySpec.miner.makes.stone={uses={{resource="land",num=1},{resource="tools",num=1}},chance=50,4}


entitySpec.smelter.color=red
entitySpec.smelter.wants.ore={1}
entitySpec.smelter.makes.iron={uses={{resource="ore",num=1},{resource="tools",num=1}},1}

entitySpec.smith.wants.iron={1}
entitySpec.smith.wants.wood={1}
entitySpec.smith.makes.tools={uses={{resource="iron",num=1},{resource="wood",num=1}},4}
entitySpec.smith.makes.swords={uses={{resource="iron",num=1},{resource="wood",num=1}},4}

entitySpec.merchant.color=blue
for resource, value in pairs(entitySpec.merchant.wants) do
    if value[1] ~= 0 then
	value[1] = 1
    end
end

for resource, value in pairs(entitySpec.lord.wants) do
    if value[1] ~= 0 then
	value[1] = 1
    end
end

entitySpec.merchant.has.gold={100}
    
