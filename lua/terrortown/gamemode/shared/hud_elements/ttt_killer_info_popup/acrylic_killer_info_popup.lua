local base = "acrylic_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local row = 40
	local gap = 5

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 176},
		minsize = {w = 350, h = 213}
	}

	HUDELEMENT.icon_headshot = Material("vgui/ttt/huds/icon_headshot")

	local icon_health = Material("vgui/ttt/acrylic/hud_health.vmt")
	local icon_ammo = Material("vgui/ttt/acrylic/hud_ammo")

	local icon_armor = Material("vgui/ttt/hud_armor.vmt")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced.vmt")

	local color_headshot = Color(240, 80, 45, 180)

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("acrylic")
		if hud then
			hud:ForceElement(self.id)
		end

		-- set as fallback default, other skins have to be set to true!
		self.disabledUnlessForced = true
	end

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.basecolor = self:GetHUDBasecolor()
		self.scale = appearance.GetGlobalScale()
		self.row = math.Round(row * self.scale, 0)
		self.gap = math.Round(gap * self.scale, 0)

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() - (110 * self.scale + self.size.w)), y = math.Round(ScrH() * 0.5 - self.size.h * 0.5)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end

	function HUDELEMENT:ShouldDraw()
		return KILLER_INFO.data.render or HUDEditor.IsEditing
	end
	-- parameter overwrites end

	function HUDELEMENT:DrawRoleText(text, x, y)
		surface.SetFont("AcrylicRole")

		local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
		local role_scale_multiplier = (self.size.w - self.row - 2 * self.padding) / role_text_width

		role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale

		draw.AdvancedText(text, "AcrylicRole", x, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, role_scale_multiplier)
	end

	function HUDELEMENT:Draw()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		self:DrawHelper(x, y, w, h)
	end

	-- added to a helper function to use return instead of nested ifs
	function HUDELEMENT:DrawHelper(x, y, w, h)
		local armor_enabled = GetGlobalBool("ttt_armor_dynamic", true) and KILLER_INFO.data.killer_armor > 0

		local weapon_enabled = KILLER_INFO.data.mode ~= "killer_self_no_weapon" and KILLER_INFO.data.mode ~= "killer_no_weapon" and KILLER_INFO.data.mode ~= "killer_world"
		local ammo_enabled = weapon_enabled and KILLER_INFO.data.killer_weapon_clip >= 0

		local header_x = self.pos.x
		local header_y = self.pos.y
		local header_w = self.size.w
		local header_h = self.row

		local avatar_x = self.pos.x
		local avatar_y = self.pos.y + self.row + self.gap
		local avatar_w = self.gap + self.row * 2
		local avatar_h = self.gap + self.row * 2

		local offset_x = self.pos.x + avatar_w + self.gap
		local offset_w = self.size.w - avatar_w - self.gap

		local role_x = offset_x
		local role_y = self.pos.y + self.row + self.gap
		local role_w = offset_w
		local role_h = self.row

		local health_x = self.pos.x + 2 * (self.row + self.gap)
		local health_y = self.pos.y + 2 * (self.row + self.gap)
		local health_w = armor_enabled and ((offset_w - self.gap) * 0.5) or offset_w
		local health_h = self.row

		local armor_x = health_x + health_w + self.gap
		local armor_y = self.pos.y + 2 * (self.row + self.gap)
		local armor_w = (offset_w - self.gap) * 0.5
		local armor_h = self.row

		local weapon_x = self.pos.x
		local weapon_y = self.pos.y + 3 * (self.row + self.gap)
		local weapon_w = ammo_enabled and (self.size.w - (offset_w + self.gap) * 0.5) or self.size.w
		local weapon_h = self.row

		local ammo_x = weapon_x + weapon_w + self.gap
		local ammo_y = self.pos.y + 3 * (self.row + self.gap)
		local ammo_w = (offset_w - self.gap) * 0.5
		local ammo_h = self.row

		local avatar_size = avatar_h - 2 * self.gap
		local img_size = role_h - 2 * self.gap

		local icon_size = 16 * self.scale
		local icon_pad = 0.5 * (self.row - icon_size)

		self:DrawBg(header_x, header_y, header_w, header_h, self.basecolor)
		self:DrawLines(header_x, header_y, header_w, header_h)

		draw.AdvancedText(LANG.GetTranslation("ttt_rs_you_were_killed"), "AcrylicRole", header_x + 2 * self.gap, header_y + 0.5 * header_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)

		-- draw avatar box
		self:DrawBg(avatar_x, avatar_y, avatar_w, avatar_h, self.basecolor)
		self:DrawLines(avatar_x, avatar_y, avatar_w, avatar_h)

		draw.FilteredShadowedTexture(avatar_x + self.gap, avatar_y + self.gap, avatar_size, avatar_size, KILLER_INFO.data.killer_icon, 255, COLOR_WHITE, self.scale)

		-- draw role box
		local c = KILLER_INFO.data.killer_role_color
		local world = KILLER_INFO.data.mode == "killer_world"

		self:DrawBg(role_x, role_y, role_w, role_h, {r = c.r, g = c.g, b = c.b, a = self.basecolor.a})
		self:DrawLines(role_x, role_y, role_w, role_h)

		if not world then
			draw.FilteredShadowedTexture(
				role_x + self.gap, 
				role_y + self.gap, 
				img_size, 
				img_size, 
				KILLER_INFO.data.killer_role_icon, 
				255, 
				COLOR_WHITE, 
				self.scale
			)
		end

		draw.AdvancedText(KILLER_INFO.data.killer_name, "AcrylicRole", role_x + (world and 2 * self.gap or role_h), role_y + 0.5 * role_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)

		-- draw health box
		self:DrawBg(health_x, health_y, health_w, health_h, self.basecolor)
		self:DrawLines(health_x, health_y, health_w, health_h)

		draw.FilteredShadowedTexture(health_x + icon_pad, health_y + icon_pad, icon_size, icon_size, icon_health, 255, COLOR_WHITE, self.scale)
		draw.AdvancedText(math.max(0, KILLER_INFO.data.killer_health or 0) .. " / " .. math.max(0, KILLER_INFO.data.killer_health_max or 0), "AcrylicBar", health_x + health_h, health_y + 0.5 * health_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)

		-- draw armor box
		if armor_enabled then
            self:DrawBg(armor_x, armor_y, armor_w, armor_h, self.basecolor)
            self:DrawLines(armor_x, armor_y, armor_w, armor_h)

            local icon_mat = KILLER_INFO.data.killer_armor > GetGlobalInt("ttt_armor_threshold_for_reinforced", 0) and icon_armor_rei or icon_armor

            draw.FilteredShadowedTexture(armor_x + icon_pad, armor_y + icon_pad, icon_size, icon_size, icon_mat, 255, COLOR_WHITE, self.scale)
            draw.AdvancedText(KILLER_INFO.data.killer_armor .. " / " .. KILLER_INFO.data.killer_armor_max, "AcrylicBar", armor_x + armor_h, armor_y + 0.5 * armor_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)
		end

		self:DrawBg(weapon_x, weapon_y, weapon_w, weapon_h, self.basecolor)
		self:DrawLines(weapon_x, weapon_y, weapon_w, weapon_h)

		draw.FilteredTexture(weapon_x + self.gap, weapon_y + self.gap, img_size, img_size, weapon_enabled and KILLER_INFO.data.killer_weapon_icon or KILLER_INFO.data.damage_type_icon)
		draw.AdvancedText(
			string.upper(weapon_enabled and KILLER_INFO.data.killer_weapon_name or KILLER_INFO.data.damage_type_name),
			"AcrylicBar",
			weapon_x + weapon_h,
			weapon_y + 0.5 * armor_h,
			COLOR_WHITE,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER,
			true,
			self.scale
		)

		if not weapon_enabled then return end

		if KILLER_INFO.data.killer_weapon_head then
			draw.FilteredShadowedTexture(
				weapon_x + weapon_w - img_size - self.gap,
				weapon_y + self.gap,
				img_size,
				img_size,
				self.icon_headshot,
				color_headshot.a,
				color_headshot
			)
		end

		if ammo_enabled then
			self:DrawBg(ammo_x, ammo_y, ammo_w, ammo_h, self.basecolor)
			self:DrawLines(ammo_x, ammo_y, ammo_w, ammo_h)

			local ammo_string = string.format("%i + %02i", KILLER_INFO.data.killer_weapon_clip, KILLER_INFO.data.killer_weapon_ammo)

			draw.FilteredShadowedTexture(ammo_x + icon_pad, ammo_y + icon_pad, icon_size, icon_size, icon_ammo, 255, COLOR_WHITE, self.scale)
			draw.AdvancedText(ammo_string, "AcrylicBar", ammo_x + ammo_h, ammo_y + 0.5 * ammo_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)
		end
	end
end