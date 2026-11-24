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
	"CharacterKnowledgeList",

	-- Strings registered by l10n
	"SI_CKP_TITLE",
	"SI_CKP_HEADER_PRICE",
	"SI_CKP_SETTING_SHOW",
	"SI_CKP_SETTING_SHOW_TOOLTIP",

	-- ESO client
	"EVENT_MANAGER",
	"EVENT_ADD_ON_LOADED",
	"WINDOW_MANAGER",
	"GetString",
	"CreateControlFromVirtual",
	"CT_LABEL",
	"TOPLEFT",
	"TOPRIGHT",
	"LEFT",
	"RIGHT",
	"TEXT_ALIGN_RIGHT",
	"TEXT_ALIGN_CENTER",
	"TEXT_WRAP_MODE_ELLIPSIS",
	"CURT_MONEY",
	"ZO_CURRENCY_FORMAT_AMOUNT_ICON",
	"ZO_SORT_ORDER_UP",
	"ZO_DEFAULT_TEXT",
	"ZO_PostHook",
	"ZO_SavedVars",
	"ZO_SortHeader_Initialize",
	"ZO_TableOrderingFunction",
	"ZO_Currency_FormatKeyboard",
	"zo_round",
}

globals = {
	"CharacterKnowledgePrices",
}

-- Posthook callbacks keep the hooked function's arguments.
ignore = {
	"212",
}
