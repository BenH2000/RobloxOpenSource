local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local abs,exp=math.abs,math.exp
local v3=Vector3.new
local v3b=v3(0,0,0)

local Flag do
	Flag = {
		MaxSpeed = 16,
		UpdateDelta = 0.3
	}
	local function NoClipThresholdFun(x)
		local a,k=0.147,0.194
		return a*exp(k*x)
	end
	local function SpeedThresholdFun(x)
		local a,k=0.147,0.322
		return a*exp(k*x)
	end
	local function UpdateInterest(PlayerMemory, HumanoidRootPart, dt)
		local nAvgFrame = 2/dt
		
		local Position = HumanoidRootPart.Position
		local LastPosition = PlayerMemory.Position or Position
		local Velocity = HumanoidRootPart.Velocity
		local LastVelocity = PlayerMemory.Velocity or Velocity
		local DispVelocity = (Position-LastPosition)/dt
		
		local Radius = Flag.MaxSpeed*1.5+abs(Velocity.Y+LastVelocity.Y+DispVelocity.Y)/3*2
		Radius = dt*Radius
		
		local AvgVelocity = PlayerMemory.AvgVelocity or v3b
		AvgVelocity = (AvgVelocity*(nAvgFrame-1)+Velocity)/nAvgFrame
		PlayerMemory.AvgVelocity = AvgVelocity
		
		local AvgDispVelocity = PlayerMemory.AvgDispVelocity or v3b
		AvgDispVelocity = (AvgDispVelocity*(nAvgFrame-1)+DispVelocity)/nAvgFrame
		PlayerMemory.AvgDispVelocity = AvgDispVelocity
		
		local u = v3(AvgVelocity.X, 0, AvgVelocity.Z)
		local v = v3(AvgDispVelocity.X, 0, AvgDispVelocity.Z)
		local NoClipThreshold = NoClipThresholdFun((u-v).magnitude)
		
		local Distance = (HumanoidRootPart.Position-LastPosition).magnitude
		local SpeedThreshold = Distance>Radius and SpeedThresholdFun(Distance-Radius) or 0
		
		PlayerMemory.Position = Position
		PlayerMemory.Velocity = Velocity
		PlayerMemory.NoClipThreshold = NoClipThreshold
		PlayerMemory.SpeedThreshold = SpeedThreshold
	end
	local function CalculateResult(PlayerMemory)
		local Result = {}
		if (PlayerMemory.NoClipThreshold >= 1) then
			Result.Bad = true
			Result.NoClip = true
			PlayerMemory.NoClipThreshold = 0
		end
		if (PlayerMemory.SpeedThreshold >= 1) then
			Result.Bad = true
			Result.Speed = true
			PlayerMemory.SpeedThreshold = 0
		end
		return Result
	end
	local BadPlayerQueue = {}
	local function ProcessQueue()
		-- If queue has more than 1 player in it
		-- during this update, clear the queue.
		-- Reasoning being that it's unlikely there
		-- will be multiple exploiters, so maybe
		-- someone teleported a bunch of users.
		if (#BadPlayerQueue == 0) then return end
		if (#BadPlayerQueue > 1) then
			BadPlayerQueue = {}
			return
		end
		local Result = table.remove(BadPlayerQueue, 1)
		local Player = Players:FindFirstChild(Result.PlayerName)
		if (not Player) then return end
		print(Result.PlayerName, 'did something bad.')
	end
	local function IsPlayerInQueue(PlayerName)
		for i=1,#BadPlayerQueue do
			if (BadPlayerQueue[i].PlayerName==PlayerName) then return BadPlayerQueue[i] end
		end
		return false
	end
	local Memory = {}
	local function Update(dt)
		for PlayerName,PlayerMemory in next,Memory do
			local Player = Players:FindFirstChild(PlayerName)
			if (Player) then
				local Character = Player.Character
				if (Character) then
					local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
					if (HumanoidRootPart) then
						UpdateInterest(PlayerMemory, HumanoidRootPart, dt)				
					end
				end
			end
			local Result = CalculateResult(PlayerMemory)
			if (Result.Bad) then
				Result.PlayerName = PlayerName
				if(not IsPlayerInQueue(PlayerName)) then
					table.insert(BadPlayerQueue, Result)
				end
			end
		end
	end
	local function PlayerAdded(Player)
		local PlayerName = Player.Name
		print(PlayerName)
		local PlayerMemory = {
			NoClipThreshold = 0,
			SpeedThreshold = 0,
		}
		Memory[PlayerName] = PlayerMemory
	end
	local function PlayerRemoving(Player)
		local PlayerName = Player.Name
		Memory[PlayerName] = nil
	end
	Players.PlayerAdded:connect(PlayerAdded)
	Players.PlayerRemoving:connect(PlayerRemoving)
	local t=0
	local function Stepped(_,dt)
		t=t+dt
		if (t>=Flag.UpdateDelta) then
			Update(t)
			ProcessQueue()
			t=0
		end
	end
	RunService.Stepped:connect(Stepped)
end
return { Flag = Flag }
