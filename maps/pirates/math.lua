
local Public = {}

Public.random = math.random
Public.randomseed = math.randomseed
Public.sqrt = math.sqrt
Public.min = math.min
Public.max = math.max
Public.rad = math.rad
Public.floor = math.floor
Public.abs = math.abs
Public.ceil = math.ceil
Public.log = math.log
Public.atan = math.atan
Public.sin = math.sin
Public.cos = math.cos
Public.pi = math.pi
Public.deg = math.deg
Public.round = math.round




--- SCALING CURVES ---

function Public.sloped(x, slope)
	return 1 + ((x - 1) * slope)
end
-- SLOPE GUIDE
-- slope 1 -> {0.25, 0.50, 0.75, 1.00, 1.50, 3.00, 5.00}
-- slope 4/5 -> {0.40, 0.60, 0.80, 1.00, 1.40, 2.60, 4.20}
-- slope 3/5 -> {0.55, 0.70, 0.85, 1.00, 1.30, 2.20, 3.40}
-- slope 2/5 -> {0.70, 0.80, 0.90, 1.00, 1.20, 1.80, 2.40}

-- EXPONENT GUIDE
-- exponent 1 -> {0.25, 0.50, 0.75, 1.00, 1.50, 3.00, 5.00}
-- exponent 1.5 -> {0.13, 0.35, 0.65, 1.00, 1.84, 5.20, 11.18}
-- exponent 2 -> {0.06, 0.25, 0.56, 1.00, 2.25, 9.00, 25.00}
-- exponent -1.2 -> {5.28, 2.30, 1.41, 1.00, 0.61, 0.27, 0.14}


function Public.sgn(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function Public.length(vec)
	return Public.sqrt(vec.x * vec.x + vec.y * vec.y)
end

function Public.slopefromto(x, from, to)
	return Public.max(0,Public.min(1,
	(x - from) / (to - from)
	))
end

function Public.distance(vec1, vec2)
	local vecx = vec2.x - vec1.x
	local vecy = vec2.y - vec1.y
		return Public.sqrt(vecx * vecx + vecy * vecy)
end

function Public.vector_sum(vec1, vec2)
	return {x = vec1.x + vec2.x, y = vec1.y + vec2.y}
end


function Public.shuffle(tbl)
	local size = #tbl
		for i = size, 2, -1 do
			local rand = Public.random(size)
			tbl[i], tbl[rand] = tbl[rand], tbl[i]
		end
	return tbl
end

local function is_closer(pos1, pos2, pos)
    return ((pos1.x - pos.x) ^ 2 + (pos1.y - pos.y) ^ 2) < ((pos2.x - pos.x) ^ 2 + (pos2.y - pos.y) ^ 2)
end
function Public.shuffle_distancebiased(tbl, position)
    local size = #tbl
    for i = size, 1, -1 do
        local rand = Public.random(i)
        if is_closer(tbl[i].position, tbl[rand].position, position) and i > rand then
            tbl[i], tbl[rand] = tbl[rand], tbl[i]
        end
    end
    return tbl
end

function Public.raffle(values, weights) --arguments of the form {[a] = A, [b] = B, ...} and {[a] = a_weight, [b] = b_weight, ...} or just {a,b,c,...} and {1,2,3...}

	local total_weight = 0
	for k,w in pairs(weights) do
		assert(values[k])
		if w > 0 then
			total_weight = total_weight + w
		end
		-- negative weights treated as zero
	end
	assert(total_weight > 0)

	local cumulative_probability = 0
	local rng = Public.random()
	for k,v in pairs(values) do
		assert(weights[k])
		cumulative_probability = cumulative_probability + (weights[k] / total_weight)
		if rng <= cumulative_probability then
			return v
		end
	end
end

function Public.raffle2(table) --arguments of the form {v1 = w1, v2 = w2, ...}

	local total_weight = 0
	for k,w in pairs(table) do
		if w > 0 then
			total_weight = total_weight + w
		end
		-- negative weights treated as zero
	end
	assert(total_weight > 0)

	local cumulative_probability = 0
	local rng = Public.random()
	for k,v in pairs(table) do
		cumulative_probability = cumulative_probability + v/total_weight
		if rng <= cumulative_probability then
			return k
		end
	end
end

Public.points_in_m20t20_squared_sorted_by_distance_to_origin = {{0, 0}, {1, 0}, {0, 1}, {0, -1}, {-1, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}, {2, 0}, {0, 2}, {0, -2}, {-2, 0}, {2, 1}, {2, -1}, {1, 2}, {1, -2}, {-1, 2}, {-1, -2}, {-2, 1}, {-2, -1}, {2, 2}, {2, -2}, {-2, 2}, {-2, -2}, {3, 0}, {0, 3}, {0, -3}, {-3, 0}, {3, 1}, {3, -1}, {1, 3}, {1, -3}, {-1, 3}, {-1, -3}, {-3, 1}, {-3, -1}, {3, 2}, {3, -2}, {2, 3}, {2, -3}, {-2, 3}, {-2, -3}, {-3, 2}, {-3, -2}, {4, 0}, {0, 4}, {0, -4}, {-4, 0}, {4, 1}, {4, -1}, {1, 4}, {1, -4}, {-1, 4}, {-1, -4}, {-4, 1}, {-4, -1}, {3, 3}, {3, -3}, {-3, 3}, {-3, -3}, {4, 2}, {4, -2}, {2, 4}, {2, -4}, {-2, 4}, {-2, -4}, {-4, 2}, {-4, -2}, {5, 0}, {4, 3}, {4, -3}, {3, 4}, {3, -4}, {0, 5}, {0, -5}, {-3, 4}, {-3, -4}, {-4, 3}, {-4, -3}, {-5, 0}, {5, 1}, {5, -1}, {1, 5}, {1, -5}, {-1, 5}, {-1, -5}, {-5, 1}, {-5, -1}, {5, 2}, {5, -2}, {2, 5}, {2, -5}, {-2, 5}, {-2, -5}, {-5, 2}, {-5, -2}, {4, 4}, {4, -4}, {-4, 4}, {-4, -4}, {5, 3}, {5, -3}, {3, 5}, {3, -5}, {-3, 5}, {-3, -5}, {-5, 3}, {-5, -3}, {6, 0}, {0, 6}, {0, -6}, {-6, 0}, {6, 1}, {6, -1}, {1, 6}, {1, -6}, {-1, 6}, {-1, -6}, {-6, 1}, {-6, -1}, {6, 2}, {6, -2}, {2, 6}, {2, -6}, {-2, 6}, {-2, -6}, {-6, 2}, {-6, -2}, {5, 4}, {5, -4}, {4, 5}, {4, -5}, {-4, 5}, {-4, -5}, {-5, 4}, {-5, -4}, {6, 3}, {6, -3}, {3, 6}, {3, -6}, {-3, 6}, {-3, -6}, {-6, 3}, {-6, -3}, {7, 0}, {0, 7}, {0, -7}, {-7, 0}, {7, 1}, {7, -1}, {5, 5}, {5, -5}, {1, 7}, {1, -7}, {-1, 7}, {-1, -7}, {-5, 5}, {-5, -5}, {-7, 1}, {-7, -1}, {6, 4}, {6, -4}, {4, 6}, {4, -6}, {-4, 6}, {-4, -6}, {-6, 4}, {-6, -4}, {7, 2}, {7, -2}, {2, 7}, {2, -7}, {-2, 7}, {-2, -7}, {-7, 2}, {-7, -2}, {7, 3}, {7, -3}, {3, 7}, {3, -7}, {-3, 7}, {-3, -7}, {-7, 3}, {-7, -3}, {6, 5}, {6, -5}, {5, 6}, {5, -6}, {-5, 6}, {-5, -6}, {-6, 5}, {-6, -5}, {8, 0}, {0, 8}, {0, -8}, {-8, 0}, {8, 1}, {8, -1}, {7, 4}, {7, -4}, {4, 7}, {4, -7}, {1, 8}, {1, -8}, {-1, 8}, {-1, -8}, {-4, 7}, {-4, -7}, {-7, 4}, {-7, -4}, {-8, 1}, {-8, -1}, {8, 2}, {8, -2}, {2, 8}, {2, -8}, {-2, 8}, {-2, -8}, {-8, 2}, {-8, -2}, {6, 6}, {6, -6}, {-6, 6}, {-6, -6}, {8, 3}, {8, -3}, {3, 8}, {3, -8}, {-3, 8}, {-3, -8}, {-8, 3}, {-8, -3}, {7, 5}, {7, -5}, {5, 7}, {5, -7}, {-5, 7}, {-5, -7}, {-7, 5}, {-7, -5}, {8, 4}, {8, -4}, {4, 8}, {4, -8}, {-4, 8}, {-4, -8}, {-8, 4}, {-8, -4}, {9, 0}, {0, 9}, {0, -9}, {-9, 0}, {9, 1}, {9, -1}, {1, 9}, {1, -9}, {-1, 9}, {-1, -9}, {-9, 1}, {-9, -1}, {9, 2}, {9, -2}, {7, 6}, {7, -6}, {6, 7}, {6, -7}, {2, 9}, {2, -9}, {-2, 9}, {-2, -9}, {-6, 7}, {-6, -7}, {-7, 6}, {-7, -6}, {-9, 2}, {-9, -2}, {8, 5}, {8, -5}, {5, 8}, {5, -8}, {-5, 8}, {-5, -8}, {-8, 5}, {-8, -5}, {9, 3}, {9, -3}, {3, 9}, {3, -9}, {-3, 9}, {-3, -9}, {-9, 3}, {-9, -3}, {9, 4}, {9, -4}, {4, 9}, {4, -9}, {-4, 9}, {-4, -9}, {-9, 4}, {-9, -4}, {7, 7}, {7, -7}, {-7, 7}, {-7, -7}, {10, 0}, {8, 6}, {8, -6}, {6, 8}, {6, -8}, {0, 10}, {0, -10}, {-6, 8}, {-6, -8}, {-8, 6}, {-8, -6}, {-10, 0}, {10, 1}, {10, -1}, {1, 10}, {1, -10}, {-1, 10}, {-1, -10}, {-10, 1}, {-10, -1}, {10, 2}, {10, -2}, {2, 10}, {2, -10}, {-2, 10}, {-2, -10}, {-10, 2}, {-10, -2}, {9, 5}, {9, -5}, {5, 9}, {5, -9}, {-5, 9}, {-5, -9}, {-9, 5}, {-9, -5}, {10, 3}, {10, -3}, {3, 10}, {3, -10}, {-3, 10}, {-3, -10}, {-10, 3}, {-10, -3}, {8, 7}, {8, -7}, {7, 8}, {7, -8}, {-7, 8}, {-7, -8}, {-8, 7}, {-8, -7}, {10, 4}, {10, -4}, {4, 10}, {4, -10}, {-4, 10}, {-4, -10}, {-10, 4}, {-10, -4}, {9, 6}, {9, -6}, {6, 9}, {6, -9}, {-6, 9}, {-6, -9}, {-9, 6}, {-9, -6}, {11, 0}, {0, 11}, {0, -11}, {-11, 0}, {11, 1}, {11, -1}, {1, 11}, {1, -11}, {-1, 11}, {-1, -11}, {-11, 1}, {-11, -1}, {11, 2}, {11, -2}, {10, 5}, {10, -5}, {5, 10}, {5, -10}, {2, 11}, {2, -11}, {-2, 11}, {-2, -11}, {-5, 10}, {-5, -10}, {-10, 5}, {-10, -5}, {-11, 2}, {-11, -2}, {8, 8}, {8, -8}, {-8, 8}, {-8, -8}, {11, 3}, {11, -3}, {9, 7}, {9, -7}, {7, 9}, {7, -9}, {3, 11}, {3, -11}, {-3, 11}, {-3, -11}, {-7, 9}, {-7, -9}, {-9, 7}, {-9, -7}, {-11, 3}, {-11, -3}, {10, 6}, {10, -6}, {6, 10}, {6, -10}, {-6, 10}, {-6, -10}, {-10, 6}, {-10, -6}, {11, 4}, {11, -4}, {4, 11}, {4, -11}, {-4, 11}, {-4, -11}, {-11, 4}, {-11, -4}, {12, 0}, {0, 12}, {0, -12}, {-12, 0}, {12, 1}, {12, -1}, {9, 8}, {9, -8}, {8, 9}, {8, -9}, {1, 12}, {1, -12}, {-1, 12}, {-1, -12}, {-8, 9}, {-8, -9}, {-9, 8}, {-9, -8}, {-12, 1}, {-12, -1}, {11, 5}, {11, -5}, {5, 11}, {5, -11}, {-5, 11}, {-5, -11}, {-11, 5}, {-11, -5}, {12, 2}, {12, -2}, {2, 12}, {2, -12}, {-2, 12}, {-2, -12}, {-12, 2}, {-12, -2}, {10, 7}, {10, -7}, {7, 10}, {7, -10}, {-7, 10}, {-7, -10}, {-10, 7}, {-10, -7}, {12, 3}, {12, -3}, {3, 12}, {3, -12}, {-3, 12}, {-3, -12}, {-12, 3}, {-12, -3}, {11, 6}, {11, -6}, {6, 11}, {6, -11}, {-6, 11}, {-6, -11}, {-11, 6}, {-11, -6}, {12, 4}, {12, -4}, {4, 12}, {4, -12}, {-4, 12}, {-4, -12}, {-12, 4}, {-12, -4}, {9, 9}, {9, -9}, {-9, 9}, {-9, -9}, {10, 8}, {10, -8}, {8, 10}, {8, -10}, {-8, 10}, {-8, -10}, {-10, 8}, {-10, -8}, {13, 0}, {12, 5}, {12, -5}, {5, 12}, {5, -12}, {0, 13}, {0, -13}, {-5, 12}, {-5, -12}, {-12, 5}, {-12, -5}, {-13, 0}, {13, 1}, {13, -1}, {11, 7}, {11, -7}, {7, 11}, {7, -11}, {1, 13}, {1, -13}, {-1, 13}, {-1, -13}, {-7, 11}, {-7, -11}, {-11, 7}, {-11, -7}, {-13, 1}, {-13, -1}, {13, 2}, {13, -2}, {2, 13}, {2, -13}, {-2, 13}, {-2, -13}, {-13, 2}, {-13, -2}, {13, 3}, {13, -3}, {3, 13}, {3, -13}, {-3, 13}, {-3, -13}, {-13, 3}, {-13, -3}, {12, 6}, {12, -6}, {6, 12}, {6, -12}, {-6, 12}, {-6, -12}, {-12, 6}, {-12, -6}, {10, 9}, {10, -9}, {9, 10}, {9, -10}, {-9, 10}, {-9, -10}, {-10, 9}, {-10, -9}, {13, 4}, {13, -4}, {11, 8}, {11, -8}, {8, 11}, {8, -11}, {4, 13}, {4, -13}, {-4, 13}, {-4, -13}, {-8, 11}, {-8, -11}, {-11, 8}, {-11, -8}, {-13, 4}, {-13, -4}, {12, 7}, {12, -7}, {7, 12}, {7, -12}, {-7, 12}, {-7, -12}, {-12, 7}, {-12, -7}, {13, 5}, {13, -5}, {5, 13}, {5, -13}, {-5, 13}, {-5, -13}, {-13, 5}, {-13, -5}, {14, 0}, {0, 14}, {0, -14}, {-14, 0}, {14, 1}, {14, -1}, {1, 14}, {1, -14}, {-1, 14}, {-1, -14}, {-14, 1}, {-14, -1}, {14, 2}, {14, -2}, {10, 10}, {10, -10}, {2, 14}, {2, -14}, {-2, 14}, {-2, -14}, {-10, 10}, {-10, -10}, {-14, 2}, {-14, -2}, {11, 9}, {11, -9}, {9, 11}, {9, -11}, {-9, 11}, {-9, -11}, {-11, 9}, {-11, -9}, {14, 3}, {14, -3}, {13, 6}, {13, -6}, {6, 13}, {6, -13}, {3, 14}, {3, -14}, {-3, 14}, {-3, -14}, {-6, 13}, {-6, -13}, {-13, 6}, {-13, -6}, {-14, 3}, {-14, -3}, {12, 8}, {12, -8}, {8, 12}, {8, -12}, {-8, 12}, {-8, -12}, {-12, 8}, {-12, -8}, {14, 4}, {14, -4}, {4, 14}, {4, -14}, {-4, 14}, {-4, -14}, {-14, 4}, {-14, -4}, {13, 7}, {13, -7}, {7, 13}, {7, -13}, {-7, 13}, {-7, -13}, {-13, 7}, {-13, -7}, {14, 5}, {14, -5}, {11, 10}, {11, -10}, {10, 11}, {10, -11}, {5, 14}, {5, -14}, {-5, 14}, {-5, -14}, {-10, 11}, {-10, -11}, {-11, 10}, {-11, -10}, {-14, 5}, {-14, -5}, {15, 0}, {12, 9}, {12, -9}, {9, 12}, {9, -12}, {0, 15}, {0, -15}, {-9, 12}, {-9, -12}, {-12, 9}, {-12, -9}, {-15, 0}, {15, 1}, {15, -1}, {1, 15}, {1, -15}, {-1, 15}, {-1, -15}, {-15, 1}, {-15, -1}, {15, 2}, {15, -2}, {2, 15}, {2, -15}, {-2, 15}, {-2, -15}, {-15, 2}, {-15, -2}, {14, 6}, {14, -6}, {6, 14}, {6, -14}, {-6, 14}, {-6, -14}, {-14, 6}, {-14, -6}, {13, 8}, {13, -8}, {8, 13}, {8, -13}, {-8, 13}, {-8, -13}, {-13, 8}, {-13, -8}, {15, 3}, {15, -3}, {3, 15}, {3, -15}, {-3, 15}, {-3, -15}, {-15, 3}, {-15, -3}, {15, 4}, {15, -4}, {4, 15}, {4, -15}, {-4, 15}, {-4, -15}, {-15, 4}, {-15, -4}, {11, 11}, {11, -11}, {-11, 11}, {-11, -11}, {12, 10}, {12, -10}, {10, 12}, {10, -12}, {-10, 12}, {-10, -12}, {-12, 10}, {-12, -10}, {14, 7}, {14, -7}, {7, 14}, {7, -14}, {-7, 14}, {-7, -14}, {-14, 7}, {-14, -7}, {15, 5}, {15, -5}, {13, 9}, {13, -9}, {9, 13}, {9, -13}, {5, 15}, {5, -15}, {-5, 15}, {-5, -15}, {-9, 13}, {-9, -13}, {-13, 9}, {-13, -9}, {-15, 5}, {-15, -5}, {16, 0}, {0, 16}, {0, -16}, {-16, 0}, {16, 1}, {16, -1}, {1, 16}, {1, -16}, {-1, 16}, {-1, -16}, {-16, 1}, {-16, -1}, {16, 2}, {16, -2}, {14, 8}, {14, -8}, {8, 14}, {8, -14}, {2, 16}, {2, -16}, {-2, 16}, {-2, -16}, {-8, 14}, {-8, -14}, {-14, 8}, {-14, -8}, {-16, 2}, {-16, -2}, {15, 6}, {15, -6}, {6, 15}, {6, -15}, {-6, 15}, {-6, -15}, {-15, 6}, {-15, -6}, {16, 3}, {16, -3}, {12, 11}, {12, -11}, {11, 12}, {11, -12}, {3, 16}, {3, -16}, {-3, 16}, {-3, -16}, {-11, 12}, {-11, -12}, {-12, 11}, {-12, -11}, {-16, 3}, {-16, -3}, {13, 10}, {13, -10}, {10, 13}, {10, -13}, {-10, 13}, {-10, -13}, {-13, 10}, {-13, -10}, {16, 4}, {16, -4}, {4, 16}, {4, -16}, {-4, 16}, {-4, -16}, {-16, 4}, {-16, -4}, {15, 7}, {15, -7}, {7, 15}, {7, -15}, {-7, 15}, {-7, -15}, {-15, 7}, {-15, -7}, {14, 9}, {14, -9}, {9, 14}, {9, -14}, {-9, 14}, {-9, -14}, {-14, 9}, {-14, -9}, {16, 5}, {16, -5}, {5, 16}, {5, -16}, {-5, 16}, {-5, -16}, {-16, 5}, {-16, -5}, {12, 12}, {12, -12}, {-12, 12}, {-12, -12}, {17, 0}, {15, 8}, {15, -8}, {8, 15}, {8, -15}, {0, 17}, {0, -17}, {-8, 15}, {-8, -15}, {-15, 8}, {-15, -8}, {-17, 0}, {17, 1}, {17, -1}, {13, 11}, {13, -11}, {11, 13}, {11, -13}, {1, 17}, {1, -17}, {-1, 17}, {-1, -17}, {-11, 13}, {-11, -13}, {-13, 11}, {-13, -11}, {-17, 1}, {-17, -1}, {16, 6}, {16, -6}, {6, 16}, {6, -16}, {-6, 16}, {-6, -16}, {-16, 6}, {-16, -6}, {17, 2}, {17, -2}, {2, 17}, {2, -17}, {-2, 17}, {-2, -17}, {-17, 2}, {-17, -2}, {14, 10}, {14, -10}, {10, 14}, {10, -14}, {-10, 14}, {-10, -14}, {-14, 10}, {-14, -10}, {17, 3}, {17, -3}, {3, 17}, {3, -17}, {-3, 17}, {-3, -17}, {-17, 3}, {-17, -3}, {17, 4}, {17, -4}, {16, 7}, {16, -7}, {7, 16}, {7, -16}, {4, 17}, {4, -17}, {-4, 17}, {-4, -17}, {-7, 16}, {-7, -16}, {-16, 7}, {-16, -7}, {-17, 4}, {-17, -4}, {15, 9}, {15, -9}, {9, 15}, {9, -15}, {-9, 15}, {-9, -15}, {-15, 9}, {-15, -9}, {13, 12}, {13, -12}, {12, 13}, {12, -13}, {-12, 13}, {-12, -13}, {-13, 12}, {-13, -12}, {17, 5}, {17, -5}, {5, 17}, {5, -17}, {-5, 17}, {-5, -17}, {-17, 5}, {-17, -5}, {14, 11}, {14, -11}, {11, 14}, {11, -14}, {-11, 14}, {-11, -14}, {-14, 11}, {-14, -11}, {16, 8}, {16, -8}, {8, 16}, {8, -16}, {-8, 16}, {-8, -16}, {-16, 8}, {-16, -8}, {18, 0}, {0, 18}, {0, -18}, {-18, 0}, {18, 1}, {18, -1}, {17, 6}, {17, -6}, {15, 10}, {15, -10}, {10, 15}, {10, -15}, {6, 17}, {6, -17}, {1, 18}, {1, -18}, {-1, 18}, {-1, -18}, {-6, 17}, {-6, -17}, {-10, 15}, {-10, -15}, {-15, 10}, {-15, -10}, {-17, 6}, {-17, -6}, {-18, 1}, {-18, -1}, {18, 2}, {18, -2}, {2, 18}, {2, -18}, {-2, 18}, {-2, -18}, {-18, 2}, {-18, -2}, {18, 3}, {18, -3}, {3, 18}, {3, -18}, {-3, 18}, {-3, -18}, {-18, 3}, {-18, -3}, {16, 9}, {16, -9}, {9, 16}, {9, -16}, {-9, 16}, {-9, -16}, {-16, 9}, {-16, -9}, {17, 7}, {17, -7}, {13, 13}, {13, -13}, {7, 17}, {7, -17}, {-7, 17}, {-7, -17}, {-13, 13}, {-13, -13}, {-17, 7}, {-17, -7}, {18, 4}, {18, -4}, {14, 12}, {14, -12}, {12, 14}, {12, -14}, {4, 18}, {4, -18}, {-4, 18}, {-4, -18}, {-12, 14}, {-12, -14}, {-14, 12}, {-14, -12}, {-18, 4}, {-18, -4}, {15, 11}, {15, -11}, {11, 15}, {11, -15}, {-11, 15}, {-11, -15}, {-15, 11}, {-15, -11}, {18, 5}, {18, -5}, {5, 18}, {5, -18}, {-5, 18}, {-5, -18}, {-18, 5}, {-18, -5}, {17, 8}, {17, -8}, {8, 17}, {8, -17}, {-8, 17}, {-8, -17}, {-17, 8}, {-17, -8}, {16, 10}, {16, -10}, {10, 16}, {10, -16}, {-10, 16}, {-10, -16}, {-16, 10}, {-16, -10}, {18, 6}, {18, -6}, {6, 18}, {6, -18}, {-6, 18}, {-6, -18}, {-18, 6}, {-18, -6}, {19, 0}, {0, 19}, {0, -19}, {-19, 0}, {19, 1}, {19, -1}, {1, 19}, {1, -19}, {-1, 19}, {-1, -19}, {-19, 1}, {-19, -1}, {19, 2}, {19, -2}, {14, 13}, {14, -13}, {13, 14}, {13, -14}, {2, 19}, {2, -19}, {-2, 19}, {-2, -19}, {-13, 14}, {-13, -14}, {-14, 13}, {-14, -13}, {-19, 2}, {-19, -2}, {15, 12}, {15, -12}, {12, 15}, {12, -15}, {-12, 15}, {-12, -15}, {-15, 12}, {-15, -12}, {19, 3}, {19, -3}, {17, 9}, {17, -9}, {9, 17}, {9, -17}, {3, 19}, {3, -19}, {-3, 19}, {-3, -19}, {-9, 17}, {-9, -17}, {-17, 9}, {-17, -9}, {-19, 3}, {-19, -3}, {18, 7}, {18, -7}, {7, 18}, {7, -18}, {-7, 18}, {-7, -18}, {-18, 7}, {-18, -7}, {19, 4}, {19, -4}, {16, 11}, {16, -11}, {11, 16}, {11, -16}, {4, 19}, {4, -19}, {-4, 19}, {-4, -19}, {-11, 16}, {-11, -16}, {-16, 11}, {-16, -11}, {-19, 4}, {-19, -4}, {19, 5}, {19, -5}, {5, 19}, {5, -19}, {-5, 19}, {-5, -19}, {-19, 5}, {-19, -5}, {18, 8}, {18, -8}, {8, 18}, {8, -18}, {-8, 18}, {-8, -18}, {-18, 8}, {-18, -8}, {17, 10}, {17, -10}, {10, 17}, {10, -17}, {-10, 17}, {-10, -17}, {-17, 10}, {-17, -10}, {14, 14}, {14, -14}, {-14, 14}, {-14, -14}, {15, 13}, {15, -13}, {13, 15}, {13, -15}, {-13, 15}, {-13, -15}, {-15, 13}, {-15, -13}, {19, 6}, {19, -6}, {6, 19}, {6, -19}, {-6, 19}, {-6, -19}, {-19, 6}, {-19, -6}, {20, 0}, {16, 12}, {16, -12}, {12, 16}, {12, -16}, {0, 20}, {0, -20}, {-12, 16}, {-12, -16}, {-16, 12}, {-16, -12}, {-20, 0}, {20, 1}, {20, -1}, {1, 20}, {1, -20}, {-1, 20}, {-1, -20}, {-20, 1}, {-20, -1}, {20, 2}, {20, -2}, {2, 20}, {2, -20}, {-2, 20}, {-2, -20}, {-20, 2}, {-20, -2}, {18, 9}, {18, -9}, {9, 18}, {9, -18}, {-9, 18}, {-9, -18}, {-18, 9}, {-18, -9}, {20, 3}, {20, -3}, {3, 20}, {3, -20}, {-3, 20}, {-3, -20}, {-20, 3}, {-20, -3}, {19, 7}, {19, -7}, {17, 11}, {17, -11}, {11, 17}, {11, -17}, {7, 19}, {7, -19}, {-7, 19}, {-7, -19}, {-11, 17}, {-11, -17}, {-17, 11}, {-17, -11}, {-19, 7}, {-19, -7}, {20, 4}, {20, -4}, {4, 20}, {4, -20}, {-4, 20}, {-4, -20}, {-20, 4}, {-20, -4}, {15, 14}, {15, -14}, {14, 15}, {14, -15}, {-14, 15}, {-14, -15}, {-15, 14}, {-15, -14}, {18, 10}, {18, -10}, {10, 18}, {10, -18}, {-10, 18}, {-10, -18}, {-18, 10}, {-18, -10}, {20, 5}, {20, -5}, {19, 8}, {19, -8}, {16, 13}, {16, -13}, {13, 16}, {13, -16}, {8, 19}, {8, -19}, {5, 20}, {5, -20}, {-5, 20}, {-5, -20}, {-8, 19}, {-8, -19}, {-13, 16}, {-13, -16}, {-16, 13}, {-16, -13}, {-19, 8}, {-19, -8}, {-20, 5}, {-20, -5}, {17, 12}, {17, -12}, {12, 17}, {12, -17}, {-12, 17}, {-12, -17}, {-17, 12}, {-17, -12}, {20, 6}, {20, -6}, {6, 20}, {6, -20}, {-6, 20}, {-6, -20}, {-20, 6}, {-20, -6}, {19, 9}, {19, -9}, {9, 19}, {9, -19}, {-9, 19}, {-9, -19}, {-19, 9}, {-19, -9}, {18, 11}, {18, -11}, {11, 18}, {11, -18}, {-11, 18}, {-11, -18}, {-18, 11}, {-18, -11}, {20, 7}, {20, -7}, {7, 20}, {7, -20}, {-7, 20}, {-7, -20}, {-20, 7}, {-20, -7}, {15, 15}, {15, -15}, {-15, 15}, {-15, -15}, {16, 14}, {16, -14}, {14, 16}, {14, -16}, {-14, 16}, {-14, -16}, {-16, 14}, {-16, -14}, {17, 13}, {17, -13}, {13, 17}, {13, -17}, {-13, 17}, {-13, -17}, {-17, 13}, {-17, -13}, {19, 10}, {19, -10}, {10, 19}, {10, -19}, {-10, 19}, {-10, -19}, {-19, 10}, {-19, -10}, {20, 8}, {20, -8}, {8, 20}, {8, -20}, {-8, 20}, {-8, -20}, {-20, 8}, {-20, -8}, {18, 12}, {18, -12}, {12, 18}, {12, -18}, {-12, 18}, {-12, -18}, {-18, 12}, {-18, -12}, {20, 9}, {20, -9}, {16, 15}, {16, -15}, {15, 16}, {15, -16}, {9, 20}, {9, -20}, {-9, 20}, {-9, -20}, {-15, 16}, {-15, -16}, {-16, 15}, {-16, -15}, {-20, 9}, {-20, -9}, {19, 11}, {19, -11}, {11, 19}, {11, -19}, {-11, 19}, {-11, -19}, {-19, 11}, {-19, -11}, {17, 14}, {17, -14}, {14, 17}, {14, -17}, {-14, 17}, {-14, -17}, {-17, 14}, {-17, -14}, {18, 13}, {18, -13}, {13, 18}, {13, -18}, {-13, 18}, {-13, -18}, {-18, 13}, {-18, -13}, {20, 10}, {20, -10}, {10, 20}, {10, -20}, {-10, 20}, {-10, -20}, {-20, 10}, {-20, -10}, {19, 12}, {19, -12}, {12, 19}, {12, -19}, {-12, 19}, {-12, -19}, {-19, 12}, {-19, -12}, {16, 16}, {16, -16}, {-16, 16}, {-16, -16}, {17, 15}, {17, -15}, {15, 17}, {15, -17}, {-15, 17}, {-15, -17}, {-17, 15}, {-17, -15}, {18, 14}, {18, -14}, {14, 18}, {14, -18}, {-14, 18}, {-14, -18}, {-18, 14}, {-18, -14}, {20, 11}, {20, -11}, {11, 20}, {11, -20}, {-11, 20}, {-11, -20}, {-20, 11}, {-20, -11}, {19, 13}, {19, -13}, {13, 19}, {13, -19}, {-13, 19}, {-13, -19}, {-19, 13}, {-19, -13}, {20, 12}, {20, -12}, {12, 20}, {12, -20}, {-12, 20}, {-12, -20}, {-20, 12}, {-20, -12}, {17, 16}, {17, -16}, {16, 17}, {16, -17}, {-16, 17}, {-16, -17}, {-17, 16}, {-17, -16}, {18, 15}, {18, -15}, {15, 18}, {15, -18}, {-15, 18}, {-15, -18}, {-18, 15}, {-18, -15}, {19, 14}, {19, -14}, {14, 19}, {14, -19}, {-14, 19}, {-14, -19}, {-19, 14}, {-19, -14}, {20, 13}, {20, -13}, {13, 20}, {13, -20}, {-13, 20}, {-13, -20}, {-20, 13}, {-20, -13}, {17, 17}, {17, -17}, {-17, 17}, {-17, -17}, {18, 16}, {18, -16}, {16, 18}, {16, -18}, {-16, 18}, {-16, -18}, {-18, 16}, {-18, -16}, {19, 15}, {19, -15}, {15, 19}, {15, -19}, {-15, 19}, {-15, -19}, {-19, 15}, {-19, -15}, {20, 14}, {20, -14}, {14, 20}, {14, -20}, {-14, 20}, {-14, -20}, {-20, 14}, {-20, -14}, {18, 17}, {18, -17}, {17, 18}, {17, -18}, {-17, 18}, {-17, -18}, {-18, 17}, {-18, -17}, {19, 16}, {19, -16}, {16, 19}, {16, -19}, {-16, 19}, {-16, -19}, {-19, 16}, {-19, -16}, {20, 15}, {20, -15}, {15, 20}, {15, -20}, {-15, 20}, {-15, -20}, {-20, 15}, {-20, -15}, {18, 18}, {18, -18}, {-18, 18}, {-18, -18}, {19, 17}, {19, -17}, {17, 19}, {17, -19}, {-17, 19}, {-17, -19}, {-19, 17}, {-19, -17}, {20, 16}, {20, -16}, {16, 20}, {16, -20}, {-16, 20}, {-16, -20}, {-20, 16}, {-20, -16}, {19, 18}, {19, -18}, {18, 19}, {18, -19}, {-18, 19}, {-18, -19}, {-19, 18}, {-19, -18}, {20, 17}, {20, -17}, {17, 20}, {17, -20}, {-17, 20}, {-17, -20}, {-20, 17}, {-20, -17}, {19, 19}, {19, -19}, {-19, 19}, {-19, -19}, {20, 18}, {20, -18}, {18, 20}, {18, -20}, {-18, 20}, {-18, -20}, {-20, 18}, {-20, -18}, {20, 19}, {20, -19}, {19, 20}, {19, -20}, {-19, 20}, {-19, -20}, {-20, 19}, {-20, -19}, {20, 20}, {20, -20}, {-20, 20}, {-20, -20}}

return Public