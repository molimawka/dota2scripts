local enemyItemPanel = {}

enemyItemPanel.enable = Menu.AddOptionBool({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel Enable", false)
enemyItemPanel.key = Menu.AddKeyOption({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel Key", Enum.ButtonCode.KEY_SPACE)
enemyItemPanel.mode = Menu.AddOptionCombo({ "Awareness", "EnemyItemPanel" }, "EnemyItemPanel View Mode", { " X", " Y" }, 0)
enemyItemPanel.x =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel x", 0, 1920, 0)
enemyItemPanel.y =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel y", 0, 1080, 0)
enemyItemPanel.opacity = Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel Opacity", 0, 255, 255)
enemyItemPanel.IconSize =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "Icon Size Panel", 24, 48, 32)
enemyItemPanel.enableHero = Menu.AddOptionBool({"Awareness", "EnemyItemPanel"}, "ItemPanel over Hero Enable", false)
enemyItemPanel.modeInHero = Menu.AddOptionCombo({ "Awareness", "EnemyItemPanel" }, "ItemPanel Hero View Mode", { " Line", " 3x3" }, 0)
enemyItemPanel.yPosWithHero =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "Y Position with Hero", -300, 25, -180)
enemyItemPanel.IconSizeOverHero =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "Icon Size over Hero", 24, 64, 32)
enemyItemPanel.opacityHero = Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "ItemPanel Opacity", 0, 255, 255)
enemyItemPanel.enableDebug = Menu.AddOptionBool({"Awareness", "EnemyItemPanel"}, "EIP Debug", false)
enemyItemPanel.font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)

local draw = true;
local item = {}
local itemVal = {}
local imgItem = {}
local imgHero = {}

function enemyItemPanel.OnUpdate()
	if not Engine.IsInGame() or not Heroes.GetLocal() then return end
	local myHero = Heroes.GetLocal()
	if Menu.IsEnabled(enemyItemPanel.enable) then
		enemyItemPanel.Work(myHero)
	end
	
end

function enemyItemPanel.Work(myHero)
	local heroes = Heroes.GetAll()
	for i, h in ipairs(heroes) do
		if not Entity.IsSameTeam(myHero, h) and not NPC.IsIllusion(h) then
			local heroName = string.sub(tostring(NPC.GetUnitName(h)),string.len("npc_dota_hero_") + 1)
			local cachedItems = {}
			itemVal[heroName] = 1
			for p = 0, 8 do
				local itemName
				if Entity.IsEntity(NPC.GetItemByIndex(h, p)) then
					itemName = tostring(Ability.GetName(NPC.GetItemByIndex(h, p)))
					itemVal[heroName] = itemVal[heroName]+1
				else
					itemName = "item_null"
				end
				table.insert(cachedItems, string.sub(itemName ,string.len("item_") + 1))
			end
			item[heroName] = cachedItems
			draw = false
		end
	end
end

function enemyItemPanel.OnDraw()
	local IconSize = Menu.GetValue(enemyItemPanel.IconSize)
	local IconSizeOverHero = Menu.GetValue(enemyItemPanel.IconSizeOverHero)
	local opacity = Menu.GetValue(enemyItemPanel.opacity)
	local opacityHero = Menu.GetValue(enemyItemPanel.opacityHero)
	local myHero = Heroes.GetLocal()
	if not Menu.IsEnabled(enemyItemPanel.enable) then return end
	if draw then return end
	local defX, defY = Renderer.GetScreenSize()
	defX, defY = defX/2, defY/2
	x, y = Menu.GetValue(enemyItemPanel.x), Menu.GetValue(enemyItemPanel.y)
	if Menu.IsKeyDown(enemyItemPanel.key) then
		x, y = Renderer.WorldToScreen(Input.GetWorldCursorPos());
		Menu.SetValue(enemyItemPanel.x, x)
		Menu.SetValue(enemyItemPanel.y, y)
	end
	local x1, y1;
	local heroes = Heroes.GetAll()
	for i, h in ipairs(heroes) do
		if not Entity.IsSameTeam(myHero, h) and not NPC.IsIllusion(h) then 
			if NPC.IsVisible(h) then x1, y1 = Renderer.WorldToScreen(Entity.GetOrigin(h)) end
			local heroName = string.sub(tostring(NPC.GetUnitName(h)),string.len("npc_dota_hero_") + 1)
			local temp
			if imgHero[heroName] == nil then
				if Menu.IsEnabled(enemyItemPanel.enableDebug) then
					Log.Write('EIP DEBUG: Load HeroIcon: '..heroName);
				end
				imgHero[heroName] = Renderer.LoadImage("~/CustomUI/miniheroes/"..heroName..".png");
			end
			if imgHero[heroName] == nil then
				error('Error loading HeroIcon: '..heroName)
			end
			temp = imgHero[heroName]
			Renderer.SetDrawColor(255, 255, 255, opacity)
			Renderer.DrawImage(temp, x, y, IconSize, IconSize)
			if Menu.GetValue(enemyItemPanel.mode) == 0 then
				x = x+IconSize
			else
				y = y+IconSize
			end
			for o, i in ipairs(item[heroName]) do
				if i ~= "null" then
					if imgItem[i] == nil then
						if Menu.IsEnabled(enemyItemPanel.enableDebug) then
							Log.Write('EIP DEBUG: Load ItemIcon: '..i);
						end
						imgItem[i] = Renderer.LoadImage("~/CustomUI/items/"..i..".png");
					end
					if imgHero[heroName] == nil then
						error('Error loading HeroIcon: '..heroName)
					end
					temp = imgItem[i]
					Renderer.SetDrawColor(255, 255, 255, opacity)
					if Entity.IsEntity(NPC.GetItemByIndex(h, o-1)) and math.floor(Ability.GetCooldown(NPC.GetItemByIndex(h, o-1))) > 0 then
						Renderer.SetDrawColor(165, 165, 165, opacity)
					end
					Renderer.DrawImage(temp, x, y, IconSize, IconSize)
					if err then
						Log.Write('EIP DEBUG: Error loading ItemIcon: '..i)
					end
					local cooldown
					if Entity.IsEntity(NPC.GetItemByIndex(h, o-1)) then
						cooldown = tostring(math.floor(Ability.GetCooldown(NPC.GetItemByIndex(h, o-1))))
						Renderer.SetDrawColor(255, 255, 255, opacity)
						Renderer.DrawText(enemyItemPanel.font, x, y, cooldown)
					end
					if Menu.GetValue(enemyItemPanel.mode) == 0 then
						x = x+IconSize
					else
						y = y+IconSize
					end
					if NPC.IsVisible(h) and Menu.IsEnabled(enemyItemPanel.enableHero) then
						Renderer.SetDrawColor(255, 255, 255, opacityHero)
						if Entity.IsEntity(NPC.GetItemByIndex(h, o-1)) and math.floor(Ability.GetCooldown(NPC.GetItemByIndex(h, o-1))) > 0 then
							Renderer.SetDrawColor(165, 165, 165, opacityHero)
						end
						if Menu.GetValue(enemyItemPanel.modeInHero) == 0 then
							Renderer.DrawImage(temp, x1-(IconSizeOverHero*(itemVal[heroName]/2)), y1+Menu.GetValue(enemyItemPanel.yPosWithHero), IconSizeOverHero, IconSizeOverHero)
							Renderer.SetDrawColor(255, 255, 255, opacityHero)
							Renderer.DrawText(enemyItemPanel.font, x1-(IconSizeOverHero*(itemVal[heroName]/2)), y1+Menu.GetValue(enemyItemPanel.yPosWithHero), cooldown)
							x1 = x1+IconSizeOverHero
						end
					end
				end
			end
			if NPC.IsVisible(h) and Menu.IsEnabled(enemyItemPanel.enableHero) and Menu.GetValue(enemyItemPanel.modeInHero) == 1 then
				for o, i in ipairs(item[heroName]) do
					if i ~= "null" then
						if imgItem[i] == nil then
							imgItem[i] = Renderer.LoadImage("~/CustomUI/items/"..i..".png");
						end
						if imgHero[heroName] == nil then
							error('Error loading HeroIcon: '..heroName)
						end
						temp = imgItem[i]
						local cooldown = tostring(math.floor(Ability.GetCooldown(NPC.GetItemByIndex(h, o-1))))
						if Entity.IsEntity(NPC.GetItemByIndex(h, o-1)) and math.floor(Ability.GetCooldown(NPC.GetItemByIndex(h, o-1))) > 0 then
							Renderer.SetDrawColor(165, 165, 165, opacityHero)
						end
						if o > 6 then
							Renderer.SetDrawColor(100, 100, 100, opacityHero)
						end
						Renderer.DrawImage(temp, x1-(IconSizeOverHero*(3/2)), y1+Menu.GetValue(enemyItemPanel.yPosWithHero), IconSizeOverHero, IconSizeOverHero)
						Renderer.SetDrawColor(255, 255, 255, opacityHero)
						Renderer.DrawText(enemyItemPanel.font, x1-(IconSizeOverHero*(3/2)), y1+Menu.GetValue(enemyItemPanel.yPosWithHero), cooldown)
					else
						Renderer.SetDrawColor(0, 0, 0, opacityHero)
						Renderer.DrawFilledRect(x1-(IconSizeOverHero*(3/2)), y1+Menu.GetValue(enemyItemPanel.yPosWithHero), IconSizeOverHero, IconSizeOverHero)
					end
					x1 = x1+IconSizeOverHero
					if o == 3 or o == 6 then
						y1 = y1+IconSizeOverHero
						x1 = x1-IconSizeOverHero*3
					end
				end
			end
			if Menu.GetValue(enemyItemPanel.mode) == 0 then
				x = Menu.GetValue(enemyItemPanel.x)
				y = y+IconSize
			else
				y = Menu.GetValue(enemyItemPanel.y)
				x = x+IconSize
			end
		end
	end
end

return enemyItemPanel
