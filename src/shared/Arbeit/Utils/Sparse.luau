--!strict

export type SparseEntry<T> = {
	index: number,
	id: number,
	value: T,
}

local SparseEntry = {}

function SparseEntry.new<T>(value: T): SparseEntry<T>
	return {
		index = -1,
		id = -1,
		value = value,
	}
end

local SparseMap = {}
SparseMap.__index = SparseMap

export type SparseMap<T> = typeof(setmetatable(
	{} :: {
		dense: { SparseEntry<T> },
		sparse: { SparseEntry<T>? },
		nextId: number,
	},
	SparseMap
))

function SparseMap.new<T>(): SparseMap<T>
	return setmetatable({
		dense = {},
		sparse = {},
		nextId = 0,
	}, SparseMap) :: SparseMap<T>
end

function SparseMap.add<T>(self: SparseMap<T>, entry: SparseEntry<T>): ()
	entry.id = self.nextId
	self.nextId += 1
	entry.index = #self.dense + 1

	self.sparse[entry.id] = entry
	table.insert(self.dense, entry)
end

function SparseMap.remove<T>(self: SparseMap<T>, entry: SparseEntry<T>): ()
	local last = self.dense[#self.dense]
	local idx = entry.index

	self.dense[idx] = last
	last.index = idx

	table.remove(self.dense)
	self.sparse[entry.id] = nil
end

function SparseMap.getById<T>(self: SparseMap<T>, id: number): SparseEntry<T>?
	return self.sparse[id]
end

return {
	SparseEntry = SparseEntry,
	SparseMap = SparseMap,
}
