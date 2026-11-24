local LCCC = LibCodesCommonCode
local LCK = LibCharacterKnowledge

local ADDON_NAME = "CharacterKnowledgePrices"
local PRICE_SCAN_NAME = ADDON_NAME .. "Scan"
local PRICE_SORT_KEY = "priceGold"
local NAME_WIDTH_WITH_PRICE = 260
local NAME_WIDTH_WITHOUT_PRICE = 380
local QUALITY_WIDTH_WITH_PRICE = 90
local QUALITY_WIDTH_WITHOUT_PRICE = 210
local PRICE_COLUMN_WIDTH = 96

CharacterKnowledgePrices =
{
	name = ADDON_NAME,
	defaults =
	{
		showPriceColumn = false,
	},
}

local CharacterKnowledgePrices = CharacterKnowledgePrices

local PRICE_SORT_KEYS =
{
	[PRICE_SORT_KEY] = { isNumeric = true, tiebreaker = "name" },
	["name"] = { caseInsensitive = true },
}

local function IsPriceColumnShown()
	local savedVars = CharacterKnowledgePrices.vars
	return savedVars ~= nil and savedVars.showPriceColumn
end

local function GetPriceGold(itemLink)
	local goldPrices = LibPrice.ItemLinkToBidAskSpread(itemLink)[LibPrice.CURRENCY_TYPE_GOLD]
	local price = goldPrices and (goldPrices[LibPrice.PRICE_SALE] or goldPrices[LibPrice.PRICE_AVG] or goldPrices[LibPrice.PRICE_ASK] or goldPrices[LibPrice.PRICE_BID])
	if (price) then
		return price.value
	end
	return -1
end

local function ApplyPriceColumnLayout(list)
	local showPriceColumn = IsPriceColumnShown()
	list.headers:GetNamedChild("Quality"):SetWidth(showPriceColumn and QUALITY_WIDTH_WITH_PRICE or QUALITY_WIDTH_WITHOUT_PRICE)
	local priceHeader = list.characterKnowledgePricesHeader
	priceHeader:SetHidden(not showPriceColumn)
	priceHeader:SetWidth(showPriceColumn and PRICE_COLUMN_WIDTH or 0)
	if (not showPriceColumn and list.currentSortKey == PRICE_SORT_KEY) then
		list.currentSortKey = "extended"
		list.currentSortOrder = ZO_SORT_ORDER_UP
		list.sortHeaderGroup:SelectAndResetSortForKey("extended")
	end
end

local function StopPriceScan(list)
	EVENT_MANAGER:UnregisterForUpdate(PRICE_SCAN_NAME)
	list.characterKnowledgePricesScanning = false
end

function CharacterKnowledgePrices.RefreshPriceColumn(list)
	if (not IsPriceColumnShown() or list.characterKnowledgePricesValid or list.characterKnowledgePricesScanning or #list.masterList == 0) then
		return
	end

	for _, data in ipairs(list.masterList) do
		data.priceGold = -1
	end
	list.characterKnowledgePricesScanning = true

	local startIndex = 1
	local blockSize = 200
	EVENT_MANAGER:RegisterForUpdate(PRICE_SCAN_NAME, 0, function ()
		local stopIndex = startIndex + blockSize
		for index = startIndex, stopIndex - 1 do
			local data = list.masterList[index]
			data.priceGold = GetPriceGold(LCK.GetItemLinkFromItemId(data.itemId))
			if (index >= #list.masterList) then
				StopPriceScan(list)
				list.characterKnowledgePricesValid = true
				if (not list.researchModeIsSelected) then
					list:RefreshFilters()
				end
				return
			end
		end
		startIndex = stopIndex
	end)
end

function CharacterKnowledgePrices.OnListSetup(list)
	if (list.characterKnowledgePricesAttached) then
		return
	end
	list.characterKnowledgePricesAttached = true

	local priceHeader = CreateControlFromVirtual(list.headers:GetName() .. "Price", list.headers, "ZO_SortHeader")
	priceHeader:SetAnchor(TOPLEFT, list.headers:GetNamedChild("Characters"), TOPRIGHT, 0, 0)
	priceHeader:SetDimensions(PRICE_COLUMN_WIDTH, 32)
	ZO_SortHeader_Initialize(priceHeader, GetString(SI_CKP_HEADER_PRICE), PRICE_SORT_KEY, ZO_SORT_ORDER_UP, TEXT_ALIGN_RIGHT, "ZoFontGameLargeBold")
	list.sortHeaderGroup:AddHeader(priceHeader)
	list.characterKnowledgePricesHeader = priceHeader

	local originalSortFunction = list.sortFunction
	list.sortFunction = function (listEntry1, listEntry2)
		if (list.currentSortKey == PRICE_SORT_KEY) then
			return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, PRICE_SORT_KEY, PRICE_SORT_KEYS, list.currentSortOrder)
		end
		return originalSortFunction(listEntry1, listEntry2)
	end

	ApplyPriceColumnLayout(list)
end

function CharacterKnowledgePrices.OnSettingChanged(showPriceColumn)
	CharacterKnowledgePrices.vars.showPriceColumn = showPriceColumn
	if (showPriceColumn) then
		return
	end

	local list = CharacterKnowledge.list
	if (not list or not list.characterKnowledgePricesAttached) then
		return
	end
	StopPriceScan(list)
	ApplyPriceColumnLayout(list)
	list:RefreshFilters()
end

local function OnAddOnLoaded(eventCode, addonName)
	if (addonName ~= ADDON_NAME) then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

	CharacterKnowledgePrices.vars = ZO_SavedVars:NewAccountWide("CharacterKnowledgePricesSavedVariables", 1, nil, CharacterKnowledgePrices.defaults)

	if (IsPriceColumnShown()) then
		CharacterKnowledgePrices.RegisterPriceColumn()
	end

	local LAM = LCCC.GetLibAddonMenu()
	if (LAM) then
		local panelId = "CharacterKnowledgePricesSettings"
		LAM:RegisterAddonPanel(panelId,
													 {
														 type = "panel",
														 name = GetString(SI_CKP_TITLE),
														 version = "1.0.0",
														 author = "@dack_janiels",
														 registerForRefresh = true,
													 })
		LAM:RegisterOptionControls(panelId,
															 {
																 {
																	 type = "checkbox",
																	 name = SI_CKP_SETTING_SHOW,
																	 tooltip = SI_CKP_SETTING_SHOW_TOOLTIP,
																	 getFunc = function () return CharacterKnowledgePrices.vars.showPriceColumn end,
																	 setFunc = CharacterKnowledgePrices.OnSettingChanged,
																	 requiresReload = true,
																	 default = CharacterKnowledgePrices.defaults.showPriceColumn
																 },
															 })
	end
end

function CharacterKnowledgePrices.RegisterPriceColumn()
	if (CharacterKnowledgePrices.priceColumnRegistered) then
		return
	end
	CharacterKnowledgePrices.priceColumnRegistered = true

	ZO_PostHook(CharacterKnowledgeList, "Setup", function (list)
		CharacterKnowledgePrices.OnListSetup(list)
	end)

	ZO_PostHook(CharacterKnowledgeList, "BuildMasterList", function (list)
		StopPriceScan(list)
		list.characterKnowledgePricesValid = false
		CharacterKnowledgePrices.RefreshPriceColumn(list)
	end)

	ZO_PostHook(CharacterKnowledgeList, "SetupItemRow", function (list, control, data)
		local showPriceColumn = IsPriceColumnShown()
		control:GetNamedChild("Name"):SetWidth(showPriceColumn and NAME_WIDTH_WITH_PRICE or NAME_WIDTH_WITHOUT_PRICE)

		local priceCell = control:GetNamedChild("Price")
		if (not priceCell) then
			priceCell = WINDOW_MANAGER:CreateControl(control:GetName() .. "Price", control, CT_LABEL)
			priceCell:SetFont("ZoFontGame")
			priceCell:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			priceCell:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			priceCell:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			priceCell:SetAnchor(LEFT, control:GetNamedChild("Characters"), RIGHT, 0, 0)
			priceCell:SetDimensions(PRICE_COLUMN_WIDTH, 30)
		end

		priceCell:SetHidden(not showPriceColumn)
		priceCell:SetWidth(showPriceColumn and PRICE_COLUMN_WIDTH or 0)
		priceCell:SetColor(ZO_DEFAULT_TEXT:UnpackRGBA())
		if (showPriceColumn and data.priceGold and data.priceGold > 0) then
			priceCell:SetText(ZO_Currency_FormatKeyboard(CURT_MONEY, zo_round(data.priceGold), ZO_CURRENCY_FORMAT_AMOUNT_ICON))
		else
			priceCell:SetText("")
		end
	end)

	local list = CharacterKnowledge.list
	if (list) then
		CharacterKnowledgePrices.OnListSetup(list)
		CharacterKnowledgePrices.RefreshPriceColumn(list)
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)