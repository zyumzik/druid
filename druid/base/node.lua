local component = require("druid.component")

---@class druid.node: druid.component
---@field node node The wrapped GUI node
local M = component.create("node")


local function get_stretch()
	local window_x, window_y = window.get_size()
	local fit = math.min(window_x / gui.get_width(), window_y / gui.get_height())
	if fit == 0 then
		return 1, 1
	end
	return window_x / gui.get_width() / fit, window_y / gui.get_height() / fit
end


---@param node node|string The GUI node or node id
function M:init(node)
	self.node = self:get_node(node)
	self._initial_adjust_mode = gui.get_adjust_mode(self.node)
	self._initial_size_mode = gui.get_size_mode(self.node)
	self._initial_size = gui.get_size(self.node)
	self._initial_position = gui.get_position(self.node)
	self._layout = gui.get_layout()
	self._base_sizes = { [self._layout] = self._initial_size }
	self._base_positions = { [self._layout] = self._initial_position }
	self._stretch_x = false
	self._stretch_y = false
	self._pos_stretch_x = false
	self._pos_stretch_y = false
	self._size_stretch_enabled = false
	self._pos_stretch_enabled = false
end


---Stretch the node through its size instead of its scale
---@param stretch_x boolean Stretch the width
---@param stretch_y boolean Stretch the height
---@return druid.node self The node component itself for chaining
function M:set_size_stretch(stretch_x, stretch_y)
	self._stretch_x = stretch_x
	self._stretch_y = stretch_y
	self._size_stretch_enabled = true
	gui.set_adjust_mode(self.node, gui.ADJUST_FIT)
	gui.set_size_mode(self.node, gui.SIZE_MODE_MANUAL)
	self:_update_size()
	return self
end


---Stretch the node position without changing its scale
---@param stretch_x boolean Stretch the horizontal position
---@param stretch_y boolean Stretch the vertical position
---@return druid.node self The node component itself for chaining
function M:set_pos_stretch(stretch_x, stretch_y)
	self._pos_stretch_x = stretch_x
	self._pos_stretch_y = stretch_y
	self._pos_stretch_enabled = true
	gui.set_adjust_mode(self.node, gui.ADJUST_FIT)
	self:_update_position()
	return self
end


---@private
function M:on_window_resized()
	if gui.get_layout() ~= self._layout then
		return
	end
	if self._size_stretch_enabled then
		self:_update_size()
	end
	if self._pos_stretch_enabled then
		self:_update_position()
	end
end


---@private
function M:on_layout_change()
	if not self._size_stretch_enabled and not self._pos_stretch_enabled then
		return
	end

	local layout = gui.get_layout()
	if self._size_stretch_enabled then
		local size = gui.get_size(self.node)
		local applied_size = self._applied_size
		if not applied_size or size.x ~= applied_size.x or size.y ~= applied_size.y then
			self._base_sizes[layout] = size
		end
	end
	if self._pos_stretch_enabled then
		local position = gui.get_position(self.node)
		local applied_position = self._applied_position
		if not applied_position or position.x ~= applied_position.x or position.y ~= applied_position.y then
			self._base_positions[layout] = position
		end
	end
	self._layout = layout
	gui.set_adjust_mode(self.node, gui.ADJUST_FIT)
	if self._size_stretch_enabled then
		gui.set_size_mode(self.node, gui.SIZE_MODE_MANUAL)
		self:_update_size()
	end
	if self._pos_stretch_enabled then
		self:_update_position()
	end
end


---@private
function M:on_remove()
	if self._size_stretch_enabled then
		gui.set_size(self.node, self._base_sizes[gui.get_layout()] or self._initial_size)
	end
	if self._pos_stretch_enabled then
		gui.set_position(self.node, self._base_positions[gui.get_layout()] or self._initial_position)
	end
	gui.set_adjust_mode(self.node, self._initial_adjust_mode)
	gui.set_size_mode(self.node, self._initial_size_mode)
end


---@private
function M:_update_size()
	local size = vmath.vector3(self._base_sizes[gui.get_layout()] or self._initial_size)
	local stretch_x, stretch_y = get_stretch()
	if self._stretch_x then
		size.x = size.x * stretch_x
	end
	if self._stretch_y then
		size.y = size.y * stretch_y
	end
	gui.set_size(self.node, size)
	self._applied_size = size
end


---@private
function M:_update_position()
	local position = vmath.vector3(self._base_positions[gui.get_layout()] or self._initial_position)
	local stretch_x, stretch_y = get_stretch()
	if self._pos_stretch_x then
		position.x = position.x * stretch_x
	end
	if self._pos_stretch_y then
		position.y = position.y * stretch_y
	end
	gui.set_position(self.node, position)
	self._applied_position = position
end


return M
