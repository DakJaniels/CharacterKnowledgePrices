-- Luacheck for Character Knowledge Prices (ESO Lua 5.1).
-- Run from this folder: luacheck .

std = "lua51"
max_line_length = 200

read_globals = {
	-- Addon libraries and hosts
	"LibCodesCommonCode",
	"LibCharacterKnowledge",
	"LibPrice",
	"CharacterKnowledge",

	-- Strings registered by l10n
	"SI_CKP_TITLE",
	"SI_CKP_SETTING_SHOW",
	"SI_CKP_SETTING_SHOW_TOOLTIP",

	-- ESO client
	"EVENT_MANAGER",
	"EVENT_ADD_ON_LOADED",
	"GetString",
	"CURT_MONEY",
	"ZO_SavedVars",
	"ZO_AbbreviateAndLocalizeNumber",
	"ZO_Currency_GetKeyboardFormattedCurrencyIcon",
	"NUMBER_ABBREVIATION_PRECISION_TENTHS",
	"zo_round",
}

globals = {
	"CharacterKnowledgePrices",
}

-- Callbacks keep the caller's arguments.
ignore = {
	"212",
}
