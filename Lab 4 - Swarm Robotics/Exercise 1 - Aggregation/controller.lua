MAX_VELOCITY = 10
MAXRANGE = 30

-- states
GO_FORWARD = 0
AVOID_OBSTACLE = 1
STOPPED = 2

-- timer limit
STOPPED_STEPS = 10
GO_FORWARD_STEPS = 15

-- parameters for stochastic transitions
PWmin = 0.01
PSmax = 0.99
W = 0.1
S = 0.15
beta = 0.1
alpha = 0.05

-- potential field utils
function roto_translational_2_differental(axis_length, motion_vector)
	local angular2linear = (axis_length/2)*motion_vector.angle
	local left = motion_vector.length - angular2linear
	local right = motion_vector.length + angular2linear
	return left, right
end
-- ###########################

-- stochastic transition utils
function signal_presence()
	robot.range_and_bearing.set_data(1,1)
	robot.leds.set_all_colors('green')
end

function signal_moving()
	robot.range_and_bearing.set_data(1,0)
	robot.leds.set_all_colors('red')
end

function count_robots_nearby()
	local number_robot_sensed = 0
	for i = 1, #robot.range_and_bearing do
		if robot.range_and_bearing[i].range < MAXRANGE and
			robot.range_and_bearing[i].data[1]==1 then
			number_robot_sensed = number_robot_sensed + 1
		end
	end
	return number_robot_sensed
end
-- ##############

-- timer features
function resetTimer()
	timer = 1
end

function incrementTimer()
	timer = timer + 1
end

function isTimerExpired(limit)
	return timer >= limit
end
-- ################

-- state behaviours
function go_forward()
	robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
end

function stop()
	robot.wheels.set_velocity(0,0)
end

function turn_randomly()
	robot.wheels.set_velocity(-MAX_VELOCITY, MAX_VELOCITY)
end
-- ##############################

-- conditions to fire transitions
function obstacleDetected()
	local front_proximity_sensors = {1, 2, 3, 4, 21, 22, 23, 24}
	
	for _, sensor in ipairs(front_proximity_sensors) do
		if robot.proximity[sensor].value > 0.8 then
			return true
		end
	end
	
	return false
end

function stopProbability()
	local N = count_robots_nearby()
	local Ps = math.min(PSmax, S+(alpha*N))
	local random_number = robot.random.uniform()
	local result = random_number < Ps
	log(robot.id, " -ps-> random number ", random_number, " < ", Ps, " ", result and "true" or "false")
	return result
end

function walkingProbability()
	local N = count_robots_nearby()
	local Pw = math.max(PWmin, W-(beta*N))
	local random_number = robot.random.uniform()
	local result = random_number < Pw
	log(robot.id, " -pw-> random number ", random_number, " < ", Pw, " ", result and "true" or "false")
	return result
end
-- ##############################

function initialization()
	state = GO_FORWARD
	signal_moving()
	resetTimer()
end

function init()
	initialization()
end

function step()
	log(robot.id, " state is: ", state, " timer: ", timer)
	
	if state == GO_FORWARD then
		signal_moving()
		go_forward()
		
		if not isTimerExpired(GO_FORWARD_STEPS) then
			incrementTimer()
		else
			resetTimer()
			turn_randomly()
		end
		
		if stopProbability() then
			resetTimer()
			state = STOPPED
		elseif obstacleDetected() then
			state = AVOID_OBSTACLE
		end
	elseif state == AVOID_OBSTACLE then
		turn_randomly()
		
		if not obstacleDetected() then
			state = GO_FORWARD
		end
	elseif state == STOPPED then
		signal_presence()
		stop()
		
		if not isTimerExpired(STOPPED_STEPS) then
			incrementTimer()
		end
		
		if isTimerExpired(STOPPED_STEPS) and walkingProbability() then
			state = GO_FORWARD
		end
	end
end

function reset()
	initialization()
end

function destroy()
end