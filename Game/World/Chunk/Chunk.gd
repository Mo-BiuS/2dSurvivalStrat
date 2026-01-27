class_name Chunk extends Node2D

@export var terrain:TileMapLayer

static var CHUNK_SIZE := 32
static var SURFACE := CHUNK_SIZE*CHUNK_SIZE
static var CHUNK_RECT := Rect2i(0,0,CHUNK_SIZE,CHUNK_SIZE)
static var TILE_SIZE := 64

var globalPosition:Vector2i
var valueMap:Array[int]
var hasSea:bool = false
var springList:Array[Vector2i]
var genarationDone = false

var mutex:Mutex = Mutex.new()

##[ GENERATION ]###############################################################
func generation()->void:
	generateHeightMap()
	generateSpring()
	call_deferred("refreshTerrain")
	genarationDone = true

func generateHeightMap()->void:
	hasSea = false
	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			var value := StaticTerrain.getValue(getHeight(Vector2i(x,y)))
			valueMap.append(value)
			if(!hasSea && StaticTerrain.GROUP_SALT_WATER.has(value)): hasSea = true
func generateSpring()->void:
	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			var centerPos:=Vector2i(x,y)
			var centerValue = getHeight(centerPos)
			if(centerValue >= StaticTerrain.THRESHOLD_COAST):
				var spring = true
				for direction in Direction.four:
					if(centerValue > getHeight(centerPos+direction)-StaticTerrain.THRESHOLD_SPRING_START):
						spring = false
						break
				if spring :
					springList.append(centerPos)
					setValue(centerPos,StaticTerrain.VALUE_LAKE)
			
##[ GRAPHICS ]##################################################################
func refreshTerrain()->void:
	var refreshPos:Array[Vector2i]
	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			var pos:=Vector2i(x,y)
			refreshPos.append(pos)
			BetterTerrain.set_cell(terrain,pos,getValue(pos))
	BetterTerrain.update_terrain_cells(terrain,refreshPos)


##[ SETTERS / GETTERS ]#########################################################
func setGlobalPosition(x:int,y:int)->void:
	globalPosition = Vector2i(x,y)
	position = globalPosition*CHUNK_SIZE*TILE_SIZE
func setValue(pos:Vector2i, value:int):
	mutex.lock()
	valueMap[pos.x*CHUNK_SIZE+pos.y] = value
	mutex.unlock()
func getValue(pos:Vector2i)->int:
	var rep = valueMap[pos.x*CHUNK_SIZE+pos.y]
	return rep
func getHeight(pos:Vector2i)->float:
	return NoiseHandler.getHeight(pos.x+globalPosition.x*CHUNK_SIZE,pos.y+globalPosition.y*CHUNK_SIZE)
