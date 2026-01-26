class_name StaticTerrain

static var THRESHOLD_SEA			:= 0.0
static var THRESHOLD_COAST			:= 0.1
static var THRESHOLD_BEACH			:= 0.12
static var THRESHOLD_PLAINS			:= 0.20
static var THRESHOLD_HILLS			:= 0.28
static var THRESHOLD_MONTAIN_LOW		:= 0.36
static var THRESHOLD_MONTAIN_MEDIUM	:= 0.44
static var THRESHOLD_MONTAIN_HIGH	:= 1.0

static var VALUE_SEA			:= 0
static var VALUE_COAST			:= 1
static var VALUE_BEACH			:= 4
static var VALUE_RIVER			:= 2
static var VALUE_LAKE			:= 3
static var VALUE_PLAINS			:= 5
static var VALUE_HILLS			:= 6
static var VALUE_MONTAIN_LOW	:= 7
static var VALUE_MONTAIN_MEDIUM	:= 8
static var VALUE_MONTAIN_HIGH	:= 9

static var GROUP_SALT_WATER:Array[int] = [VALUE_SEA,VALUE_COAST]
static var GROUP_FRESH_WATER:Array[int] = [VALUE_RIVER,VALUE_LAKE]
static var GROUP_LAND:Array[int] = [VALUE_BEACH,VALUE_PLAINS,VALUE_HILLS,VALUE_MONTAIN_LOW,VALUE_MONTAIN_MEDIUM,VALUE_MONTAIN_HIGH]

static func getValue(threshold:float)->int:
	if(threshold < THRESHOLD_SEA):return VALUE_SEA
	if(threshold < THRESHOLD_COAST):return VALUE_COAST
	if(threshold < THRESHOLD_BEACH):return VALUE_BEACH
	if(threshold < THRESHOLD_PLAINS):return VALUE_PLAINS
	if(threshold < THRESHOLD_HILLS):return VALUE_HILLS
	if(threshold < THRESHOLD_MONTAIN_LOW):return VALUE_MONTAIN_LOW
	if(threshold < THRESHOLD_MONTAIN_MEDIUM):return VALUE_MONTAIN_MEDIUM
	if(threshold < THRESHOLD_MONTAIN_HIGH):return VALUE_MONTAIN_HIGH
	return -1
	
