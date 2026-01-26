class_name Chunk extends Node2D

@export var terrain:TileMapLayer

static var CHUNK_SIZE := 64
static var TILE_SIZE := 64

static var STATE_LOADING := 0
static var STATE_TO_REFRESH := 1
static var STATE_DONE := 2
var state:int = STATE_LOADING

var globalPosition:Vector2i
var heightMap:Array[float]
var valueMap:Array[int]

func _process(_delta: float) -> void:
	if(state == STATE_TO_REFRESH):
		refreshTerrain()
		state = STATE_DONE
##[ GENERATION ]###############################################################
func generation()->void:
	generateHeightMap()

func generateHeightMap()->void:
	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			heightMap.append(NoiseHandler.getValue(x+globalPosition.x*CHUNK_SIZE,y+globalPosition.y*CHUNK_SIZE))
			valueMap.append(StaticTerrain.getValue(heightMap[x*CHUNK_SIZE+y]))

##[ GRAPHICS ]##################################################################
func refreshTerrain()->void:
	var refreshPos:Array[Vector2i]
	for x in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			var pos:=Vector2i(x,y)
			refreshPos.append(pos)
			BetterTerrain.set_cell(terrain,pos,valueMap[x*CHUNK_SIZE+y])
	BetterTerrain.update_terrain_cells(terrain,refreshPos)

##[ SETTERS / GETTERS ]#########################################################
func setGlobalPosition(x:int,y:int)->void:
	globalPosition = Vector2i(x,y)
	position = globalPosition*CHUNK_SIZE*TILE_SIZE + globalPosition*4
