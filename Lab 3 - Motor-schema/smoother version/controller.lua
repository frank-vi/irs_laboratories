local vector = require "vector"

MAX_VELOCITY = 10

-- UTILS
function create_force_vector(transational_velocity, rotational_velocity)
	return { length = transational_velocity, angle = rotational_velocity }
end

function create_null_force_vector()
	return create_force_vector(0.0, 0.0)
end

function roto_translational_2_differental(axis_length, motion_vector)
	local angular2linear = (axis_length/2)*motion_vector.angle
	local left = motion_vector.length - angular2linear
	local right = motion_vector.length + angular2linear
	return left, right
end
-- ####

-- PERCETUAL SCHEMAS
function max_reading(perceptual_schemas)
	local result = {length = 0, angle = 0}
	
	for i=1, #perceptual_schemas do
		local perceptual_schema = perceptual_schemas[i]
		local current_value = perceptual_schema.value
		if current_value > result.length then
			result.length = current_value
			result.angle = perceptual_schema.angle
		end
	end
	
	return result
end
-- #################

-- POTENTIAL FIELDS
function attractive_field(percept, velocity)
	local rotational_velocity = percept.angle
	local transational_velocity = percept.length > 0 and velocity * (1 - percept.length) or 0
	return create_force_vector(transational_velocity, rotational_velocity)
end

function repulsive_field(percept, velocity)	
	local rotational_velocity = percept.angle > 0 and percept.angle - math.pi or
								percept.angle < 0 and math.pi + percept.angle or 0
	local transational_velocity = velocity * percept.length
	return create_force_vector(transational_velocity, rotational_velocity)
end

function noise_field(max_velocity)
	local transational_velocity = max_velocity
	local rotational_velocity = robot.random.uniform(-math.pi, math.pi)
	return create_force_vector(transational_velocity, rotational_velocity)
end
-- ################

-- MOTOR-SCHEMAS
function obstacle_avoidance(sensor)
	local percept = { length = sensor.value, angle = sensor.angle }
	return repulsive_field(percept, MAX_VELOCITY)
end

function phototaxis(sensors)
	local percept = max_reading(sensors)
	return percept.length > 0 and attractive_field(percept, MAX_VELOCITY) or noise_field(MAX_VELOCITY)
end
-- #############

-- FUSION OPERATION
function coordinator(behaviours)
	local vector_sum = create_null_force_vector()
	for i=1, #behaviours do
		vector_sum = vector.vec2_polar_sum(vector_sum, behaviours[i])
	end
	return vector_sum
end
-- #############

function init()
end

function step()	
	local behaviours = { phototaxis(robot.light) }
	
	for i=1, #robot.proximity do
		behaviours[#behaviours + 1] = obstacle_avoidance(robot.proximity[i])
	end
	
	local fusion_vector = coordinator(behaviours)
	local velocity_left, velocity_right = roto_translational_2_differental(robot.wheels.axis_length, fusion_vector)
	robot.wheels.set_velocity(velocity_left, velocity_right)
end

function reset()
end

function destroy()
end
