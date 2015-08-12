#!/usr/bin/lua

lg = love.graphics
--timers
-- we declare these here so we don't have to edit them in multiple places
canShoot = true
canShootTimerMax = 0.6
canShootTimer = canShootTimerMax

--sound



--entity storage
bullets = {} --array of bullets being drawn and updated

createEnemyTimerMax = 0.2
createEnemyTimer = createEnemyTimerMax
player = { x = 500, y = 710, speed = 300, img = nil }
enemies = {}
isAlive = true
score = 0

function love.load(arg)
  bulletImg = lg.newImage('assets/bullet.png')
  enemyImg = lg.newImage('assets/enemy.png')
  enemyExplosion = lg.newImage('assets/explosion.png')
  player.img = lg.newImage('assets/hero.png')
  bg = lg.newImage('assets/bg.jpg')
  enemyExplode = love.audio.newSource("assets/Explosion2.ogg", "static")
  playerExplode = love.audio.newSource("assets/explodeplayer.mp3", "static")
  laser = love.audio.newSource('assets/Laser1.ogg', 'static')
  restartSound = love.audio.newSource('assets/restart.ogg', 'static')
  bgm = love.audio.newSource('assets/music.mp3', stream)

end

function love.update(dt)
  love.audio.play(bgm)
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left', 'a') then
    if player.x > 0 then
      player.x = player.x - (player.speed * dt)
    end
  elseif love.keyboard.isDown('right','d') then
    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed * dt)
    end
  end

  if love.keyboard.isDown('w', 'up') then
    if player.y > 0 then
      player.y = player.y - (player.speed * dt)
    end

  elseif love.keyboard.isDown('s', 'down') then
    if player.y < (lg.getHeight() - player.img:getHeight()) then
      player.y = player.y + (player.speed * dt)
    end
  end


  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot and isAlive then
    --create some bullets
    newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
    table.insert(bullets, newBullet)
    love.audio.play(laser)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)

    if bullet.y < 0 then
      table.remove(bullets, i)
    end
  end

  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax

    randomNumber = math.random(10, lg.getWidth() - 10)
    newEnemy = { x = randomNumber, y = -10, img = enemyImg}
    table.insert(enemies, newEnemy)
  end

  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (300 * dt)

    if enemy.y > 850 then
      table.remove(enemies, i)
    end
  end

  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
        enemyExplode:setVolume(1000)
        enemyExplode:play()
        score = score + 1
      end
    end

  	if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
  	and isAlive then
    	table.remove(enemies, i)
      love.audio.play(playerExplode)
    	isAlive = false
  	end

	end
  if not isAlive and love.keyboard.isDown('return') then
    restartSound:play()
	-- remove all our bullets and enemies from screen
	   bullets = {}
	   enemies = {}

	-- reset timers
	   canShootTimer = canShootTimerMax
	   createEnemyTimer = createEnemyTimerMax

	-- move player back to default position
	   player.x = 500
	   player.y = 710

	-- reset our game state
	  score = 0
	  isAlive = true
  end
end

function love.draw(dt)
  lg.draw(bg)
	lg.print(score, 500, 0, 0, 3, 3)
  lg.print("A,S,W,D = movement", 6, 720 )
  lg.print("R-CTRL = shoot", 6, 750 )
  if isAlive then
    lg.draw(player.img, player.x, player.y)
  else
    lg.print("Press Enter to restart", lg:getWidth()/3-50, lg:getHeight()/2-10, 0, 3, 3)
  end

  for i, bullet in ipairs(bullets) do
    lg.draw(bullet.img, bullet.x, bullet.y)
  end

  for i, enemy in ipairs(enemies) do
    lg.draw(enemy.img, enemy.x, enemy.y)
  end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
