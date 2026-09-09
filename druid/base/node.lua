local component = require("druid.component")

---@class druid.node: druid.component
---@field node node The wrapped GUI node
local M = component.create("node")


---@param node node|string The GUI node or node id
function M:init(node)
	self.node = self:get_node(node)
end


return M
