local rawget = rawget
local setmetatable = setmetatable
local type = type
local Vector2 = Vector2
local zero = Vector2.zero

local Rect = 
{
	center = Vector2.zero,
	extents = Vector2.zero,
}

local get = tolua.initget(Rect)

Rect.__index = function(t,k)
	local var = rawget(Rect, k)
	
	if var == nil then							
		var = rawget(get, k)
		
		if var ~= nil then
			return var(t)
		end
	end
	
	return var
end

Rect.__call = function(t, center, size)
	return setmetatable({center = center, extents = size * 0.5}, Rect)		
end

function Rect.Zero()
    return setmetatable({}, Rect)	
end

function Rect.New(center, size)	
	return setmetatable({center = center, extents = size * 0.5}, Rect)		
end

function Rect:Get()
	local size = self:GetSize()	
	return self.center, size
end

function Rect:GetSize()
	return self.extents * 2
end

function Rect:SetCenter(value)
    self.center = value
end

function Rect:SetSize(value)
	self.extents = value * 0.5
end

function Rect:GetMin()
	return self.center - self.extents
end

function Rect:SetMin(value)
	self:SetMinMax(value, self:GetMax())
end

function Rect:GetMax()
	return self.center + self.extents
end

function Rect:SetMax(value)
	self:SetMinMax(self:GetMin(), value)
end

function Rect:SetMinMax(min, max)
	self.extents = (max - min) * 0.5
	self.center = min + self.extents
end

function Rect:Encapsulate(point)
	self:SetMinMax(Vector2.Min(self:GetMin(), point), Vector2.Max(self:GetMax(), point))
end

function Rect:Expand(amount)	
	if type(amount) == "number" then
		amount = amount * 0.5
		self.extents:Add(Vector2.New(amount, amount))
	else
		self.extents:Add(amount * 0.5)
	end
end

function Rect:Intersects(rect)
	local min = self:GetMin()
	local max = self:GetMax()
	
	local min2 = rect:GetMin()
	local max2 = rect:GetMax()
	
	return min.x <= max2.x and max.x >= min2.x and min.y <= max2.y and max.y >= min2.y
end    

function Rect:Contains(p)
	local min = self:GetMin()
	local max = self:GetMax()
	
	if p.x < min.x or p.y < min.y or p.x > max.x or p.y > max.y then
		return false
	end
	
	return true
end

function Rect:ClosestPoint(point)
	local t = point - self:GetCenter()
	local closest = {t.x, t.y}
	local et = self.extents
	local extent = {et.x, et.y}
	local distance = 0
	local delta
	
	for i = 1, 3 do	
		if  closest[i] < - extent[i] then		
			delta = closest[i] + extent[i]
			distance = distance + delta * delta
			closest[i] = -extent[i]
		elseif closest[i] > extent[i]  then
			delta = closest[i] - extent[i]
			distance = distance + delta * delta
			closest[i] = extent[i]
		end
	end
		
	if distance == 0 then	    
		return rkPoint, 0
	else	
		outPoint = closest + self:GetCenter()
		return outPoint, distance
	end
end

function Rect:Destroy()
	self.center	= nil
	self.size	= nil
end

Rect.__tostring = function(self)	
	return string.format("Center: %s, Extents %s", tostring(self.center), tostring(self.extents))
end

Rect.__eq = function(a, b)
	return a.center == b.center and a.extents == b.extents
end

get.size = Rect.GetSize
get.min = Rect.GetMin
get.max = Rect.GetMax

UnityEngine.Rect = Rect
setmetatable(Rect, Rect)
return Rect
