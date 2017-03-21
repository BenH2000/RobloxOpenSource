-- @badccvoid
-- @badccvoid
-- I wrote this a few years ago. It's not very optimized. I'm not happy with the API.
-- I haven't used it in a while. But maybe somehow it's useful to someone.

--[[
	@name Cluster
	@desc Clustering algorithm. Originally authored by @BadccVoid. Optimizations?
	
	@example_usage Cluster.Query({Vector3.new(), Vector3.new()}):Within(20):GetCenters() --> { Vector3.new() }
	@example_usage Cluster.Query({Vector3.new(), Vector3.new()}):Within(4):GetClusters() --> { { Vector3.new(), Vector3.new() } }
]]
-- Source	
local Cluster = {}
Cluster.__index = Cluster
function Cluster.Query(Points)
	-- @arg Points { [ Vector3 ], ... }
	-- @ret Cluster
	return setmetatable({ Points = Points }, Cluster)
end
function Cluster:Within(Radius)
	-- @arg Radius [ atomic integer ] studs
	-- @ret Cluster
	local Points = self.Points
	local Clusters = { }
	for PointIndex = 1, #Points do
		local Point = Points[PointIndex]
		local PointAlreadyInCluster = false
		for _,Cluster in next,Clusters do
			if (PointAlreadyInCluster) then break end
			for _,Point2 in next,Cluster do
				if (Point == Point2) then
					PointAlreadyInCluster = true
					break
				end
			end
		end
		if (not PointAlreadyInCluster) then
			local Cluster = { Point }
			for PointIndex2 = PointIndex + 1, #Points do
				local Point2 = Points[PointIndex2]
				local Distance = (Point - Point2).magnitude
				if (Distance <= Radius) then
					table.insert(Cluster, Point2)
				end
			end
			table.insert(Clusters, Cluster)
		end
	end
	self.Clusters = Clusters
	return self
end
function Cluster:GetClusters()
	-- @ret { { [ Vector3 ], ... }, ... }
	return self.Clusters
end
function Cluster:GetCenters()
	-- @ret { [ Vector3 ], ... }
	local Centers = { }
	for _,Cluster in next,self.Clusters do
		local Sum = Cluster[1]
		for PointIndex = 2, #Cluster do
			Sum = Sum + Cluster[PointIndex]
		end
		local Center = Sum / #Cluster
		table.insert(Centers, Center)
	end
	return Centers
end

return Cluster
