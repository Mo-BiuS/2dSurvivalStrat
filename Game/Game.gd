class_name Game extends Node2D

@export var debugCanvas:DebugCanvas
@export var debugLayer:TileMapLayer

@export var chunkHandler:ChunkHandler

var oldPos:Vector2i

func _ready() -> void:
	for i in Chunk.CHUNK_SIZE:
		BetterTerrain.set_cell(debugLayer,Vector2i(0,i),0)
		BetterTerrain.set_cell(debugLayer,Vector2i(i,0),0)
		BetterTerrain.set_cell(debugLayer,Vector2i(Chunk.CHUNK_SIZE-1,i),0)
		BetterTerrain.set_cell(debugLayer,Vector2i(i,Chunk.CHUNK_SIZE-1),0)

func _process(_delta: float) -> void:
	var newPos:Vector2 = get_local_mouse_position()/(Chunk.CHUNK_SIZE*Chunk.TILE_SIZE)
	if(newPos.x < 0):newPos.x-=1
	if(newPos.y < 0):newPos.y-=1
	var newPosI = Vector2i(newPos)
	
	if(oldPos != newPosI):
		oldPos = newPosI
		debugLayer.position = oldPos*Chunk.CHUNK_SIZE*Chunk.TILE_SIZE
	
	debugCanvas.setPos(Vector2i(get_local_mouse_position()/Chunk.TILE_SIZE))
	
	if(Input.is_action_pressed("left_mouse")):chunkHandler.addChunk(oldPos)
