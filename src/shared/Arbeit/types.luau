export type function Partial<T>(ty: type)
	if not ty:is("table") then
		error("Partial<T> can only be used with table types")
	end

	local result = types.newtable()

	for key, prop in ty:properties() do
		local readOpt = if prop.read then types.optional(prop.read) else nil
		local writeOpt = if prop.write then types.optional(prop.write) else nil

		-- Preserve read/write symmetry when possible so the output doesn't
		-- unnecessarily split into separate read/write properties
		if readOpt and writeOpt and prop.read == prop.write then
			result:setproperty(key, readOpt)
		else
			if readOpt then
				result:setreadproperty(key, readOpt)
			end
			if writeOpt then
				result:setwriteproperty(key, writeOpt)
			end
		end
	end

	-- Note: Table indexers and metatables can't be read via the current
	-- type API, so they aren't preserved here. This only affects edge cases.

	return result
end

return {}
