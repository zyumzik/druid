local component = require("druid.component")

---@class druid.node: druid.component
---@field node node The wrapped GUI node
---@field stretch_lock_x boolean True if horizontal stretch is locked
---@field stretch_lock_y boolean True if vertical stretch is locked
local M = component.create("node")


local function get_stretch()
	local window_x, window_y = window.get_size()
	local stretch_x = window_x / gui.get_width()
	local stretch_y = window_y / gui.get_height()
	local stretch = math.min(stretch_x, stretch_y)
	return stretch_x / stretch, stretch_y / stretch
end


---@param node node|string The GUI node or node id
function M:init(node)
	self.node = self:get_node(node)
	self.stretch_lock_x = false
	self.stretch_lock_y = false
	self._stretch_x = 1
	self._stretch_y = 1
end


---Lock the Defold stretch adjustment on selected axes
---@param lock_x boolean Lock horizontal stretching
---@param lock_y boolean Lock vertical stretching
---@return druid.node self The node component itself for chaining
function M:set_stretch_lock(lock_x, lock_y)
	self:_update_stretch(lock_x, lock_y)
	self.stretch_lock_x = lock_x
	self.stretch_lock_y = lock_y
	return self
end


---@private
function M:on_window_resized()
	if self.stretch_lock_x or self.stretch_lock_y then
		self:_update_stretch(self.stretch_lock_x, self.stretch_lock_y)
	end
end


---@private
function M:on_layout_change()
	if self.stretch_lock_x or self.stretch_lock_y then
		self:_update_stretch(self.stretch_lock_x, self.stretch_lock_y)
	end
end


---@private
---@param lock_x boolean
---@param lock_y boolean
function M:_update_stretch(lock_x, lock_y)
	local stretch_x, stretch_y = get_stretch()
	local position = gui.get_position(self.node)
	local scale = gui.get_scale(self.node)

	if self.stretch_lock_x or lock_x then
		position.x = position.x * self._stretch_x / (lock_x and stretch_x or 1)
		scale.x = scale.x * self._stretch_x / (lock_x and stretch_x or 1)
	end
	if self.stretch_lock_y or lock_y then
		position.y = position.y * self._stretch_y / (lock_y and stretch_y or 1)
		scale.y = scale.y * self._stretch_y / (lock_y and stretch_y or 1)
	end

	self._stretch_x = lock_x and stretch_x or 1
	self._stretch_y = lock_y and stretch_y or 1
	gui.set_position(self.node, position)
	gui.set_scale(self.node, scale)
end


return M
