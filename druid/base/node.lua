local component = require("druid.component")
local helper = require("druid.helper")

---@class druid.node: druid.component
---@field node node The wrapped GUI node
---@field stretch_lock_x boolean True if horizontal stretch is locked
---@field stretch_lock_y boolean True if vertical stretch is locked
local M = component.create("node")


---@param node node|string The GUI node or node id
function M:init(node)
	self.node = self:get_node(node)
	self._initial_scale = gui.get_scale(self.node)
	self.stretch_lock_x = false
	self.stretch_lock_y = false
end


---Lock the Defold stretch scaling on selected axes
---@param lock_x boolean Lock horizontal stretch scaling
---@param lock_y boolean Lock vertical stretch scaling
---@return druid.node self The node component itself for chaining
function M:set_stretch_lock(lock_x, lock_y)
	self.stretch_lock_x = lock_x
	self.stretch_lock_y = lock_y
	self:_update_stretch_scale()
	return self
end


---@private
function M:on_window_resized()
	if self.stretch_lock_x or self.stretch_lock_y then
		self:_update_stretch_scale()
	end
end


---@private
function M:on_layout_change()
	self._initial_scale = gui.get_scale(self.node)
	if self.stretch_lock_x or self.stretch_lock_y then
		self:_update_stretch_scale()
	end
end


---@private
function M:_update_stretch_scale()
	local stretch_x, stretch_y = helper.get_screen_aspect_koef()
	local scale = vmath.vector3(self._initial_scale)

	if self.stretch_lock_x then
		scale.x = scale.x / stretch_x
	end
	if self.stretch_lock_y then
		scale.y = scale.y / stretch_y
	end

	gui.set_scale(self.node, scale)
end


return M
