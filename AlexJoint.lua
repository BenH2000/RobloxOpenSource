-- @badccvoid
-- @badccvoid
-- Joint v2
local JointsService = game:GetService('JointsService')
local v3,cf=Vector3.new,CFrame.new
local v3b,cfb=v3(0,0,0),cf(0,0,0)
local tos = cfb.toObjectSpace

local function Custom(Type, Part0, Part1, C0, C1)
	local Joint = Instance.new(Type)
	Joint.Part0 = Part0
	Joint.Part1 = Part1
	Joint.C0 = C0
	Joint.C1 = C1
	Joint.Parent = JointsService
	return Joint
end
local function CustomWeld(Part0, Part1, C0, C1)
	return Custom('Weld', Part0, Part1, C0, C1)
end
local function CustomMotor(Part0, Part1, C0, C1)
	return Custom('Motor', Part0, Part1, C0, C1)
end
local function BlankWeld(Part0, Part1)
	return CustomWeld(Part0, Part1, cfb, cfb)
end
local function BlankMotor(Part0, Part1)
	return CustomMotor(Part0, Part1, cfb, cfb)
end
local function Weld(Part0, Part1)
	return CustomWeld(Part0, Part1, tos(Part0.CFrame, Part1.CFrame), cfb)
end
local function Motor(Part0, Part1)
	return CustomMotor(Part0, Part1, tos(Part0.CFrame, Part1.CFrame), cfb)
end
local function WeldAllTo(m, p, NoRecurse)
	local Welds = {}
	for _,v in next,m:GetChildren() do
		if (not NoRecurse) then
			for _,w in next,WeldAllTo(v, p, NoRecurse) do
				table.insert(Welds, w)
			end
		end
		if (v:IsA('BasePart') and v ~= p) then
			local w = Weld(v, p)
			table.insert(Welds, w)
			v.Anchored = false
		end
	end
	p.Anchored = false
	return Welds
end
return { CustomWeld = CustomWeld, CustomMotor = CustomMotor, BlankWeld = BlankWeld, BlankMotor = BlankMotor, Weld = Weld, Motor = Motor, WeldAllTo = WeldAllTo }