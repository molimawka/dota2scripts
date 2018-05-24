local LastHit = {}

local key = Menu.AddKeyOption({"Utility"}, "Last Hit Key", Enum.ButtonCode.KEY_SPACE)

function LastHit.OnDraw()
	if not Menu.IsKeyDown(key) then return end
	
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if not NPC.IsVisible(myHero) then return end
	local radius = NPC.GetAttackRange(myHero)
	local creeps = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
	for i, npc in ipairs(creeps) do
		local oneHitDamage = LastHit.GetOneHitDamageVersus(myHero, npc)
		if Entity.IsNPC(npc) and NPC.IsLaneCreep(npc) and Entity.IsAlive(npc) and not Entity.IsDormant(npc) then

			local x, y, visible = Renderer.WorldToScreen(Entity.GetAbsOrigin(npc))
			local size = 10
			local creepDamage = (NPC.GetTrueDamage(npc) * NPC.GetArmorDamageMultiplier(npc)) / 2
			if Entity.GetHealth(npc) <= oneHitDamage + creepDamage  then
				Renderer.SetDrawColor(255, 255, 0, 150)
				Renderer.DrawFilledRect(x-size, y-size, 2*size, 2*size)
				Player.AttackTarget(Players.GetLocal(), myHero, npc)
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
