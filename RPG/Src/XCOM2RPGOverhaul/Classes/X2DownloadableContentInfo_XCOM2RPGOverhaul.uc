class X2DownloadableContentInfo_XCOM2RPGOverhaul extends X2DownloadableContentInfo config (RPG);

struct AbilityWeaponCategoryRestriction
{
	var name AbilityName;
	var array<name> WeaponCategories;
};

var config array<AbilityWeaponCategoryRestriction> AbilityWeaponCategoryRestrictions;

var config int ShotgunAimBonus;
var config int ShotgunCritBonus;
var config int CannonDamageBonus;

static event OnPostTemplatesCreated()
{
	PatchAbilitiesWeaponCondition();
	PatchWeapons();
	PatchSquadSight();
	PatchSniperStandardFire();
	PatchLongWatch();
	PatchSuppression();
	PatchSkirmisherGrapple();
	PatchThrowClaymore();
}

static function PatchAbilitiesWeaponCondition()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Condition_WeaponCategory	WeaponCondition;
	local AbilityWeaponCategoryRestriction Restriction;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.AbilityWeaponCategoryRestrictions(Restriction)
	{
		Template = TemplateManager.FindAbilityTemplate(Restriction.AbilityName);
		if (Template != none)
		{
			WeaponCondition = new class'X2Condition_WeaponCategory';
			WeaponCondition.MatchWeaponCategories = Restriction.WeaponCategories;
			Template.AbilityTargetConditions.AddItem(WeaponCondition);
		}
	}
}

static function PatchWeapons()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<name> TemplateNames;
	local array<X2DataTemplate> DifficultyVariants;
	local name TemplateName;
	local X2DataTemplate ItemTemplate;
	local X2WeaponTemplate WeaponTemplate;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ItemTemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficultyVariants);
		// Iterate over all variants
		
		foreach DifficultyVariants(ItemTemplate)
		{
			WeaponTemplate = X2WeaponTemplate(ItemTemplate);
			if (WeaponTemplate != none)
			{
				switch (WeaponTemplate.WeaponCat)
				{
					case 'rifle':
						WeaponTemplate.Abilities.AddItem('FullAutoFire');
						if (InStr(string(WeaponTemplate.DataName), "CV") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireConvA');
						if (InStr(string(WeaponTemplate.DataName), "MG") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireMagA');
						if (InStr(string(WeaponTemplate.DataName), "BM") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireBeamA');
						break;
					case 'bullpup':
						WeaponTemplate.Abilities.AddItem('FullAutoFire');
						WeaponTemplate.iClipSize += 1;
						if (InStr(string(WeaponTemplate.DataName), "CV") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireConvA');
						if (InStr(string(WeaponTemplate.DataName), "MG") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireMagA');
						if (InStr(string(WeaponTemplate.DataName), "BM") != INDEX_NONE)
							WeaponTemplate.SetAnimationNameForAbility('FullAutoFire', 'FF_AutoFireBeamA');
						break;
					case 'sniper_rifle':
						WeaponTemplate.Abilities.AddItem('Squadsight');
						break;
					case 'shotgun':
						WeaponTemplate.Abilities.AddItem('ShotgunDamageModifierCoverType');
						WeaponTemplate.Abilities.AddItem('ShotgunDamageModifierRange');
						WeaponTemplate.CritChance += default.ShotgunCritBonus;
						WeaponTemplate.Aim += default.ShotgunAimBonus;
						break;
					case 'cannon':
						WeaponTemplate.Abilities.AddItem('FullAutoFire');
						WeaponTemplate.Abilities.AddItem('Suppression');
						WeaponTemplate.Abilities.AddItem('AutoFireShot');
						WeaponTemplate.Abilities.AddItem('AutoFireOverwatch');
						WeaponTemplate.BaseDamage.Damage += default.CannonDamageBonus;
						break;
					case 'pistol':
						WeaponTemplate.Abilities.AddItem('PistolStandardShot');
						break;
					case 'sword':
						WeaponTemplate.Abilities.AddItem('SwordSlice');
						break;
					case 'gremlin':
						WeaponTemplate.Abilities.AddItem('IntrusionProtocol');
						break;
					case 'grenade_launcher':
						WeaponTemplate.Abilities.AddItem('LaunchGrenade');
						break;
					case 'wristblade':
						WeaponTemplate.Abilities.AddItem('SkirmisherGrapple');
						break;
					case 'claymore':
						WeaponTemplate.Abilities.AddItem('ThrowClaymore');
						break;
				}
			}
		}
	}
}

static function PatchThrowClaymore()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('ThrowClaymore');
	Template.bUniqueSource = true;
}


static function PatchSkirmisherGrapple()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SkirmisherGrapple');
	Template.bUniqueSource = true;
}

static function PatchSniperStandardFire()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('SniperStandardFire');
	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).bAddWeaponTypicalCost = false;
}

static function PatchLongWatch()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('LongWatch');
	X2AbilityCost_ActionPoints(Template.AbilityCosts[0]).bAddWeaponTypicalCost = false;
}


static function PatchSuppression()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('Suppression');
	Template.AdditionalAbilities.AddItem('LockdownBonuses');
}


static function PatchSquadSight()
{
	local X2AbilityTemplateManager		TemplateManager;
	local X2AbilityTemplate				Template;
	local X2Effect_Squadsight			Squadsight;
	local X2Condition_UnitActionPoints	ActionPointCondition;
	local X2AbilityTrigger_EventListener EventTrigger;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = TemplateManager.FindAbilityTemplate('Squadsight');

	Template.AbilityTriggers.Length = 0;
	Template.AbilityTargetEffects.Length = 0;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'PlayerTurnBegun';
	EventTrigger.ListenerData.Filter = eFilter_Player;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);

	ActionPointCondition = new class'X2Condition_UnitActionPoints';
	ActionPointCondition.AddActionPointCheck(0, class'X2CharacterTemplateManager'.default.StandardActionPoint, false, eCheck_GreaterThanOrEqual, 2, 0);

	Squadsight = new class'X2Effect_Squadsight';
	Squadsight.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnBegin);
	Squadsight.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Squadsight.TargetConditions.AddItem(ActionPointCondition);
	Template.AddTargetEffect(Squadsight);

	Template.AdditionalAbilities.AddItem('RemoveSquadSightOnMove');
}

/// <summary>
/// Called from XComGameState_Unit:CanAddItemToInventory & UIArmory_Loadout:GetDisabledReason
/// defaults to using the wrapper function below for calls from XCGS_U. Return false with a non-empty string in this function to show the disabled reason in UIArmory_Loadout
/// Note: due to how UIArmory_Loadout does its check, expect only Slot, ItemTemplate, and UnitState to be filled when trying to fill out a disabled reason. Hence the check for CheckGameState == none
/// </summary>
//static function bool CanAddItemToInventory_CH(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason)
//{
//	local X2WeaponTemplate WeaponTemplate;
//	local bool bEvaluate;
//	local array<name> ItemCategories;
//	local name Category;
//
//	If (UnitState.GetSoldierClassTemplateName() != 'UniversalSoldier')
//	{
//		return false;
//	}
//	
//	ItemCategories.AddItem('sniper_rifle');
//	ItemCategories.AddItem('shotgun');
//	ItemCategories.AddItem('cannon');
//	ItemCategories.AddItem('gremlin');
//	ItemCategories.AddItem('grenade_launcher');
//	ItemCategories.AddItem('sword');
//
//	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
//
//	foreach ItemCategories(Category)
//	{
//		if (MissesWeaponProficency(UnitState, WeaponTemplate, Category))
//		{
//			bCanAddItem = 0;
//			// @TODO get localization from ability
//			DisabledReason = "Soldier needs" @ ConvertToCamelCase(String(Category));
//			bEvaluate = true;
//			break;
//		}
//	}
//
//	if (bEvaluate)
//		`LOG(GetFuncName() @ DisabledReason @ bEvaluate,, 'RPG');
//
//	if(CheckGameState == none)
//		return !bEvaluate;
//
//	return bEvaluate;
//}

private static function bool MissesWeaponProficency(XComGameState_Unit UnitState, X2WeaponTemplate WeaponTemplate, name WeaponCategory)
{

	return (WeaponTemplate != none && WeaponTemplate.WeaponCat == WeaponCategory && !UnitState.HasSoldierAbility(GetProficiencyAbilityName(WeaponCategory)));
}

private static function name GetProficiencyAbilityName(name ItemCategory)
{
	return name(ConvertToCamelCase(string(ItemCategory)) $ "Proficiency");
}

private static function string ConvertToCamelCase(string StringToConvert)
{
	local array<string> Pieces;
	local string Token, Result;
	
	Pieces = SplitString(StringToConvert, "_");

	foreach Pieces(Token)
	{
		Result $= Caps(Left(Token, 1)) $ Caps(Right(Token, Len(Token) - 1));
	}

	return Result;
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	local X2WeaponTemplate PrimaryWeaponTemplate, WeaponTemplate;
	local AnimSet AnimSetIter;
	local int i;
	if (!UnitState.IsSoldier() || UnitState.GetSoldierClassTemplateName() == 'Templar')
	{
		return;
	}

	WeaponTemplate = X2WeaponTemplate( UnitState.GetSecondaryWeapon().GetMyTemplate());
	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());

	if (WeaponTemplate.WeaponCat == 'sidearm' &&
		InStr(string(XComWeapon(Pawn.Weapon).ObjectArchetype), "WP_TemplarAutoPistol") != INDEX_NONE)
	{
		for (i = 0; i < Pawn.Mesh.AnimSets.Length; i++)
		{
			if (string(Pawn.Mesh.AnimSets[i]) == "AS_TemplarAutoPistol")
			{
				Pawn.Mesh.AnimSets.Remove(i, 1);
				break;
			}
		}
		AddAnimSet(Pawn, AnimSet(`CONTENT.RequestGameArchetype("AutoPistol_ANIM.Anims.AS_AutoPistol")));

		Pawn.Mesh.UpdateAnimations();
	}

	if (PrimaryWeaponTemplate.WeaponCat == 'rifle' || PrimaryWeaponTemplate.WeaponCat == 'bullpup')
	{
		AddAnimSet(Pawn, AnimSet(`CONTENT.RequestGameArchetype("AutoFire_ANIM.Anims.AS_AssaultRifleAutoFire")));
		Pawn.Mesh.UpdateAnimations();
	}

	
	//foreach Pawn.Mesh.AnimSets(AnimSetIter)
	//{
	//	`LOG(GetFuncName() @ UnitState.GetFullName() @ "current animsets: " @ AnimSetIter,, 'RPG');
	//}
	//`LOG(GetFuncName() @ UnitState.GetFullName() @ "------------------",, 'RPG');
}

static function AddAnimSet(XComUnitPawn Pawn, AnimSet AnimSetToAdd)
{
	if (Pawn.Mesh.AnimSets.Find(AnimSetToAdd) == INDEX_NONE)
	{
		Pawn.Mesh.AnimSets.AddItem(AnimSetToAdd);
		//`LOG(GetFuncName() @ "adding" @ AnimSetToAdd,, 'RPG');
	}
}
