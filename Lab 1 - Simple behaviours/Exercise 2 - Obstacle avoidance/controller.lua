MAX_VELOCITY = 10

function random_walk()
	left_velocity = robot.random.uniform(0, MAX_VELOCITY)
	right_velocity = robot.random.uniform(0, MAX_VELOCITY)
end

function obstacle_detection()
	local obstacle_direction = 0
	local proximity_value = 0
	for sensor_index, proximity_sensor in ipairs(robot.proximity) do
		local current_proximity = proximity_sensor.value
		
		if current_proximity > proximity_value then
			proximity_value = current_proximity
			obstacle_direction = proximity_sensor.angle
		end
	end
	return obstacle_direction, proximity_value
end

function step_activation(value)
	return (value < 0) and 0 or 1
end

function obstacle_avoidance()
	direction, proximity = obstacle_detection()
	if proximity > 0 then
		alpha = step_activation(direction)
		left_velocity = alpha*MAX_VELOCITY
		right_velocity = (1 - alpha)*MAX_VELOCITY
	end
end

function init()
end

function step()
	random_walk()
	obstacle_avoidance()
	robot.wheels.set_velocity(left_velocity, right_velocity)
end

function reset()
end

function destroy()
end
