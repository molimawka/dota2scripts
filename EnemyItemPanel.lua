local enemyItemPanel = {}

enemyItemPanel.enable = Menu.AddOptionBool({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel Enable", false)
enemyItemPanel.key = Menu.AddKeyOption({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel Key", Enum.ButtonCode.KEY_SPACE)
enemyItemPanel.x =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel x", 0, 1920, 0)
enemyItemPanel.y =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "EnemyItemPanel y", 0, 1080, 0)
enemyItemPanel.IconSize =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "Icon Size", 24, 48, 32)
enemyItemPanel.IntRColor =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "R Color", 0, 255, 255)
enemyItemPanel.IntGColor =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "G Color", 0, 255, 255)
enemyItemPanel.IntBColor =  Menu.AddOptionSlider({"Awareness", "EnemyItemPanel"}, "B Color", 0, 255, 255)
enemyItemPanel.font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)

local draw = true;
local item = {}
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
		if Entity.IsSameTeam(myHero, h) or NPC.IsIllusion(h) then return end
		local heroName = string.sub(tostring(NPC.GetUnitName(h)),string.len("npc_dota_hero_") + 1)
		local cachedItems = {}
		for p = 0, 8 do
			local itemName
			if Entity.IsEntity(NPC.GetItemByIndex(h, p)) then
				itemName = tostring(Ability.GetName(NPC.GetItemByIndex(h, p)))
			else
				itemName = "item_null"
			end
			table.insert(cachedItems, string.sub(itemName ,string.len("item_") + 1))
		end
		item[heroName] = cachedItems
	end
	draw = false
end

function enemyItemPanel.OnDraw()
	local r, g, b = Menu.GetValue(enemyItemPanel.IntRColor), Menu.GetValue(enemyItemPanel.IntGColor), Menu.GetValue(enemyItemPanel.IntBColor)
	local IconSize = Menu.GetValue(enemyItemPanel.IconSize)
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
	local heroes = Heroes.GetAll()
	for i, h in ipairs(heroes) do
		if Entity.IsSameTeam(myHero, h) or NPC.IsIllusion(h) then return end
		local heroName = string.sub(tostring(NPC.GetUnitName(h)),string.len("npc_dota_hero_") + 1)
		local temp
		if imgHero[heroName] == nil then
			imgHero[heroName] = Renderer.LoadImage("~/CustomUI/miniheroes/"..heroName..".png");
		end
		temp = imgHero[heroName]
		Renderer.SetDrawColor(255, 255, 255, 255)
		Renderer.DrawImage(temp, x, y, IconSize, IconSize)
		x = x+IconSize
		for o, i in ipairs(item[heroName]) do
			if i ~= "null" then
				if imgItem[i] == nil then
					imgItem[i] = Renderer.LoadImage("~/CustomUI/items/"..i..".png");
				end
				temp = imgItem[i]
				Renderer.SetDrawColor(255, 255, 255, 255)
				Renderer.DrawImage(temp, x, y, IconSize, IconSize)
				if Entity.IsEntity(NPC.GetItemByIndex(h, o-1)) then
					local cooldown = tostring(math.floor(Ability.GetCooldown(NPC.GetItemByIndex(h, o-1))))
					Renderer.SetDrawColor(r, g, b, 255)
					Renderer.DrawText(enemyItemPanel.font, x, y, cooldown)
				end
				x = x+IconSize
			end
		end
		x = Menu.GetValue(enemyItemPanel.x)
		y = y+IconSize
	end
end

return enemyItemPanel
