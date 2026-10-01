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
	self._layout = gui.get_layout()
	self._base_sizes = { [self._layout] = self._initial_size }
	self._stretch_x = false
	self._stretch_y = false
	self._size_stretch_enabled = false
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


---@private
function M:on_window_resized()
	if self._size_stretch_enabled and gui.get_layout() == self._layout then
		self:_update_size()
	end
end


---@private
function M:on_layout_change()
	if not self._size_stretch_enabled then
		return
	end

	local layout = gui.get_layout()
	local size = gui.get_size(self.node)
	local applied_size = self._applied_size
	if not applied_size or size.x ~= applied_size.x or size.y ~= applied_size.y then
		self._base_sizes[layout] = size
	end
	self._layout = layout
	gui.set_adjust_mode(self.node, gui.ADJUST_FIT)
	gui.set_size_mode(self.node, gui.SIZE_MODE_MANUAL)
	self:_update_size()
end


---@private
function M:on_remove()
	gui.set_size(self.node, self._base_sizes[gui.get_layout()] or self._initial_size)
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


return M
