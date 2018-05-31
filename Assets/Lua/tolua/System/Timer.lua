--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

-- 所有需要Update的入口，不允许直接使用event.lua里的接口

local setmetatable = setmetatable
local UpdateBeat = UpdateBeat
local Time = Time

Timer = {}

local Timer = Timer
local mt = {__index = Timer}

-- scale false 采用deltaTime计时，true 采用 unscaledDeltaTime计时
function Timer.New(func, duration, loop, scale)
	scale = scale or false and true	
	loop = loop or 1
	return setmetatable({func = func, duration = duration, time = duration, loop = loop, scale = scale, running = false}, mt)	
end

function Timer:Start()
	self.running = true

	if not self.handle then
		self.handle = UpdateBeat:CreateListener(self.Update, self)
	end

	UpdateBeat:AddListener(self.handle)	
end

function Timer:Reset(func, duration, loop, scale)
	self.duration 	= duration
	self.loop		= loop or 1
	self.scale		= scale
	self.func		= func
	self.time		= duration		
end

function Timer:Stop()
	self.running = false

	if self.handle then
		UpdateBeat:RemoveListener(self.handle)	
	end
end

function Timer:Update()
	if not self.running then
		return
	end

	local delta = self.scale and Time.deltaTime or Time.unscaledDeltaTime	
	self.time = self.time - delta
	
	if self.time <= 0 then
		self.func()
		
		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end
		
		if self.loop == 0 then
			self:Stop()
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
end

-- 帧计数，Update执行
FrameTimer = {}

local FrameTimer = FrameTimer
local mt2 = {__index = FrameTimer}

function FrameTimer.New(func, count, loop)	
	local c = Time.frameCount + count
	loop = loop or 1
	return setmetatable({func = func, loop = loop, duration = count, count = c, running = false}, mt2)		
end

function FrameTimer:Reset(func, count, loop)
	self.func = func
	self.duration = count
	self.loop = loop
	self.count = Time.frameCount + count	
end

function FrameTimer:Start()		
	if not self.handle then
		self.handle = UpdateBeat:CreateListener(self.Update, self)
	end
	
	UpdateBeat:AddListener(self.handle)	
	self.running = true
end

function FrameTimer:Stop()	
	self.running = false

	if self.handle then
		UpdateBeat:RemoveListener(self.handle)	
	end
end

function FrameTimer:Update()	
	if not self.running then
		return
	end

	if Time.frameCount >= self.count then
		self.func()	
		
		if self.loop > 0 then
			self.loop = self.loop - 1
		end
		
		if self.loop == 0 then
			self:Stop()
		else
			self.count = Time.frameCount + self.duration
		end
	end
end

-- FixedUpdate计时器
TimerFixed = {}

local TimerFixed = TimerFixed
local mt3 = {__index = TimerFixed}

function TimerFixed.New(func, loop)	
	loop = loop or 1
	return setmetatable({loop = loop, func = func, running = false}, mt3)			
end

function TimerFixed:Start()		
	if not self.handle then	
		self.handle = FixedUpdateBeat:CreateListener(self.Update, self)
	end
	
	self.running = true
	FixedUpdateBeat:AddListener(self.handle)	
end

function TimerFixed:Reset(func, loop)
	self.loop		= loop or 1	
	self.func		= func
end

function TimerFixed:Stop()
	self.running = false

	if self.handle then
		FixedUpdateBeat:RemoveListener(self.handle)	
	end
end

function TimerFixed:Update()	
	if not self.running then
		return
	end

	self.func()		
		
	if self.loop > 0 then
		self.loop = self.loop - 1
		
	    if self.loop == 0 then
		    self:Stop()
	    end
	end
end

-- Update更新
TimerUpdate = {}

local TimerUpdate = TimerUpdate
local mt4 = {__index = TimerUpdate}

function TimerUpdate.New(func, loop)
	loop = loop or 1
	return setmetatable({func = func, loop = loop, running = false}, mt4)	
end

function TimerUpdate:Start()
	self.running = true

	if not self.handle then
		self.handle = UpdateBeat:CreateListener(self.Update, self)
	end

	UpdateBeat:AddListener(self.handle)	
end

function TimerUpdate:Reset(func, loop)
	self.loop		= loop or 1
	self.func		= func	
end

function TimerUpdate:Stop()
	self.running = false

	if self.handle then
		UpdateBeat:RemoveListener(self.handle)	
	end
end

function TimerUpdate:Update()
	if not self.running then
		return
	end
	
	self.func()
		
	if self.loop > 0 then
		self.loop = self.loop - 1
	end
		
	if self.loop == 0 then
		self:Stop()
	end
end