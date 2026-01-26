class_name ChunkHandler extends Node2D

var CHUNK_PACKED:PackedScene = preload("res://Game/World/Chunk/Chunk.tscn")
var chunkDict:Dictionary[Vector2i,Chunk]
var loadingChunk:Array[Chunk]
var loadingTaskId:int

func _ready()->void:
	for x in range(-0,1):
		for y in range(-0,1):
			addChunk(x,y)
	loadingTaskId = WorkerThreadPool.add_group_task(chunkLoader,loadingChunk.size())

func chunkLoader(i:int)->void:
	loadingChunk[i].generation()
	loadingChunk[i].state = Chunk.STATE_TO_REFRESH

func addChunk(x:int,y:int)->void:
	var chunk:Chunk = CHUNK_PACKED.instantiate()
	chunk.setGlobalPosition(x,y)
	loadingChunk.append(chunk)
	add_child(chunk)
