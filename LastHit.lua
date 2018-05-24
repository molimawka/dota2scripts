local LastHit = {}

local key = Menu.AddKeyOption({"Utility"}, "Last Hit Key", Enum.ButtonCode.KEY_SPACE)

local target

function LastHit.OnUpdate()
	if not Menu.IsKeyDown(key) or not Engine.IsInGame() or not Heroes.GetLocal() then return end
	local myHero = Heroes.GetLocal()
	LastHit.Work(myHero)
	
end
function LastHit.Work(myHero)
	if not myHero then return end
	if not NPC.IsVisible(myHero) then return end
	local radius = NPC.GetAttackRange(myHero)
	local creeps = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
	for i, npc in ipairs(creeps) do
		local oneHitDamage = LastHit.GetOneHitDamageVersus(myHero, npc)
		if Entity.IsNPC(npc) and NPC.IsLaneCreep(npc) and Entity.IsAlive(npc) and not Entity.IsDormant(npc) then
			local creepDamage = (NPC.GetTrueDamage(npc) * NPC.GetArmorDamageMultiplier(npc)) / 2
			if Entity.GetHealth(npc) <= oneHitDamage + creepDamage  then
				target = npc
				Player.AttackTarget(Players.GetLocal(), myHero, npc)
			end
		end
	end
end

function LastHit.OnDraw()
	local myHero = Heroes.GetLocal()
	if not target then return end
	if not NPC.IsVisible(myHero) then return end
	if target and Entity.IsNPC(target) and Entity.IsAlive(target) and NPC.IsVisible(target) and not Entity.IsDormant(target) then

		local size_x, size_y = Renderer.GetScreenSize()
		local x1, y1 = Renderer.WorldToScreen(Entity.GetAbsOrigin(target))
		local radius = 16
		Renderer.SetDrawColor(0, 255, 255, 150)
		if x1 < size_x and x1 > 0 and y1 < size_y and y1 > 0 then
			local x4, y4, x3, y3, visible3
			local dergee = 90
			for angle = 0, 360 / dergee do
				x4 = 0 * math.cos(angle * dergee / 57.3) - radius * math.sin(angle * dergee / 57.3)
				y4 = radius * math.cos(angle * dergee / 57.3) + 0 * math.sin(angle * dergee / 57.3)
				x3,y3 = Renderer.WorldToScreen(Entity.GetAbsOrigin(target) + Vector(x4,y4,0))
				Renderer.DrawLine(x1,y1,x3,y3)
				x1,y1 = Renderer.WorldToScreen(Entity.GetAbsOrigin(target) + Vector(x4,y4,0))
			end
		end
	end
end

function LastHit.GetOneHitDamageVersus(myHero, npc)
	if not myHero or not npc then return 0 end
	local damage = NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(npc)

	if NPC.GetUnitName(myHero) == "npc_dota_hero_invoker" and Invoker.GetInstances(myHero) ~= "EEE" then
		local E = NPC.GetAbility(myHero, "invoker_exort")
		local extra_damage = 12 * Ability.GetLevel(E)
		damage = damage + extra_damage
	end
	return damage
end

return LastHit
