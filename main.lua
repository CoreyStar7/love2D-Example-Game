-- [ Settings ] --

-- BackgroundColor
bgRed = 75/255
bgGreen = 74/255
bgBlue = 72/255
bgAlpha = 100/100

-- Stats and Fonts
printStatistics = true
customFont = true

-- Custom Font
titleFontSize = 18
bodyFontSize = 15

-- Preload Common Assets --
assetsDirectory = "assets/"
imagesDirectory = assetsDirectory.."images/"
fontsDirectory = assetsDirectory.."fonts/"
librariesDirectory = assetsDirectory.."libraries/"

anim8 = require(librariesDirectory.."anim8")
love.graphics.setDefaultFilter("nearest", "nearest")

-- Variables --
	if customFont then
		getDPIScale = love.graphics.getDPIScale()
		sysInfoTitle = love.graphics.newFont(fontsDirectory.."VCR_OSD_MONO.ttf", titleFontSize, "normal", getDPIScale)
		sysInfoBody = love.graphics.newFont(fontsDirectory.."VCR_OSD_MONO.ttf", bodyFontSize, "normal", getDPIScale)
		love.graphics.setFont(sysInfoBody)
	else
		getDPIScale = love.graphics.getDPIScale()
		sysInfoTitle = love.graphics.newFont(titleFontSize, "normal", getDPIScale)
		sysInfoBody = love.graphics.newFont(bodyFontSize, "normal", getDPIScale)
		love.graphics.setFont(sysInfoBody)
	end

-- Custom Functions --
function printStats()
	if printStatistics then
		width, height = love.window.getMode()
		love.graphics.print("System Information:",sysInfoTitle,0,0)
		love.graphics.print("currentOS: "..love.system.getOS(),0,20)
		love.graphics.print("osPowerInfo: "..love.system.getPowerInfo(),0,35)
		love.graphics.print("osDate : "..os.date(),0,80)
		love.graphics.print("osTime : "..os.time(),0,95)
		love.graphics.print("cpuThreads: "..love.system.getProcessorCount(),0,50)
		love.graphics.print("cpuFrameTime: "..os.clock(),0,65)
		love.graphics.print("Resolution: "..width.." x "..height,0,110)

		love.graphics.print("Character Information: ",sysInfoTitle,0,127)
		love.graphics.print("CharPositionX: "..player.x,0,142)
		love.graphics.print("CharPositionY: "..player.y,0,157)
		love.graphics.print("CharSpeed: "..playerSpeed,0,172)
		love.graphics.print("CharControl: ".."WASD or Up; Right; Down; Left; Arrow Keys.",0,187)
	end
end

-- Base Functions --
function love.load()
	player = {}
	player.x = 0
	player.y = 0
	--player.sprite = love.graphics.newImage(imagesDirectory.."whiteFace.png")
	player.spriteSheet = love.graphics.newImage(imagesDirectory.."basicChar.png")
	player.grid = anim8.newGrid(12,18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
	player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
	player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
	player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

	player.anim = player.animations.down -- default value

	background = love.graphics.newImage(imagesDirectory.."whiteGrid.png")
	altBackground = love.graphics.newImage(imagesDirectory.."blackGrid.png")
end

function love.update(dt) -- dt means "deltaTime", remember this!
	local isMoving = false
	playerSpeed = 1

	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		player.y = player.y - playerSpeed
		player.anim = player.animations.up
		isMoving = true
	end
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		player.x = player.x - playerSpeed
		player.anim = player.animations.left
		isMoving = true
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		player.y = player.y + playerSpeed
		player.anim = player.animations.down
		isMoving = true
	end
	if love.keyboard.isDown("d") or love.keyboard.isDown("right")then
		player.x = player.x + playerSpeed
		player.anim = player.animations.right
		isMoving = true
	end

	if not isMoving then
		player.anim:gotoFrame(2)
	end

	player.anim:update(dt)
end

function love.draw()
	-- Background
	love.graphics.setBackgroundColor(bgRed, bgGreen, bgBlue, bgAlpha)
	love.graphics.draw(altBackground, 0,0) -- make it actually tile pls

	-- Player
	player.anim:draw(player.spriteSheet, player.x, player.y, nil, 10)

	-- Misc
	printStats()
end