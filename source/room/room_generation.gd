extends Node

# Defines starting size of the matrix and total cells in it.
var MatrixSizeX = 10
var MatrixSizeY = 10
var TotalCells = MatrixSizeX * MatrixSizeY

# Defines a blank array representing the matrix of the map.
var MapMatrix = []

# Called when the node enters the scene tree for the first time.
func _ready():
	matrix_init()
	print("\n1st stage: Places values randomly on the matrix.")
	generate_room_base()
	matrix_draw()
	print("\n2nd stage: Signifes a box around each value.")
	generate_room_boxes()
	matrix_draw()
	print("\n3rd stage: Flattens all non zero values to 1.")
	generate_room_boxes_process()
	matrix_draw()
	print("\n4th stage: Random values are placed in the area of the room.")
	generate_room_randoms()
	matrix_draw()
	
# Initializes the matrix by appending 0's in the MapMatrix array with the total amount of cells.
func matrix_init():
	for i in TotalCells:
		MapMatrix.append(0)

# Prints a list of each postition and it's value in the matrix.
func matrix_dump():
	for x in MatrixSizeX:
		for y in MatrixSizeY:
			print("%d, %d = %d" % [x, y, MapMatrix[(y * MatrixSizeX) + x]])

# Returns the value of a position.
func matrix_get(x, y):
	var idx = (y * MatrixSizeX) + x
	return MapMatrix[idx]

# Sets the value of a position.
func matrix_set(x, y, val):
	var idx = (y * MatrixSizeX) + x
	MapMatrix[idx] = val

# Changes the total size of the matrix. Is used as part of the game loop.
func matrix_increase(x, y):
	MatrixSizeX = MatrixSizeX + x
	MatrixSizeY = MatrixSizeY + y
	TotalCells = MatrixSizeX * MatrixSizeY

# Prints the matrix in a table like format.
func matrix_draw():
	var row = []
	var row_counter = 1
	for y in MatrixSizeY:
		for x in MatrixSizeX:
			var idx = (y * MatrixSizeX) + x
			row.append(MapMatrix[idx])
			if idx == ((MatrixSizeX * row_counter)-1):
				print("y=%d %s" % [row_counter, row])
				row_counter = row_counter + 1
				row = []

# Conditional function that gives enough space for the edge detection of room building functions.
func boundry_check(x, y):
	if 1 < x and x < (MatrixSizeX-2) and 1 < y and y < (MatrixSizeY-2):
		return true

# Randomly sets the spaces where boxes will be drawn around.
func generate_room_base():
	for y in MatrixSizeY:
		for x in MatrixSizeX:
			if boundry_check(x, y) == true:
				matrix_set(x,y,0)
				var random_float = randf()
				if random_float < 0.3:
					matrix_set(x, y, 2)

# Checks for and generates the boxes within the matirix.
func generate_room_boxes():
	for y in MatrixSizeY:
		for x in MatrixSizeX:
			if matrix_get(x, y) == 2:
				make_box(x,y)

# Processes all values in the matrix above 0 to be 1.
func generate_room_boxes_process():
	for y in MatrixSizeY:
		for x in MatrixSizeX:
			if matrix_get(x, y) > 0:
				matrix_set(x, y, 1)

# Sets random values within room that is used for spawning items/enemies.
func generate_room_randoms():
	for y in MatrixSizeY:
		for x in MatrixSizeX:
			if matrix_get(x, y) > 0:
				var random_float = randf()
				if random_float < 0.075:
					matrix_set(x, y, 2)
				if random_float < 0.025:
					matrix_set(x, y, 3)

# Sets the box.
func make_box(x, y):
	matrix_set(x-1, y-1, matrix_get(x+1, y)+3)
	matrix_set(x, y-1, matrix_get(x+1, y)+3)
	matrix_set(x+1, y-1, matrix_get(x+1, y)+3)
	matrix_set(x-1, y, matrix_get(x+1, y)+3)
	matrix_set(x+1, y, matrix_get(x+1, y)+3)
	matrix_set(x-1, y+1, matrix_get(x+1, y)+3)
	matrix_set(x, y+1, matrix_get(x+1, y)+3)
	matrix_set(x+1, y+1, matrix_get(x+1, y)+3)
