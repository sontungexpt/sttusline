local rep = string.rep
local floor = math.floor
local components = {}
local statusline = {}
local M = {}

	return function()
		conf_comp_index = conf_comp_index + 1

		repeat
			pos_in_line = pos_in_line + 1
			 curr_comp = conf_components[conf_comp_index]

			if type(curr_comp) ~= "table" then -- special component or path to component
				if curr_comp == "%=" then -- special component
					statusline[pos_in_line] = "%="
					goto continue
				elseif type(curr_comp) == "number" then -- special component
					statusline[pos_in_line] = rep(" ", floor(curr_comp))
					goto continue
				end

				local has_comp, default_comp = pcall(require, COMP_DIR .. tostring(curr_comp))
				curr_comp = has_comp and default_comp or nil
			elseif type(curr_comp[2]) == "table" then -- has custom config
				local has_comp, default_comp = pcall(require, COMP_DIR .. tostring(curr_comp[1]))
				curr_comp = has_comp and require("sttusline.config").merge_config(default_comp, curr_comp[2])
					or nil
			end

			if curr_comp then
				statusline[pos_in_line] = ""

				if not unique_comps[curr_comp] then
					unique_comps[curr_comp] = true
					curr_comp.__pos = { pos_in_line }

					comp_index = comp_index + 1
					components[comp_index] = curr_comp
					return comp_index, curr_comp, pos_in_line
				else
					curr_comp.__pos[#curr_comp.__pos + 1] = pos_in_line
				end
			end

			conf_comp_index = conf_comp_index + 1
     ::continue::
		until conf_comp_index > len
	end
