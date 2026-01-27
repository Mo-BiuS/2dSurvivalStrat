class_name DebugCanvas extends CanvasLayer

@export var fpsLabel:Label
@export var wind:Sprite2D
@export var gpos:Label
@export var lpos:Label

@export var chunkHandler:ChunkHandler

func _process(_delta: float) -> void:
	wind.rotate(.006)
	setFpsLabel(float(int(Engine.get_frames_per_second()*100))/100)

func setFpsLabel(value:float):
	fpsLabel.text = "FPS : " + str(value)

func setPos(pos:Vector2):
	gpos.text = "Global Position : "+str(chunkHandler.getGlobalPos(pos))
	lpos.text = "Local Position : "+str(chunkHandler.getLocalPos(pos))
