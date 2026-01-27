class_name NoiseHandler

static var noiseArray:Array[NoiseStruct] = [
]
static var totalWeight:int = 0
static var globalSeed:int = 1666534398
#BIG ISLAND : 1666534398, (16,8,2)

static func _static_init() -> void:
	noiseArray.append(addNewBasicNoise(1.0/16.0	,16))
	noiseArray.append(addNewBasicNoise(1.0/4.0	,8))
	noiseArray.append(addNewBasicNoise(1.0		,2))
	print("=====[ Global Seed : ",globalSeed," ]=====")

static func addNewBasicNoise(scale:float, weight:int)->NoiseStruct:
	var noise:=NoiseStruct.new()
	noise.noise.seed = globalSeed
	noise.scale = scale
	noise.weight = weight
	totalWeight += weight
	return noise

static func getHeight(x:int,y:int)->float:
	var rep = 0.0
	for noise:NoiseStruct in noiseArray:
		rep+=(noise.noise.get_noise_2d(x*noise.scale,y*noise.scale)*noise.weight)/totalWeight
	return rep
