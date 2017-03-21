-- @badccvoid
-- @badccvoid
-- 3/20/2017

-- To Enable:
-- Call Ragdoll on client (first), and RagdollServer on server (second)
--[[ e.g.
	-- CLIENT
	Ragdoll.Ragdoll(Character)
	Event:FireServer('Ragdoll')
	
	-- SERVER
	function OnRagdollEvent(Player)
		Ragdoll.RagdollServer(Player)
	end
--]]

-- To Disable:
-- Call UnragdollServer on the server (first), and Ragdoll on the client (second).
-- Make sure they happen in that order.
--[[ e.g.
	-- CLIENT
	function OnUnragdollEvent()
		Ragdoll.Unragdoll(Character)
	end	
	
	-- SERVER
	Ragdoll.UnragdollServer()
	Event:FireClient('Unragdoll')
--]]

-- So basically, server has to initiate unragdoll event since it has to run UnragdollServer code before 
-- client (otherwise camera will glitch for a frame), but you can send an event from client to initiate.
-- If anyone finds a better way, let me know.

local Ragdoll, Unragdoll, RagdollServer, UnragdollServer, PlayerRemoving do
	local JointParent = {}
	local function RagdollSetup(Character)
		-- Neck
		local NeckConstraint = Instance.new('BallSocketConstraint')
		NeckConstraint.Name = 'RagdollNeck'
		NeckConstraint.Attachment0 = Character.UpperTorso['NeckRigAttachment']
		NeckConstraint.Attachment1 = Character.Head['NeckRigAttachment']
		NeckConstraint.LimitsEnabled = true
		NeckConstraint.UpperAngle = 25
		NeckConstraint.Enabled = false
		NeckConstraint.Parent = Character
		-- Waist
		local WaistConstraint = Instance.new('BallSocketConstraint')
		WaistConstraint.Name = 'RagdollWaist'
		WaistConstraint.Attachment0 = Character.LowerTorso['WaistRigAttachment']
		WaistConstraint.Attachment1 = Character.UpperTorso['WaistRigAttachment']
		WaistConstraint.LimitsEnabled = true
		WaistConstraint.UpperAngle = 5
		WaistConstraint.Enabled = false
		WaistConstraint.Parent = Character
		-- Left Wrist
		local LeftWristConstraint = Instance.new('HingeConstraint')
		LeftWristConstraint.Name = 'RagdollLeftWrist'
		LeftWristConstraint.Attachment0 = Character.LeftLowerArm['LeftWristRigAttachment']
		LeftWristConstraint.Attachment1 = Character.LeftHand['LeftWristRigAttachment']
		LeftWristConstraint.Enabled = false
		LeftWristConstraint.Parent = Character
		-- Right Wrist
		local RightWristConstraint = Instance.new('HingeConstraint')
		RightWristConstraint.Name = 'RagdollRightWrist'
		RightWristConstraint.Attachment0 = Character.RightLowerArm['RightWristRigAttachment']
		RightWristConstraint.Attachment1 = Character.RightHand['RightWristRigAttachment']
		RightWristConstraint.Enabled = false
		RightWristConstraint.Parent = Character
		-- Left Knee
		local LeftKneeConstraint = Instance.new('HingeConstraint')
		LeftKneeConstraint.Name = 'RagdollLeftKnee'
		LeftKneeConstraint.Attachment0 = Character.LeftUpperLeg['LeftKneeRigAttachment']
		LeftKneeConstraint.Attachment1 = Character.LeftLowerLeg['LeftKneeRigAttachment']
		LeftKneeConstraint.LimitsEnabled = true
		LeftKneeConstraint.UpperAngle = 15
		LeftKneeConstraint.LowerAngle = -45
		LeftKneeConstraint.Enabled = false
		LeftKneeConstraint.Parent = Character
		-- Right Knee
		local RightKneeConstraint = Instance.new('HingeConstraint')
		RightKneeConstraint.Name = 'RagdollRightKnee'
		RightKneeConstraint.Attachment0 = Character.RightUpperLeg['RightKneeRigAttachment']
		RightKneeConstraint.Attachment1 = Character.RightLowerLeg['RightKneeRigAttachment']
		RightKneeConstraint.LimitsEnabled = true
		RightKneeConstraint.UpperAngle = 15
		RightKneeConstraint.LowerAngle = -45
		RightKneeConstraint.Enabled = false
		RightKneeConstraint.Parent = Character
		-- Left Ankle
		local LeftAnkleConstraint = Instance.new('HingeConstraint')
		LeftAnkleConstraint.Name = 'RagdollLeftAnkle'
		LeftAnkleConstraint.Attachment0 = Character.LeftLowerLeg['LeftAnkleRigAttachment']
		LeftAnkleConstraint.Attachment1 = Character.LeftFoot['LeftAnkleRigAttachment']
		LeftAnkleConstraint.LimitsEnabled = true
		LeftAnkleConstraint.UpperAngle = 15
		LeftAnkleConstraint.LowerAngle = -45
		LeftAnkleConstraint.Enabled = false
		LeftAnkleConstraint.Parent = Character
		-- Right Ankle
		local RightAnkleConstraint = Instance.new('HingeConstraint')
		RightAnkleConstraint.Name = 'RagdollRightAnkle'
		RightAnkleConstraint.Attachment0 = Character.RightLowerLeg['RightAnkleRigAttachment']
		RightAnkleConstraint.Attachment1 = Character.RightFoot['RightAnkleRigAttachment']
		RightAnkleConstraint.LimitsEnabled = true
		RightAnkleConstraint.UpperAngle = 15
		RightAnkleConstraint.LowerAngle = -45
		RightAnkleConstraint.Enabled = false
		RightAnkleConstraint.Parent = Character
		-- Left Shoulder
		local LeftShoulderConstraint = Instance.new('BallSocketConstraint')
		LeftShoulderConstraint.Name = 'RagdollLeftShoulder'
		LeftShoulderConstraint.Attachment0 = Character.UpperTorso['LeftShoulderRigAttachment']
		LeftShoulderConstraint.Attachment1 = Character.LeftUpperArm['LeftShoulderRigAttachment']
		LeftShoulderConstraint.Enabled = false
		LeftShoulderConstraint.Parent = Character
		-- Right Shoulder
		local RightShoulderConstraint = Instance.new('BallSocketConstraint')
		RightShoulderConstraint.Name = 'RagdollRightShoulder'
		RightShoulderConstraint.Attachment0 = Character.UpperTorso['RightShoulderRigAttachment']
		RightShoulderConstraint.Attachment1 = Character.RightUpperArm['RightShoulderRigAttachment']
		RightShoulderConstraint.Enabled = false
		RightShoulderConstraint.Parent = Character
		-- Left Elbow
		local LeftElbowConstraint = Instance.new('BallSocketConstraint')
		LeftElbowConstraint.Name = 'RagdollLeftElbow'
		LeftElbowConstraint.Attachment0 = Character.LeftUpperArm['LeftElbowRigAttachment']
		LeftElbowConstraint.Attachment1 = Character.LeftLowerArm['LeftElbowRigAttachment']
		LeftElbowConstraint.Enabled = false
		LeftElbowConstraint.Parent = Character
		-- Right Elbow
		local RightElbowConstraint = Instance.new('BallSocketConstraint')
		RightElbowConstraint.Name = 'RagdollRightElbow'
		RightElbowConstraint.Attachment0 = Character.RightUpperArm['RightElbowRigAttachment']
		RightElbowConstraint.Attachment1 = Character.RightLowerArm['RightElbowRigAttachment']
		RightElbowConstraint.Enabled = false
		RightElbowConstraint.Parent = Character
		-- Left Hip
		local LeftHipConstraint = Instance.new('BallSocketConstraint')
		LeftHipConstraint.Name = 'RagdollLeftHip'
		LeftHipConstraint.Attachment0 = Character.LowerTorso['LeftHipRigAttachment']
		LeftHipConstraint.Attachment1 = Character.LeftUpperLeg['LeftHipRigAttachment']
		LeftHipConstraint.Enabled = false
		LeftHipConstraint.Parent = Character
		-- Right Hip
		local RightHipConstraint = Instance.new('BallSocketConstraint')
		RightHipConstraint.Name = 'RagdollRightHip'
		RightHipConstraint.Attachment0 = Character.LowerTorso['RightHipRigAttachment']
		RightHipConstraint.Attachment1 = Character.RightUpperLeg['RightHipRigAttachment']
		RightHipConstraint.Enabled = false
		RightHipConstraint.Parent = Character
	end
	local function EnableHumanoid(Humanoid, b)
		for _,v in next,Enum.HumanoidStateType:GetEnumItems() do
			if (v ~= Enum.HumanoidStateType.None and v ~= Enum.HumanoidStateType.Dead) then
				Humanoid:SetStateEnabled(v, b)
			end
		end
	end
	function Ragdoll(Character)
		local Humanoid = Character:FindFirstChild('Humanoid')
		if (not Humanoid) then return end
		local Camera = workspace.CurrentCamera
		Camera.CameraSubject = Character['UpperTorso']
		EnableHumanoid(Humanoid, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	end
	function Unragdoll(Character)
		local Humanoid = Character:FindFirstChild('Humanoid')
		if (not Humanoid) then return end
		local Camera = workspace.CurrentCamera
		Camera.CameraSubject = Humanoid
		EnableHumanoid(Humanoid, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
	function RagdollServer(Player)
		local PlayerName = Player.Name
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild('Humanoid')
		if (not Humanoid) then return end
		local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
		if (not HumanoidRootPart) then return end
		local mJointParent = JointParent[PlayerName]
		if (not mJointParent) then mJointParent = {} JointParent[PlayerName] = mJointParent end
		Character.UpperTorso:SetNetworkOwner(Player)
		for _,v in next,Character:GetChildren() do
			if (v:IsA('BasePart')) then
				for _,u in next,v:GetChildren() do
					if (u:IsA('Motor')) then mJointParent[u] = u.Parent u.Parent = nil end
				end
			elseif (v:IsA('Accessory')) then
				v.Handle.CanCollide = false
			end
		end
		local RagdollNeck = Character:FindFirstChild('RagdollNeck')
		if (not RagdollNeck) then RagdollSetup(Character) end
		for _,v in next,Character:GetChildren() do
			if (v:IsA('Constraint')) then 
				v.Enabled = true 
			end
		end
	end
	function UnragdollServer(Player)
		local PlayerName = Player.Name
		local Character = Player.Character
		local RagdollNeck = Character:FindFirstChild('RagdollNeck')
		if (not RagdollNeck) then return end
		local mJointParent = JointParent[PlayerName]
		if (not mJointParent) then return end
		local Humanoid = Character:FindFirstChild('Humanoid')
		if (not Humanoid) then return end
		local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
		if (not HumanoidRootPart) then return end
		HumanoidRootPart.CFrame = Character['UpperTorso'].CFrame
		HumanoidRootPart.Velocity = Vector3.new(0,0,0)
		
		for Motor,Parent in next,mJointParent do Motor.Parent = Parent end
		JointParent[PlayerName] = nil
		for _,v in next,Character:GetChildren() do
			-- NOTE(alex): For some reason in a server re-enabling causes 
			-- them to spaz out, so just.. remake them every time.
--			if (v:IsA('Constraint')) then v.Enabled = false end
			if (v:IsA('Constraint')) then v:Destroy() end
		end
		return true
	end
	function PlayerRemoving(PlayerName)
		JointParent[PlayerName] = nil
	end
end
return { Ragdoll = Ragdoll, Unragdoll = Unragdoll, RagdollServer = RagdollServer, UnragdollServer = UnragdollServer, PlayerRemoving = PlayerRemoving }