local PlacementConfig = require(script.Parent.Parent.Config.PlacementConfig)
local Paths = require(script.Parent.Parent.Config.Paths)

local PlacementUtil = {}

function PlacementUtil.SnapToGrid(position)
	local grid = PlacementConfig.GridSize

	return Vector3.new(
		math.floor(position.X / grid + 0.5) * grid,
		PlacementConfig.TurretY,
		math.floor(position.Z / grid + 0.5) * grid
	)
end

function PlacementUtil.IsInsideBounds(position)
	return position.X >= PlacementConfig.MinX
		and position.X <= PlacementConfig.MaxX
		and position.Z >= PlacementConfig.MinZ
		and position.Z <= PlacementConfig.MaxZ
end

local function distancePointToSegment(point, a, b)
	local ab = b - a
	local ap = point - a

	local t = ap:Dot(ab) / ab:Dot(ab)
	t = math.clamp(t, 0, 1)

	local closest = a + ab * t

	return (point - closest).Magnitude
end

function PlacementUtil.DistanceFromPath(position)
	local minDistance = math.huge
	local points = Paths.MainPath

	for i = 1, #points - 1 do
		local distance = distancePointToSegment(position, points[i], points[i + 1])

		if distance < minDistance then
			minDistance = distance
		end
	end

	return minDistance
end

function PlacementUtil.IsValidTurretPosition(position)
	local snapped = PlacementUtil.SnapToGrid(position)

	if not PlacementUtil.IsInsideBounds(snapped) then
		return false, snapped, "outside_bounds"
	end

	if PlacementUtil.DistanceFromPath(snapped) < PlacementConfig.MinDistanceFromPath then
		return false, snapped, "too_close_to_path"
	end

	return true, snapped, nil
end

return PlacementUtil