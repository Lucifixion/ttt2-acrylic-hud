local base = "acrylic_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local TryT = LANG.TryTranslation

	local row = 40
	local gap = 5

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 275, h = 130},
		minsize = {w = 225, h = 130}
	}

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
		self.sri_text_width_padding = sri_text_width_padding
		--self.secondaryRoleInformationFunc = nil

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:IsResizable()
		return true, true
	end

	function HUDELEMENT:ShouldDraw()
		local c = LocalPlayer()
		local tgt = c:GetObserverTarget()

		if GetGlobalBool("ttt_aspectator_admin_only", false) and not c:IsAdmin() then return false end

		local tgt_is_valid = IsValid(tgt) and tgt:IsPlayer()

		return (tgt_is_valid and GAMEMODE.round_state == ROUND_ACTIVE) or HUDEditor.IsEditing
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - (56 * self.scale + self.size.h)}

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		local defaults = self:GetDefaults()

		self.basecolor = self:GetHUDBasecolor()
		self.scale = math.min(self.size.w / defaults.minsize.w, self.size.h / defaults.minsize.h)
		self.row = math.Round(row * self.scale, 0)
		self.gap = math.Round(gap * self.scale, 0)

		BaseClass.PerformLayout(self)
	end

	-- Returns player's ammo information
	function HUDELEMENT:GetAmmo(ply)
		local weap = ply:GetActiveWeapon()

		if not weap or not ply:Alive() then
			return - 1
		end

		local ammo_inv = weap.Ammo1 and weap:Ammo1() or 0
		local ammo_clip = weap:Clip1() or 0
		local ammo_max = weap.Primary.ClipSize or 0

		return ammo_clip, ammo_max, ammo_inv
	end

	--[[
		This function expects to receive a function as a parameter which later returns a table with the following keys: { text: "", color: Color }
		The function should also take care of managing the visibility by returning nil to tell the UI that nothing should be displayed
	]]--
	function HUDELEMENT:SetSecondaryRoleInfoFunction(func)
		if func and isfunction(func) then
			self.secondaryRoleInformationFunc = func
		end
	end

	function HUDELEMENT:DrawRoleText(text, x, y)
		surface.SetFont("AcrylicRole")

		local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
		local role_scale_multiplier = (self.size.w - self.row - 2 * self.padding) / role_text_width

		role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale

		draw.AdvancedText(text, "AcrylicRole", x, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, role_scale_multiplier)
	end

	local watching_icon = Material("vgui/ttt/watching_icon")

	local icon_armor = Material("vgui/ttt/hud_armor")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced")
	
	local icon_ammo = Material("vgui/ttt/acrylic/hud_ammo")
	local icon_health = Material("vgui/ttt/acrylic/hud_health")

	function HUDELEMENT:Draw()
		-- get target
		local tgt = LocalPlayer():GetObserverTarget()

		-- fallback for HUD switcher
		if not IsValid(tgt) or not tgt:IsPlayer() then
			tgt = LocalPlayer()
		end

		local c, text
		local rd = tgt:AS_GetRoleData()

        c = tgt:AS_GetRoleColor()
        text = TryT(rd.name)

		local armor_enabled = GetGlobalBool("ttt_armor_dynamic", true) and tgt:AS_GetArmor() > 0

        local role_x = self.pos.x
        local role_y = self.pos.y
        local role_w = self.size.w
        local role_h = self.row

        local health_x = self.pos.x
        local health_y = self.pos.y + self.row + self.gap
        local health_w = armor_enabled and ((self.size.w - self.gap) * 0.5) or self.size.w
        local health_h = self.row

        local armor_x = self.pos.x + health_w + self.gap
        local armor_y = self.pos.y + self.row + self.gap
        local armor_w = (self.size.w - self.gap) * 0.5
        local armor_h = self.row

        local ammo_x = self.pos.x
        local ammo_y = self.pos.y + 2 * (self.row + self.gap)
        local ammo_w = self.size.w
        local ammo_h = self.row

		if GetGlobalBool("ttt_aspectator_display_role", true) then
			-- draw role box
			self:DrawBg(role_x, role_y, role_w, role_h, {r = c.r, g = c.g, b = c.b, a = self.basecolor.a})
			self:DrawLines(role_x, role_y, role_w, role_h)

			local img_size = role_h - 2 * self.gap

			if rd then
				draw.FilteredShadowedTexture(role_x + self.gap, role_y + self.gap, img_size, img_size, rd.iconMaterial, 255, COLOR_WHITE, self.scale)
				self:DrawRoleText(text, role_x + role_h, role_y + 0.5 * role_h)
			end
		end

        -- icon size for all small icons
        local icon_size = 16 * self.scale
        local icon_pad = 0.5 * (self.row - icon_size)

        -- draw health box
        self:DrawBg(health_x, health_y, health_w, health_h, self.basecolor)
        self:DrawLines(health_x, health_y, health_w, health_h)

        draw.FilteredShadowedTexture(health_x + icon_pad, health_y + icon_pad, icon_size, icon_size, icon_health, 255, COLOR_WHITE, self.scale)
        draw.AdvancedText(math.max(0, tgt:Health()) .. " / " .. math.max(0, tgt:GetMaxHealth()), "AcrylicBar", health_x + health_h, health_y + 0.5 * health_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)

        -- draw armor box
        if armor_enabled then
            self:DrawBg(armor_x, armor_y, armor_w, armor_h, self.basecolor)
            self:DrawLines(armor_x, armor_y, armor_w, armor_h)

            local icon_mat = tgt:AS_ArmorIsReinforced() and icon_armor_rei or icon_armor

            draw.FilteredShadowedTexture(armor_x + icon_pad, armor_y + icon_pad, icon_size, icon_size, icon_mat, 255, COLOR_WHITE, self.scale)
            draw.AdvancedText(tgt:AS_GetArmor() .. " / " .. (isfunction(tgt.AS_GetMaxArmor) and tgt:AS_GetMaxArmor() or 100), "AcrylicBar", armor_x + armor_h, armor_y + 0.5 * armor_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)
        end

        -- draw ammo box
        self:DrawBg(ammo_x, ammo_y, ammo_w, ammo_h, self.basecolor)
        self:DrawLines(ammo_x, ammo_y, ammo_w, ammo_h)

        local ammo_string = "---"

        local clip, clip_max, ammo, ammo_type = tgt:AS_GetWeapon()
        ammo_type = string.lower(game.GetAmmoTypes()[ammo_type] or "")

        if clip ~= -1 then
            ammo_string = string.format("%i + %02i", clip, ammo)
        end

        draw.FilteredShadowedTexture(ammo_x + icon_pad, ammo_y + icon_pad, icon_size, icon_size, icon_ammo, 255, COLOR_WHITE, self.scale)
        draw.AdvancedText(ammo_string, "AcrylicBar", ammo_x + ammo_h, ammo_y + 0.5 * ammo_h, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)
	end
end
