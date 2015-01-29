if pipeworks.enable_mese_tube then
	local mese_noctr_textures = {"pipeworks_mese_tube_noctr_1.png", "pipeworks_mese_tube_noctr_2.png", "pipeworks_mese_tube_noctr_3.png",
				     "pipeworks_mese_tube_noctr_4.png", "pipeworks_mese_tube_noctr_5.png", "pipeworks_mese_tube_noctr_6.png"}
	local mese_plain_textures = {"pipeworks_mese_tube_plain_1.png", "pipeworks_mese_tube_plain_2.png", "pipeworks_mese_tube_plain_3.png",
				     "pipeworks_mese_tube_plain_4.png", "pipeworks_mese_tube_plain_5.png", "pipeworks_mese_tube_plain_6.png"}
	local mese_end_textures = {"pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png",
				   "pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png"}
	local mese_short_texture = "pipeworks_mese_tube_short.png"
	local mese_inv_texture = "pipeworks_mese_tube_inv.png"
	local function update_formspec(pos)
		local meta = minetest.get_meta(pos)
		local old_formspec = meta:get_string("formspec")
		if string.find(old_formspec, "button1") then -- Old version
			local inv = meta:get_inventory()
			for i = 1, 6 do
				for _, stack in ipairs(inv:get_list("line"..i)) do
					minetest.item_drop(stack, "", pos)
				end
			end
		end
		local buttons_formspec = ""
		for i = 0, 5 do
			buttons_formspec = buttons_formspec .. fs_helpers.cycling_button(meta,
				"image_button[7,"..(i)..";1,1", "l"..(i+1).."s",
				{{text="",texture="pipeworks_button_off.png", addopts="false;false;pipeworks_button_interm.png"}, {text="",texture="pipeworks_button_on.png", addopts="false;false;pipeworks_button_interm.png"}})
		end
		meta:set_string("formspec",
			"size[8,11]"..
			"list[context;line1;1,0;6,1;]"..
			"list[context;line2;1,1;6,1;]"..
			"list[context;line3;1,2;6,1;]"..
			"list[context;line4;1,3;6,1;]"..
			"list[context;line5;1,4;6,1;]"..
			"list[context;line6;1,5;6,1;]"..
			"image[0,0;1,1;pipeworks_white.png]"..
			"image[0,1;1,1;pipeworks_black.png]"..
			"image[0,2;1,1;pipeworks_green.png]"..
			"image[0,3;1,1;pipeworks_yellow.png]"..
			"image[0,4;1,1;pipeworks_blue.png]"..
			"image[0,5;1,1;pipeworks_red.png]"..
			buttons_formspec..
			"list[current_player;main;0,7;8,4;]")
	end
	pipeworks.register_tube("pipeworks:mese_tube", "Sorting Pneumatic Tube Segment", mese_plain_textures, mese_noctr_textures,
				mese_end_textures, mese_short_texture, mese_inv_texture,
				{tube = {can_go = function(pos, node, velocity, stack)
						 local tbl, tbln = {}, 0
						 local found, foundn = {}, 0
						 local meta = minetest.get_meta(pos)
						 local inv = meta:get_inventory()
						 local name = stack:get_name()
						 for i, vect in ipairs(pipeworks.meseadjlist) do
							 if meta:get_int("l"..i.."s") == 1 then
								 local invname = "line"..i
								 local is_empty = true
								 for _, st in ipairs(inv:get_list(invname)) do
									 if not st:is_empty() then
										 is_empty = false
										 if st:get_name() == name then
											 foundn = foundn + 1
											 found[foundn] = vect
										 end
									 end
								 end
								 if is_empty then
									 tbln = tbln + 1
									 tbl[tbln] = vect
								 end
							 end
						 end
						 return (foundn > 0) and found or tbl
					end},
				on_construct = function(pos)
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					for i = 1, 6 do
						meta:set_int("l"..tostring(i).."s", 1)
						inv:set_size("line"..tostring(i), 6*1)
					end
					update_formspec(pos)
					meta:set_string("infotext", "Mese pneumatic tube")
				end,
				on_punch = update_formspec,
				on_receive_fields = function(pos, formname, fields, sender)
					fs_helpers.on_receive_fields(pos, fields)
					update_formspec(pos)
				end,
				can_dig = function(pos, player)
					update_formspec(pos) -- so non-virtual items would be dropped for old tubes
					return true
				end,
				allow_metadata_inventory_put = function(pos, listname, index, stack, player)
					update_formspec(pos) -- For old tubes
					local inv = minetest.get_meta(pos):get_inventory()
					local stack_copy = ItemStack(stack)
					stack_copy:set_count(1)
					inv:set_stack(listname, index, stack_copy)
					return 0
				end,
				allow_metadata_inventory_take = function(pos, listname, index, stack, player)
					update_formspec(pos) -- For old tubes
					local inv = minetest.get_meta(pos):get_inventory()
					inv:set_stack(listname, index, ItemStack(""))
					return 0
				end,
				allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
					qupdate_formspec(pos) -- For old tubes
					local inv = minetest.get_meta(pos):get_inventory()
					inv:set_stack(from_list, from_index, ItemStack(""))
					return 0
				end,
				}, true) -- Must use old tubes, since the textures are rotated with 6d ones
end

minetest.register_craft( {
	output = "pipeworks:mese_tube_1 2",
	recipe = {
	        { "homedecor:plastic_sheeting", "homedecor:plastic_sheeting", "homedecor:plastic_sheeting" },
	        { "", "default:mese_crystal", "" },
	        { "homedecor:plastic_sheeting", "homedecor:plastic_sheeting", "homedecor:plastic_sheeting" }
	},
})

minetest.register_craft( {
	type = "shapeless",
	output = "pipeworks:mese_tube_000000",
	recipe = {
	    "pipeworks:tube_1",
		"default:mese_crystal_fragment",
		"default:mese_crystal_fragment",
		"default:mese_crystal_fragment",
		"default:mese_crystal_fragment"
	},
})