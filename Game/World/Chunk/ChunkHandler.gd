class_name ChunkHandler extends Node2D

var CHUNK_PACKED:PackedScene = preload("res://Game/World/Chunk/Chunk.tscn")
var chunkDict:Dictionary[Vector2i,Chunk] = {}
var genrationArray:Array[Chunk] = []
var generationThread:Thread = Thread.new()
var lakeThread:Thread = Thread.new()
var riverThread:Thread = Thread.new()
var islandIt:Array[Chunk]

var springIt:Array[Chunk]
var riverIt:Array[Vector2i]
var lakeIt:Array[Vector2i]

var refreshIt:Array[Chunk]

func _process(_delta: float) -> void:
	if(generationThread.is_started() && !generationThread.is_alive()):generationThread.wait_to_finish()
	if(lakeThread.is_started() && !lakeThread.is_alive()):lakeThread.wait_to_finish()
	if(riverThread.is_started() && !riverThread.is_alive()):riverThread.wait_to_finish()
	elif(!generationThread.is_started() && !refreshIt.is_empty()):
		refreshIt.pop_front().refreshTerrain()
	elif(!genrationArray.is_empty()):
		if(!generationThread.is_started()):
			var chunk:Chunk = genrationArray.pop_front()
			generationThread.start(chunk.generation,Thread.PRIORITY_LOW)
	elif(!islandIt.is_empty()):
		var chunk:Chunk = islandIt.pop_front()
		for direction in Direction.eight:
			if(!chunkDict.has(chunk.globalPosition+direction)):
				if(!chunk.hasSea):loadIsland(chunk.globalPosition+direction)
				else:addChunk(chunk.globalPosition+direction)
	if(!springIt.is_empty()):
		if(springIt[0].genarationDone):
			var chunk:Chunk = springIt.pop_front()
			for pos:Vector2i in chunk.springList:
				lakeIt.append(pos+chunk.globalPosition*Chunk.CHUNK_SIZE)
	if(!riverIt.is_empty()):
		if(!riverThread.is_started()):
			if(hasChunkReady(getGlobalPos(riverIt[0])) && chunkDict[getGlobalPos(riverIt[0])].valueMap.size() == Chunk.SURFACE):
				riverThread.start(riverGeneration,Thread.PRIORITY_LOW)
			else:
				riverIt.append(riverIt.pop_front())
	if(!lakeIt.is_empty()):
		if(!lakeThread.is_started()):
			if(hasChunkReady(getGlobalPos(lakeIt[0])) && chunkDict[getGlobalPos(lakeIt[0])].valueMap.size() == Chunk.SURFACE):
				lakeThread.start(lakeGeneration,Thread.PRIORITY_LOW)
			else:
				lakeIt.append(lakeIt.pop_front())

##[ GENERATION ]###############################################################
func loadIsland(pos:Vector2i)->void:
	if(!chunkDict.has(pos)):
		addChunk(pos)
		islandIt.append(chunkDict[pos])
	
func addChunk(pos:Vector2i)->void:
	if(!chunkDict.has(pos)):
		var chunk:Chunk = CHUNK_PACKED.instantiate()
		chunk.setGlobalPosition(pos.x,pos.y)
		springIt.append(chunk)
		genrationArray.append(chunk)
		chunkDict[pos] = chunk
		add_child(chunk)

func lakeGeneration()->void:
	var foundRiver:=false
	var foundSea:=false
	var mustWaitForGen:=false
	var workingLakeIt:Array[Vector2i] = [lakeIt.pop_front()]
	var exclusionList:Array[Vector2i] = []
	setValue(workingLakeIt[0],StaticTerrain.VALUE_LAKE)
	while(!foundRiver && !foundSea && !mustWaitForGen):
		var minHeight := 1.0
		var minPos := workingLakeIt[0]
		for lakePos in workingLakeIt:
			var lakeHeight = NoiseHandler.getHeight(lakePos.x,lakePos.y)
			if(!exclusionList.has(lakePos)):
				for dir:Vector2i in Direction.four:
					var directionPos = lakePos+dir
					var directionValue = getValue(directionPos)
					if(StaticTerrain.GROUP_SALT_WATER.has(directionValue)):
						foundSea = true
					elif(!exclusionList.has(directionPos)):
						if(directionValue == StaticTerrain.VALUE_LAKE && !workingLakeIt.has(directionPos)):workingLakeIt.append(directionPos)
						elif(!workingLakeIt.has(directionPos)):
							var directionHeight = NoiseHandler.getHeight(directionPos.x,directionPos.y)
							if(directionHeight < lakeHeight):
								foundRiver = true
								minPos = directionPos
							elif(directionHeight <= minHeight):
								minHeight = directionHeight
								minPos = directionPos
		if(foundRiver):
			riverIt.insert(0,minPos)
			setValue(minPos,-1)
		else:
			if(hasChunkReady(getGlobalPos(minPos))):
				workingLakeIt.append(minPos)
				setValue(minPos,StaticTerrain.VALUE_LAKE)
			else:
				lakeIt.append(minPos)
				call_deferred("addChunk",getGlobalPos(minPos))
				mustWaitForGen = true


func riverGeneration()->void:
	var foundLake:=false
	var foundSea:=false
	var mustWaitForGen:=false
	var workingPos:Vector2i = riverIt.pop_front()
	while(!foundLake && !foundSea && !mustWaitForGen):
		setValue(workingPos,StaticTerrain.VALUE_RIVER)
		var minPos = workingPos
		var minHeight = NoiseHandler.getHeight(minPos.x,minPos.y)
		for dir:Vector2i in Direction.four:
			var dirPos = workingPos+dir
			var dirHeight = NoiseHandler.getHeight(dirPos.x,dirPos.y)
			if(dirHeight <= minHeight):
				minHeight = dirHeight
				minPos = dirPos
		
		if(minPos == workingPos):
			foundLake = true
			lakeIt.insert(0,minPos)
			setValue(minPos,-1)
		elif(hasChunkReady(getGlobalPos(minPos))):
			if(StaticTerrain.GROUP_SALT_WATER.has(getValue(minPos))):
				foundSea = true
			elif(hasChunkReady(getGlobalPos(minPos))):
				if(getValue(minPos) == StaticTerrain.VALUE_LAKE):
					foundLake = true
				else:
					workingPos = minPos
		else:
			riverIt.append(minPos)
			call_deferred("addChunk",getGlobalPos(minPos))
			mustWaitForGen = true

##[ SETTERS / GETTERS ]#########################################################
func hasChunkReady(globalPos:Vector2i)->bool:
	return chunkDict.has(globalPos) && chunkDict[globalPos].genarationDone
func getValue(pos:Vector2i)->int:
	var globalPos = getGlobalPos(pos)
	
	if(!chunkDict.has(globalPos)):return -1
	else: return chunkDict.get(globalPos).getValue(getLocalPos(pos))
func setValue(pos:Vector2i,value:int)->void:
	var globalPos = getGlobalPos(pos)
	if(chunkDict.has(globalPos)):
		var chunk:Chunk = chunkDict.get(globalPos)
		call_thread_safe("addToRefresh",chunk)
		chunk.call_thread_safe("setValue",getLocalPos(pos),value)
func addToRefresh(chunk:Chunk)->void:
	if(!refreshIt.has(chunk)):refreshIt.append(chunk)
func getGlobalPos(pos:Vector2i)->Vector2i:
	var globalPos = Vector2i(int(pos.x/Chunk.CHUNK_SIZE),int(pos.y/Chunk.CHUNK_SIZE))
	if(pos.x < 0):globalPos.x-=1
	if(pos.y < 0):globalPos.y-=1
	return globalPos
func getLocalPos(pos:Vector2i)->Vector2i:
	var localPos = Vector2i(pos.x%Chunk.CHUNK_SIZE,pos.y%Chunk.CHUNK_SIZE)
	if(pos.x < 0):localPos.x=localPos.x+Chunk.CHUNK_SIZE
	if(pos.y < 0):localPos.y=localPos.y+Chunk.CHUNK_SIZE
	return localPos
