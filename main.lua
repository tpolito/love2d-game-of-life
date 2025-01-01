function love.conf(t)
	t.window.resizable = true
	t.window.minwidth = 400
	t.window.minheight = 300
	t.window.title = "Game of Life"
end

function love.load()
	love.graphics.setBackgroundColor(1, 1, 1)
	love.keyboard.setKeyRepeat(true)
	BASE_CELL_SIZE = 15
	CELL_SIZE = BASE_CELL_SIZE

	GRID_X = 70
	GRID_Y = 50

	-- Calculate initial window size based on grid
	windowWidth = GRID_X * CELL_SIZE
	windowHeight = GRID_Y * CELL_SIZE
	love.window.setMode(windowWidth, windowHeight, { resizable = true })

	grid = {}
	for y = 1, GRID_Y do
		grid[y] = {}
		for x = 1, GRID_X do
			grid[y][x] = false
		end
	end

	-- Added: Initialize font for better text rendering
	font = love.graphics.newFont(14)
	love.graphics.setFont(font)
end

function love.resize(w, h)
	-- Recalculate cell size based on new window dimensions
	local scaleX = w / (GRID_X * BASE_CELL_SIZE)
	local scaleY = h / (GRID_Y * BASE_CELL_SIZE)
	local scale = math.min(scaleX, scaleY)
	CELL_SIZE = BASE_CELL_SIZE * scale
end

-- Added: Function to count living cells
function countLivingCells()
	local count = 0
	for y = 1, GRID_Y do
		for x = 1, GRID_X do
			if grid[y][x] then
				count = count + 1
			end
		end
	end
	return count
end

function love.update()
	-- Get mouse coordinates and adjust for grid offset
	local mouseX = love.mouse.getX()
	local mouseY = love.mouse.getY()

	-- Calculate grid offset (same as in draw function)
	local totalWidth = GRID_X * CELL_SIZE
	local totalHeight = GRID_Y * CELL_SIZE
	local offsetX = (love.graphics.getWidth() - totalWidth) / 2
	local offsetY = (love.graphics.getHeight() - totalHeight) / 2

	-- Adjust mouse coordinates relative to grid
	local gridMouseX = mouseX - offsetX
	local gridMouseY = mouseY - offsetY

	-- Calculate selected cell based on adjusted coordinates
	selectedX = math.min(math.max(math.floor(gridMouseX / CELL_SIZE) + 1, 1), GRID_X)
	selectedY = math.min(math.max(math.floor(gridMouseY / CELL_SIZE) + 1, 1), GRID_Y)

	if love.mouse.isDown(1) then
		grid[selectedY][selectedX] = true
	elseif love.mouse.isDown(2) then
		grid[selectedY][selectedX] = false
	end
end

function love.keypressed()
	local nextGrid = {}

	for y = 1, GRID_Y do
		nextGrid[y] = {}
		for x = 1, GRID_X do
			local neighborCount = 0

			for dy = -1, 1 do
				for dx = -1, 1 do
					if not (dy == 0 and dx == 0)
							and grid[y + dy]
							and grid[y + dy][x + dx] then
						neighborCount = neighborCount + 1
					end
				end
			end

			nextGrid[y][x] = neighborCount == 3
					or (grid[y][x] and neighborCount == 2)
		end
	end

	grid = nextGrid
end

function love.draw()
	-- Calculate offset to center the grid
	local totalWidth = GRID_X * CELL_SIZE
	local totalHeight = GRID_Y * CELL_SIZE
	local offsetX = (love.graphics.getWidth() - totalWidth) / 2
	local offsetY = (love.graphics.getHeight() - totalHeight) / 2

	love.graphics.push()
	love.graphics.translate(offsetX, offsetY)

	for y = 1, GRID_Y do
		for x = 1, GRID_X do
			local cellDrawSize = CELL_SIZE - 1

			if x == selectedX and y == selectedY then
				love.graphics.setColor(0, 1, 1)
			elseif grid[y][x] then
				love.graphics.setColor(1, 0, 1)
			else
				love.graphics.setColor(0.86, 0.86, 0.86)
			end

			love.graphics.rectangle("fill", (x - 1) * CELL_SIZE, (y - 1) * CELL_SIZE, cellDrawSize, cellDrawSize)
		end
	end

	-- Debug text (adjusted for offset)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(
		string.format("Living Cells: %d", countLivingCells()),
		-offsetX + 10,
		-offsetY + 30
	)

	-- Display FPS counter
	love.graphics.print(
		string.format("FPS: %d", love.timer.getFPS()),
		-offsetX + 10,
		-offsetY + 50
	)

	love.graphics.pop()
end
