class_name ChunkHandler extends Node2D

var CHUNK_PACKED:PackedScene = preload("res://Game/World/Chunk/Chunk.tscn")
var chunkDict:Dictionary[Vector2i,Chunk] = {}
var genrationArray:Array[Chunk] = []
var generationThread:Thread = Thread.new()
var lakeThread:Thread = Thread.new()
var riverThread:Thread = Thread.new()
var islandIt:Array[Chunk]

var springArray:Array[Chunk]
var riverToGen:Array[Vector2i]
var lakeToGen:Array[Vector2i]

var refreshIt:Array[Chunk]

func _process(_delta: float) -> void:
	
	if(!islandIt.is_empty()):
		var chunk:Chunk = islandIt.pop_front()
		for direction in Direction.eight:
			if(!chunkDict.has(chunk.globalPosition+direction)):
				if(!chunk.hasSea):loadIsland(chunk.globalPosition+direction)
				else:addChunk(chunk.globalPosition+direction)
	if(!springArray.is_empty()):
		if(springArray[0].genarationDone):
			var chunk:Chunk = springArray.pop_front()
			for pos:Vector2i in chunk.springList:
				lakeToGen.append(pos+chunk.globalPosition*Chunk.CHUNK_SIZE)
	
	if(generationThread.is_started() && !generationThread.is_alive()):generationThread.wait_to_finish()
	if(lakeThread.is_started() && !lakeThread.is_alive()):lakeThread.wait_to_finish()
	if(riverThread.is_started() && !riverThread.is_alive()):riverThread.wait_to_finish()
	
	if(!generationThread.is_started()):
		if(!refreshIt.is_empty()):refreshIt.pop_front().refreshTerrain()
		elif(!genrationArray.is_empty()):
			var chunk:Chunk = genrationArray.pop_front()
			generationThread.start(chunk.generation,Thread.PRIORITY_LOW)
	if(!riverThread.is_started()):
		if(!riverToGen.is_empty()):
			if(hasChunkReady(getGlobalPos(riverToGen[0])) && chunkDict[getGlobalPos(riverToGen[0])].valueMap.size() == Chunk.SURFACE):
				riverThread.start(riverGeneration,Thread.PRIORITY_LOW)
			else:
				riverToGen.append(riverToGen.pop_front())
	if(!lakeThread.is_started()):
		if(!lakeToGen.is_empty()):
			if(hasChunkReady(getGlobalPos(lakeToGen[0])) && chunkDict[getGlobalPos(lakeToGen[0])].valueMap.size() == Chunk.SURFACE):
				lakeThread.start(lakeGeneration,Thread.PRIORITY_LOW)
			else:
				lakeToGen.append(lakeToGen.pop_front())

##[ GENERATION ]###############################################################
func loadIsland(pos:Vector2i)->void:
	if(!chunkDict.has(pos)):
		addChunk(pos)
		islandIt.append(chunkDict[pos])
	
func addChunk(pos:Vector2i)->void:
	if(!chunkDict.has(pos)):
		var chunk:Chunk = CHUNK_PACKED.instantiate()
		chunk.setGlobalPosition(pos.x,pos.y)
		springArray.append(chunk)
		genrationArray.append(chunk)
		chunkDict[pos] = chunk
		add_child(chunk)

func lakeGeneration()->void:
	var foundRiver:=false
	var foundSea:=false
	var mustWaitForGen:=false
	var workinglakeToGen:Array[Vector2i] = [lakeToGen.pop_front()]
	setValue(workinglakeToGen[0],StaticTerrain.VALUE_LAKE)
	while(!foundRiver && !foundSea && !mustWaitForGen):
		var minHeight := 1.0
		var minPos := workinglakeToGen[0]
		for lakePos in workinglakeToGen:
			var lakeHeight = NoiseHandler.getHeight(lakePos.x,lakePos.y)
			for dir:Vector2i in Direction.four:
				var directionPos = lakePos+dir
				var directionValue = getValue(directionPos)
				
				if(StaticTerrain.GROUP_SALT_WATER.has(directionValue)):
					foundSea = true
				elif(!workinglakeToGen.has(directionPos)):
					if(directionValue == StaticTerrain.VALUE_LAKE):workinglakeToGen.append(directionPos)
					else:
						var directionHeight = NoiseHandler.getHeight(directionPos.x,directionPos.y)
						if(directionHeight < lakeHeight):
							foundRiver = true
							minPos = directionPos
						elif(directionHeight <= minHeight):
							foundRiver = false
							minHeight = directionHeight
							minPos = directionPos
		if(foundRiver):
			if(!hasChunkReady(getGlobalPos(minPos))):call_thread_safe("addChunk",getGlobalPos(minPos))
			call_thread_safe("addFrontriverToGen",minPos)
			setValue(minPos,StaticTerrain.VALUE_RIVER)
		else:
			if(hasChunkReady(getGlobalPos(minPos))):
				workinglakeToGen.append(minPos)
				setValue(minPos,StaticTerrain.VALUE_LAKE)
			else:
				lakeToGen.append(minPos)
				call_thread_safe("addChunk",getGlobalPos(minPos))
				mustWaitForGen = true


func riverGeneration()->void:
	var foundLake:=false
	var foundSea:=false
	var mustWaitForGen:=false
	var workingPos:Vector2i = riverToGen.pop_front()
	while(!foundLake && !foundSea && !mustWaitForGen):
		setValue(workingPos,StaticTerrain.VALUE_RIVER)
		var minPos = workingPos
		var minHeight = NoiseHandler.getHeight(minPos.x,minPos.y)
		var nLake = 0
		for dir:Vector2i in Direction.four:
			var dirPos = workingPos+dir
			if(hasChunkReady(getGlobalPos(minPos)) && getValue(minPos) == StaticTerrain.VALUE_LAKE):nLake+=1
			var dirHeight = NoiseHandler.getHeight(dirPos.x,dirPos.y)
			if(dirHeight <= minHeight):
				minHeight = dirHeight
				minPos = dirPos
		
		if(nLake > 1):
			foundLake = true
			setValue(workingPos,StaticTerrain.VALUE_LAKE)
			call_thread_safe("addFrontlakeToGen",workingPos)
		if(minPos == workingPos):
			foundLake = true
			setValue(workingPos,StaticTerrain.VALUE_LAKE)
			call_thread_safe("addFrontlakeToGen",minPos)
		elif(hasChunkReady(getGlobalPos(minPos))):
			if(StaticTerrain.GROUP_SALT_WATER.has(getValue(minPos))):
				foundSea = true
			elif(hasChunkReady(getGlobalPos(minPos))):
				if(getValue(minPos) == StaticTerrain.VALUE_LAKE):
					foundLake = true
					setValue(workingPos,StaticTerrain.VALUE_LAKE)
				else:
					workingPos = minPos
		else:
			call_thread_safe("addChunk",getGlobalPos(minPos))
			call_thread_safe("addFrontriverToGen",minPos)
			mustWaitForGen = true

##[ SETTERS / GETTERS ]#########################################################
func hasChunkReady(globalPos:Vector2i)->bool:
	return chunkDict.has(globalPos) && chunkDict[globalPos].genarationDone
func getValue(pos:Vector2i)->int:
	var globalPos = getGlobalPos(pos)
	if(hasChunkReady(globalPos)):return chunkDict.get(globalPos).getValue(getLocalPos(pos))
	else:return -1
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
func addFrontriverToGen(pos:Vector2i):
		riverToGen.insert(0,pos)
func addFrontlakeToGen(pos:Vector2i):
		lakeToGen.insert(0,pos)
