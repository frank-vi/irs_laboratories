VELOCITY_STANDARD = 10

function random_walk()
	left_velocity = robot.random.uniform(0, VELOCITY_STANDARD)
	right_velocity = robot.random.uniform(0, VELOCITY_STANDARD)
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
	return obstacle_direction, proximity_value -- 0 means no detection
end

function step_function(value)
	return (value < 0) and 0 or 1
end

function obstacle_avoidance()
	direction, proximity = obstacle_detection()
	if proximity ~= 0 then
		alpha = step_function(direction)
		left_velocity = alpha*VELOCITY_STANDARD -- * (1.1 - proximity)
		right_velocity = (1 - alpha)*VELOCITY_STANDARD -- * (1.1 - proximity)
	end
end

function light_detection()
	light_direction = 0
	light_intensity = -1
	for sensor_index, light_sensor in ipairs(robot.light) do
		local current_light_intensity = light_sensor.value
		
		if current_light_intensity > light_intensity then
			light_intensity = current_light_intensity
			light_direction = light_sensor.angle
		end
	end
end

function light_following()	
	light_detection()
	
	if light_intensity > 0 then
		beta = step_function(light_direction)
		left_velocity =  (1 - beta) * VELOCITY_STANDARD -- * (1.1 - light_intensity)
		right_velocity = beta * VELOCITY_STANDARD -- * (1.1 - light_intensity)
	end
end

function init()
end

function step()	
	random_walk()
	light_following()
	obstacle_avoidance()
	robot.wheels.set_velocity(left_velocity, right_velocity)
end

function reset()
end

function destroy()
end
