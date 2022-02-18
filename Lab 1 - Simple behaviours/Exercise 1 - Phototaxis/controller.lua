MAX_VELOCITY = 10
MIN_VELOCITY = 0

function light_detection()
	local sensor_detected = 0
	local intensity = -1
	for sensor_index, light_sensor in pairs(robot.light) do
		local current_value = light_sensor.value
		
		if current_value > intensity then
			intensity = current_value
			sensor_detected = sensor_index
		end
	end
	return sensor_detected > 0 and true or false, sensor_detected
end

function is_light_in_front(sensor)
	return (1 <= sensor and sensor <= 3) or
			(22 <= sensor and sensor <= 24)
end

function is_light_on_left(sensor)
	return 4 <= sensor and sensor <= 12
end

function go_away()
	robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
end

function turn_left()
	robot.wheels.set_velocity(MIN_VELOCITY, MAX_VELOCITY)
end

function turn_right()
	robot.wheels.set_velocity(MAX_VELOCITY, MIN_VELOCITY)
end

function init()
end

function step()
	local light, sensor = light_detection()
	
	if light and is_light_in_front(sensor) then
		go_away()
	elseif light and is_light_on_left(sensor) then
		turn_left()	
	else
		turn_right()
	end
end

function reset()
end

function destroy()
end