--!strict
local Sparse = require("./Utils/Sparse")
local utils = require("./Utils/utils")

type Fn<A...> = (A...) -> ()
type LifecycleType = "DYNAMIC"|"DIRECT"

type Bucket<A...> = Sparse.SparseMap<Fn<A...>>
type FnIndexEntry<A...> = Sparse.SparseEntry<Fn<A...>>

type ILifecycle<A...> = {
	name: string,
	buckets: { [number]: Bucket<A...> },
	bucketIndices: { number },
	_fnIndexes:{[Fn<A...>]: FnIndexEntry<A...> }
}
export type Lifecycle<A...> = ILifecycle<A...> & {
	rebuildBuckets: (self: Lifecycle<A...>) -> (),
	subscribe: (self: Lifecycle<A...>, bucket: number, fn: Fn<A...>) -> () ,
	unsubscribe: (self: Lifecycle<A...>, bucket: number, entry: Fn<A...> )->(),
	fireAll: (self: Lifecycle<A...>, A...) -> (),
}

local LifecycleClass = {}
LifecycleClass.__index = LifecycleClass

function LifecycleClass.new<A...>(name: string): Lifecycle<A...>
	local self = setmetatable(
		{
			name = name,
			buckets = {},
			bucketIndices = {},
			_fnIndexes = {}
		} :: ILifecycle<A...>,
		LifecycleClass
	) :: Lifecycle<A...>

	return self
end

function LifecycleClass.rebuildBuckets<A...>(self: Lifecycle<A...>) -- called after initiation of Service,Controller, and Component are finished inside the loader
	self.bucketIndices = utils.getActiveIndices(self.buckets)
end

function LifecycleClass.subscribe<A...>(self: Lifecycle<A...>, bucket: number, fn: Fn<A...>)
	self.buckets[bucket] = self.buckets[bucket] or Sparse.SparseMap.new<<Fn<A...>>>()

	local entry = Sparse.SparseEntry.new(fn)
	self.buckets[bucket]:add(entry)
	self._fnIndexes[fn] = entry
end

function LifecycleClass.unsubscribe<A...>(self: Lifecycle<A...>, bucket: number, fn: Fn<A...> )
	assert(self.buckets[bucket],`Bucket {bucket} is invalid!`)
	local entry = self._fnIndexes[fn]
	assert(entry,`Entry by the required function not found`)

	self.buckets[bucket]:remove(entry)
end

function LifecycleClass.fireAll<A...>(self: Lifecycle<A...>, ...: A...) -- Surely this is for lifecycles that is for mid-events not something like "OnStart" and "OnDestroy"
	for i = 1, #self.bucketIndices do
		local bucket = self.bucketIndices[i]
		local bucketMap = self.buckets[bucket]
		assert(bucketMap, `Missing bucket {bucket}`)
		for _, entry in bucketMap.dense do
			entry.value(...)
		end
	end
end

return LifecycleClass
