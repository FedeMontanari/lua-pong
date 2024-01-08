_G.love = require("love")


function setYOffset(tar)
	return tar.y - tar.h / 2
end

function inputCheck()
	up = love.keyboard.isDown("up")
	down = love.keyboard.isDown("down")
end

function detectCollision(tar)
	return ball.x > tar.x
		and tar.x + 7 > ball.x
		and ball.y > tar.y
		and tar.y + tar.h + 3 > ball.y
end


function opponentMovement(dt)

	local half_h = opponent.h / 2

	if opponent.y + half_h < ball.y then
		opponent.y = opponent.y + opponent.s * dt
	else if opponent.y + half_h > ball.y then
		opponent.y = opponent.y - opponent.s * dt
	end
	end

	if game.diff == 0 then
		opponent.s = 200
	end
	if game.diff == 1 then
		opponent.s = 300
	end
	if game.diff == 2 then
		opponent.s = 450
	end
	if game.diff == 3 then
		opponent.s = 500
		ball.s = 555
	end
	if game.diff == 4 then
		opponent.s = 550
		ball.s = 600
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "up" and not game.init and game.diff < 4 then
		game.diff = game.diff + 1
	end
	if key == "down" and not game.init and game.diff > 0 then
		game.diff = game.diff - 1
	end
	if key == "escape" then
		love.event.quit()
	end
end

function love.load()

	bleep = love.audio.newSource("assets/sounds/bleep.ogg", "static")
	fontSq = love.graphics.newFont("assets/fonts/Square.ttf", 42)
	fontSqO = love.graphics.newFont("assets/fonts/Squareo.ttf", 42)
	bgMusic = love.audio.newSource("assets/sounds/music.mp3", "stream")
	bgMusic:setLooping(true)
	bgMusic:setVolume(0.25)
	bgMusic:play()

	winX, winY = love.graphics.getDimensions()

	ball = {
		x = winX / 2,
		y = winY / 2,
		radius = 6,
		segments = 100,
		hor = false,
		ver = true,
		s = 350
	}

	player = {
		x = winX - 10,
		y = winY / 2,
		h = 100,
		speed = 500,
		col = false,
	}

	player.y = setYOffset(player)

	opponent = {
		x = 5,
		y = winY / 2,
		h = 100,
		s = 500,
		col = false,
	}

	opponent.y = setYOffset(opponent)

	score = {
		p = 0,
		o = 0,
	}

	game = {
		init = false,
		diff = 2,
	}


end

function love.update(dt)
	inputCheck()

	opponentMovement(dt)

	if love.keyboard.isDown("space") then
		game.init = true
	end

	-- Check game state
	if game.init then
		-- Player movement
		if up and player.y >= 0 then
			player.y = player.y - player.speed * dt
		end
		if down and player.y <= winY - player.h then
			player.y = player.y + player.speed * dt
		end

		-- Ball movement
		if ball.hor then
			ball.x = ball.x + ball.s * dt
		else
			ball.x = ball.x - ball.s * dt
		end

		if ball.ver then
			ball.y = ball.y + ball.s * dt
		else
			ball.y = ball.y - ball.s * dt
		end

		player.col = detectCollision(player)
		opponent.col = detectCollision(opponent)
	end
end

function love.draw()

	if game.init then
		love.graphics.setColor(255, 255, 255)
		love.graphics.line(winX / 2, 0, winX / 2, winY)
		love.graphics.circle("fill", ball.x, ball.y, ball.radius, ball.segments)
		love.graphics.rectangle("fill", player.x, player.y, 7, player.h)
		love.graphics.rectangle("fill", opponent.x, opponent.y, 7, opponent.h)

	if ball.y + 5 > winY then
		ball.ver = false
	else if ball.y <= 5 then
		ball.ver = true
	end
	end

	if player.col then
		bleep:setPitch(1)
		bleep:play()
		ball.hor = false
	end

	if opponent.col then
		bleep:setPitch(0.5)
		bleep:play()
		ball.hor = true
	end

	if ball.x + 5 > winX then
		score.o = score.o + 1
		ball.x = winX / 2
		ball.x = winX * 0.1
		ball.y = opponent.y + opponent.h / 2
	else if ball.x <= 5 then
		score.p = score.p + 1
		ball.x = winX * 0.9
		ball.y = player.y + player.h / 2
	end
	end


	-- Score drawing
	love.graphics.setColor(255, 255, 255, 0.5)
	love.graphics.print(score.o, fontSq, winX * 0.25, winY / 2)
	love.graphics.setColor(255, 255, 255, 0.5)
	love.graphics.print(score.p, fontSq, winX * 0.75, winY / 2)
	else
		-- Initial Message
		love.graphics.setColor(255, 255, 255)
		message = "Press SPACE to start\nESC to EXIT\nUP/DOWN to change difficulty:\n" .. game.diff + 1
		love.graphics.printf(message, fontSq, winX * 0.04, winY/2 - fontSq:getHeight(gameStartFormatMessage), winX * 0.9, "center")
	end

end
