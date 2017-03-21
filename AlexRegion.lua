-- @badccvoid
-- @badccvoid
-- Fast.
-- Supports multiple rotated prisms.
-- Has event support.

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local m = require(ReplicatedStorage.Module['Math'])

local v3,cf,cfa = Vector3.new,CFrame.new,CFrame.Angles
local v3b,cfb = v3(0,0,0),cf()
local ptos = cfb.pointToObjectSpace
local insert,remove = table.insert,table.remove

local function MakePrism()
	return {
		c = nil, -- CFrame
		s = nil  -- Size
	}
end
local function MakeRegion()
	return {
		Prisms = {},
		Objects = {},
		ObjectsFastIndex = {}, -- Fast, but uses extra memory.
		ObjectAdded = nil,
		ObjectRemoved = nil,
		IsInRegion = nil,
	}
end
local function CastPoint(Prism,p)
	local c,s=Prism.c,Prism.s
	local r=ptos(c,p)+s*0.5
	return r.x>=0 and r.x<s.x and r.y>=0 and r.y<s.y and r.z>=0 and r.z<s.z
end
local function RegionCastPoint(Region,p)
	local ps=Region.Prisms
	for i=1,#ps do
		local b=CastPoint(ps[i],p)
		if (not b) then return false end
	end
	return true
end
local function IsInRegionPlayer(Player,Region)
	local Character = Player.Character
	if (not Character) then return false end
	local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
	if (not HumanoidRootPart) then return false end
	return RegionCastPoint(Region,HumanoidRootPart.Position)
end
local function Update(r,ps)
	local IsInRegion,ObjectsFastIndex,Objects = r.IsInRegion,r.ObjectsFastIndex,r.Objects
	for i=1,#ps do
--	for _,p in next,ps do
		local p=ps[i]
		local InRegion=IsInRegion(p,r)
		local InTable=ObjectsFastIndex[p.Name]
		if (InRegion and not InTable) then
			table.insert(Objects, p.Name)
			ObjectsFastIndex[p.Name] = #Objects
			if (r.ObjectAdded) then r.ObjectAdded(p, r) end
		elseif (not InRegion and InTable) then
			local i=ObjectsFastIndex[p.Name]
			local SwapObject=Objects[#Objects]
			Objects[#Objects]=Objects[i]
			Objects[i]=SwapObject
			ObjectsFastIndex[SwapObject]=i
			ObjectsFastIndex[p.Name]=nil
			table.remove(Objects)
			if (r.ObjectRemoved) then r.ObjectRemoved(p, r) end
		end
	end
end

return { MakePrism=MakePrism, MakeRegion=MakeRegion, Update=Update, RegionCastPoint=RegionCastPoint, CastPoint=CastPoint, IsInRegionPlayer=IsInRegionPlayer }