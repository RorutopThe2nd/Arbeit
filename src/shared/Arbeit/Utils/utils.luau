local util = {}
function util.getActiveIndices(bucketArray: { [number]: any })
	local indices: { number } = {}

	for key, _ in pairs(bucketArray) do
		table.insert(indices, key)
	end

	table.sort(indices)

	return indices
end

return util
