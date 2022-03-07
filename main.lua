-- [ Settings ] --

-- Collisions
showCollision = false

-- Stats and Fonts
printStatistics = false
customFont = true

-- Custom Font
titleFontSize = 18
bodyFontSize = 15

-- Preload Common Assets --
assetsDirectory = "assets/"
imagesDirectory = assetsDirectory.."images/"
fontsDirectory = assetsDirectory.."fonts/"
librariesDirectory = assetsDirectory.."libraries/"
mapsDirectory = assetsDirectory.."maps/"
audioDirectory = assetsDirectory.."audio/"

anim8 = require(librariesDirectory.."anim8")
love.graphics.setDefaultFilter("nearest", "nearest")

sti = require(librariesDirectory.."sti")
gameMap = sti(mapsDirectory.."testmap.lua")

camera = require(librariesDirectory.."camera")
cam = camera()

wf = require(librariesDirectory.."windfield")
world = wf.newWorld(0, 0)

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
		love.graphics.print("CurrentFPS: "..tostring(love.timer.getFPS()),0,127)

		love.graphics.print("Character Information: ",sysInfoTitle,0,142)
		love.graphics.print("CharPositionX: "..player.x,0,157)
		love.graphics.print("CharPositionY: "..player.y,0,172)
		love.graphics.print("CharSpeed: "..player.speed,0,187)
		love.graphics.print("CharControl: ".."WASD or Up; Right; Down; Left; Arrow Keys.",0,202)
		love.graphics.print("Audio Control: ".."Space to play Soundbyte, Z and X to Pause and Continue BGM.",0,217)
	end
end

-- Audio Function
function love.keypressed(key)
	if key == "space" then
		sounds.blip:play()
	end
	if key == "z" then
		sounds.music:play()
	end
	if key == "x" then
		sounds.music:pause()
	end
end

-- Base Functions --
function love.load()
	player = {}
	player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10)
	player.collider:setFixedRotation(true)
	player.x = 400
	player.y = 200
	player.speed = 300
	--player.sprite = love.graphics.newImage(imagesDirectory.."oldAssets/whiteFace.png")
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

	local walls = {}
	if gameMap.layers["Walls"] then
		for i, obj in pairs(gameMap.layers["Walls"].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
			wall:setType("static")
			table.insert(walls, wall)
		end
	end

	sounds = {}
	sounds.blip = love.audio.newSource(audioDirectory.."blip.wav", "static")
	sounds.music = love.audio.newSource(audioDirectory.."music.mp3", "stream")
	sounds.music:setLooping(true)

	sounds.music:play()
end

function love.update(dt) -- dt means "deltaTime", remember this!
	--dt = 0.016

	local isMoving = false

	local vx = 0
	local vy = 0

	-- Untie from FPS
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		vy = player.speed * -1
		player.anim = player.animations.up
		isMoving = true
	end
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		vx = player.speed * -1
		player.anim = player.animations.left
		isMoving = true
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		vy = player.speed
		player.anim = player.animations.down
		isMoving = true
	end
	if love.keyboard.isDown("d") or love.keyboard.isDown("right")then
		vx = player.speed
		player.anim = player.animations.right
		isMoving = true
	end

	player.collider:setLinearVelocity(vx, vy)

	if not isMoving then
		player.anim:gotoFrame(2)
	end

	world:update(dt)
	player.x = player.collider:getX()
	player.y = player.collider:getY()

	player.anim:update(dt)

	cam:lookAt(player.x, player.y)

	local w = love.graphics:getWidth()
	local h = love.graphics:getHeight()

	local mapW = gameMap.width * gameMap.tilewidth
	local mapH = gameMap.height * gameMap.tileheight

	local function handleCameraRestrictions()
		if cam.x < w/2 then
			cam.x = w/2
		end

		if cam.y < h/2 then
			cam.y = h/2
		end

		if cam.x > (mapW - w/2) then
			cam.x = (mapW - w/2)
		end

		if cam.y > (mapH - h/2) then
			cam.y = (mapH - h/2)
		end
	end

	handleCameraRestrictions()

end

function love.draw()
	-- Camera Draw
	cam:attach()

		-- Map Layers
		gameMap:drawLayer(gameMap.layers["Ground"])
		gameMap:drawLayer(gameMap.layers["Trees"])

		-- Map / World Draw
		if showCollision then
			world:draw() -- Show Collision
		end

		-- Player
		player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)

	-- Camera Stop Drawing
	cam:detach()

	-- Draw System Info
	printStats()

end