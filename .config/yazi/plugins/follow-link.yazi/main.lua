local hovered_url = ya.sync(function()
	local h = cx.active.current.hovered
	return h
end)

return {
    entry = function()
        local h = hovered_url()
        if h and h.link_to then
            ya.err(h.link_to)
            ya.manager_emit("reveal", { path = h.link_to })
        end
    end,
}
