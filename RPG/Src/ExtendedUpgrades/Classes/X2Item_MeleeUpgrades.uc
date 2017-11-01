class X2Item_MeleeUpgrades extends X2Item config (ExtendedUpgrades);

var config array<name> MeleeWeaponCategories;
var config array<name> MutuallyExclusiveUpgradesCategory1;

var config int MELEE_CRIT_UPGRADE_BSC;
var config int MELEE_CRIT_UPGRADE_ADV;
var config int MELEE_CRIT_UPGRADE_SUP;

var config int MELEE_AIM_UPGRADE_BSC;
var config int MELEE_AIM_UPGRADE_ADV;
var config int MELEE_AIM_UPGRADE_SUP;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreateBasicMeleeCritUpgrade());
	Items.AddItem(CreateAdvancedMeleeCritUpgrade());
	Items.AddItem(CreateSuperiorMeleeCritUpgrade());
	
	Items.AddItem(CreateBasicMeleeAimUpgrade());
	Items.AddItem(CreateAdvancedMeleeAimUpgrade());
	Items.AddItem(CreateSuperiorMeleeAimUpgrade());

	return Items;
}


// #######################################################################################
// -------------------- CRIT UPGRADES ----------------------------------------------------
// #######################################################################################

static function X2DataTemplate CreateBasicMeleeCritUpgrade()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'MeleeCritUpgrade_Bsc');

	class'X2Item_DefaultUpgrades'.static.SetUpTier1Upgrade(Template);
	SetUpCritUpgrade(Template);
	
	//Template.BonusAbilities.AddItem('LaserSight_Bsc');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Sch_Elerium_Dust";
	Template.CritBonus = default.MELEE_CRIT_UPGRADE_BSC;
	
	return Template;
}

static function X2DataTemplate CreateAdvancedMeleeCritUpgrade()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'MeleeCritUpgrade_Adv');

	class'X2Item_DefaultUpgrades'.static.SetUpTier2Upgrade(Template);
	SetUpCritUpgrade(Template);
	
	//Template.BonusAbilities.AddItem('LaserSight_Adv');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Sch_Elerium_Dust";
	Template.CritBonus = default.MELEE_CRIT_UPGRADE_ADV;

	return Template;
}

static function X2DataTemplate CreateSuperiorMeleeCritUpgrade()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'MeleeCritUpgrade_Sup');

	class'X2Item_DefaultUpgrades'.static.SetUpTier3Upgrade(Template);
	SetUpCritUpgrade(Template);
	

	//Template.BonusAbilities.AddItem('LaserSight_Sup');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Sch_Elerium_Dust";
	Template.CritBonus = default.MELEE_CRIT_UPGRADE_SUP;
	
	return Template;
}

static function SetUpCritUpgrade(out X2WeaponUpgradeTemplate Template)
{
	local name MutuallyExclusiveUpgrade;
	
	SetUpMeleeWeaponUpgrade(Template);

	Template.AddCritChanceModifierFn = CritUpgradeModifier;
	Template.GetBonusAmountFn = GetCritBonusAmount;

	foreach default.MutuallyExclusiveUpgradesCategory1(MutuallyExclusiveUpgrade)
	{
		Template.MutuallyExclusiveUpgrades.AddItem(MutuallyExclusiveUpgrade);
	}
}

// #######################################################################################
// --------------------- AIM UPGRADES ----------------------------------------------------
// #######################################################################################

static function X2DataTemplate CreateBasicMeleeAimUpgrade()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'MeleeAimUpgrade_Bsc');

	class'X2Item_DefaultUpgrades'.static.SetUpTier1Upgrade(Template);
	SetUpAimBonusUpgrade(Template);
	
	Template.strImage = "UIlibrary_strategyimages.X2InventoryIcons.Inv_Elerium_Crystals";
	Template.AimBonus = default.MELEE_AIM_UPGRADE_BSC;
	
	return Template;
}

static function X2DataTemplate CreateAdvancedMeleeAimUpgrade()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'MeleeAimUpgrade_Adv');

	class'X2Item_DefaultUpgrades'.static.SetUpTier2Upgrade(Template);
	SetUpAimBonusUpgrade(Template);

	Template.strImage = "UIlibrary_strategyimages.X2InventoryIcons.Inv_Elerium_Crystals";
	Template.AimBonus = default.MELEE_AIM_UPGRADE_ADV;
	
	return Template;
}

static function X2DataTemplate CreateSuperiorMeleeAimUpgrade()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'MeleeAimUpgrade_Sup');

	class'X2Item_DefaultUpgrades'.static.SetUpTier3Upgrade(Template);
	SetUpAimBonusUpgrade(Template);

	Template.strImage = "UIlibrary_strategyimages.X2InventoryIcons.Inv_Elerium_Crystals";
	Template.AimBonus = default.MELEE_AIM_UPGRADE_SUP;
	
	return Template;
}

static function SetUpAimBonusUpgrade(out X2WeaponUpgradeTemplate Template)
{
	local name MutuallyExclusiveUpgrade;

	SetUpMeleeWeaponUpgrade(Template);

	Template.AddHitChanceModifierFn = AimUpgradeHitModifier;
	Template.GetBonusAmountFn = GetAimBonusAmount;

	foreach default.MutuallyExclusiveUpgradesCategory1(MutuallyExclusiveUpgrade)
	{
		Template.MutuallyExclusiveUpgrades.AddItem(MutuallyExclusiveUpgrade);
	}
}


// #######################################################################################
// --------------------- Generic Functions------------------------------------------------
// #######################################################################################

static function SetUpMeleeWeaponUpgrade(out X2WeaponUpgradeTemplate Template)
{
	Template.CanApplyUpgradeToWeaponFn = CanApplyMeleeUpgradeToWeapon;
	
	Template.CanBeBuilt = false;
	Template.MaxQuantity = 1;

	Template.BlackMarketTexts = class'X2Item_DefaultUpgrades'.default.UpgradeBlackMarketTexts;
}


static function bool CanApplyMeleeUpgradeToWeapon(X2WeaponUpgradeTemplate UpgradeTemplate, XComGameState_Item Weapon, int SlotIndex)
{
	local array<X2WeaponUpgradeTemplate> AttachedUpgradeTemplates;
	local X2WeaponUpgradeTemplate AttachedUpgrade; 
	local int iSlot;
		
	AttachedUpgradeTemplates = Weapon.GetMyWeaponUpgradeTemplates();

	foreach AttachedUpgradeTemplates(AttachedUpgrade, iSlot)
	{
		// Slot Index indicates the upgrade slot the player intends to replace with this new upgrade
		if (iSlot == SlotIndex)
		{
			// The exact upgrade already equipped in a slot cannot be equipped again
			// This allows different versions of the same upgrade type to be swapped into the slot
			if (AttachedUpgrade == UpgradeTemplate)
			{
				return false;
			}
		}
		else if (UpgradeTemplate.MutuallyExclusiveUpgrades.Find(AttachedUpgrade.Name) != INDEX_NONE)
		{
			// If the new upgrade is mutually exclusive with any of the other currently equipped upgrades, it is not allowed
			return false;
		}
	}

	if (default.MeleeWeaponCategories.Find(X2WeaponTemplate(Weapon.GetMyTemplate()).WeaponCat) == INDEX_NONE)
	{
		return false;
	}

	return true;
}

static function int GetCritBonusAmount(X2WeaponUpgradeTemplate UpgradeTemplate)
{
	return UpgradeTemplate.CritBonus;
}


static function bool CritUpgradeModifier(X2WeaponUpgradeTemplate UpgradeTemplate, out int CritChanceMod)
{
	CritChanceMod = UpgradeTemplate.CritBonus;
	return true;
}

static function int GetAimBonusAmount(X2WeaponUpgradeTemplate UpgradeTemplate)
{
	return UpgradeTemplate.AimBonus;
}

static function bool AimUpgradeHitModifier(X2WeaponUpgradeTemplate UpgradeTemplate, const GameRulesCache_VisibilityInfo VisInfo, out int HitChanceMod)
{
	HitChanceMod = UpgradeTemplate.AimBonus;
	return true;
}
