package ui
{
	import d2api.DataApi;
	import d2api.HighlightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Label;
	import d2components.Texture;
	import d2data.Item;
	import d2data.ItemWrapper;
	import d2data.Spell;
	import d2enums.ComponentHookList;
	import d2enums.FightSpellCastCriticalEnum;
	import d2enums.LocationEnum;
	import managers.interfaces.SpellWindowManager;
	import types.CountdownData;
	import types.SpellButtonParams;
	import types.SpellData;
	
	/**
	 * Spell's button UI.
	 *
	 * @author Relena
	 */
	public class SpellButton
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// APIs
		/**
		 * @private
		 *
		 * ?
		 */
		public var hlApi:HighlightApi;
		/**
		 * @private
		 *
		 * log
		 */
		public var sysApi:SystemApi;
		/**
		 * @private
		 *
		 * createUri
		 */
		public var uiApi:UiApi;
		/**
		 * @private
		 *
		 * getSpellItem, getItemWrapper
		 */
		public var dataApi:DataApi;
		
		// Dependencies
		private var _spellWindowManager:SpellWindowManager;
		
		// Conponents
		public var ctn_main:GraphicContainer;
		public var btn_spell:ButtonContainer;
		public var btn_spell_tx:Texture;
		public var tx_criticalHit:Texture;
		public var tx_criticalFailure:Texture;
		public var lbl_spellAreaLink:Label;
		
		// Divers
		private var _spellData:SpellData;
		private var _countdownData:CountdownData;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialise function, automatically call bye the core.
		 *
		 * @param	spellData	Spell data.
		 */
		public function main(spellButtonParams:SpellButtonParams):void
		{
			_spellWindowManager = spellButtonParams.spellWindowManager;
			_spellData = spellButtonParams.spellData;
			
			_countdownData = new CountdownData();
			_countdownData._fighterId = _spellData._fighterId;
			_countdownData._spellId = _spellData._spellId;
			_countdownData._start = _spellData._turn;
			_countdownData._countdown = (dataApi.getSpellWrapper(_spellData._spellId, _spellData._spellRank) as Object).minCastInterval;
			_countdownData._description = "";
			
			updateSpellTexture(_spellData._spellType, _spellData._spellId);
			displayCritical(_spellData._spellCritical);
			
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_RELEASE);
			
			lbl_spellAreaLink.text = "<a href='event:spellEffectArea," + _spellData._fighterId + "," + _spellData._cellId + "," + _spellData._sourceCellId + "," + _spellData._spellId + "," + _spellData._spellRank + "'><b>+</b></a>";
		}
		
		/**
		 * Cleanup function.
		 */
		public function unload():void
		{
			uiApi.hideTooltip();
		}
		
		/**
		 * Display the write spell asset.
		 *
		 * @param	spellType
		 * @param	spellId
		 */
		private function updateSpellTexture(spellType:int, spellId:int):void
		{
			if (spellType == SpellData.SPELL_TYPE_SPELL)
			{
				btn_spell_tx.uri = dataApi.getSpellWrapper(spellId).iconUri;
			}
			else if (spellType == SpellData.SPELL_TYPE_WEAPON)
			{
				btn_spell_tx.uri = uiApi.createUri(uiApi.me().getConstant("weapon") + dataApi.getItem(spellId).typeId);
			}
		}
		
		/**
		 * Display the criticals assets.
		 *
		 * @param	spellCritical
		 */
		private function displayCritical(spellCritical:int):void
		{
			if (_spellData._spellCritical == FightSpellCastCriticalEnum.CRITICAL_FAIL)
				tx_criticalFailure.visible = true;
			
			if (_spellData._spellCritical == FightSpellCastCriticalEnum.CRITICAL_HIT)
				tx_criticalHit.visible = true;
		}
		
		/**
		 * Display a tooltip.
		 *
		 * @param	target
		 */
		private function showTooltip(target:Object):void
		{
			var cacheName:String;
			if (_spellData._spellType == SpellData.SPELL_TYPE_SPELL)
			{
				var spell:Object = dataApi.getSpellWrapper(_spellData._spellId, _spellData._spellRank);
				cacheName = "spell-id" + _spellData._spellId + "-lvl" + _spellData._spellRank;
				
				uiApi.showTooltip(spell, target, false, "standard", LocationEnum.POINT_BOTTOMRIGHT, LocationEnum.POINT_TOPRIGHT, 3, null, null, null, cacheName);
			}
			else if (_spellData._spellType == SpellData.SPELL_TYPE_WEAPON)
			{
				var weapon:ItemWrapper = dataApi.getItemWrapper(_spellData._spellId);
				cacheName = "weapon-id" + _spellData._spellId;
				
				uiApi.showTooltip(weapon, target, false, "standard", LocationEnum.POINT_BOTTOMRIGHT, LocationEnum.POINT_TOPRIGHT, 3, null, null, null, cacheName);
			}
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Display a tooltip.
		 *
		 * @private
		 *
		 * @param	target
		 */
		public function onRollOver(target:Object):void
		{
			if (target == ctn_main)
			{
				showTooltip(target);
			}
		}
		
		/**
		 * Hide ths tooltips.
		 *
		 * @private
		 *
		 * @param	target
		 */
		public function onRollOut(target:Object):void
		{
			if (target == ctn_main)
			{
				uiApi.hideTooltip();
			}
		}
		
		/**
		 * Request the creation of a new spell window.
		 *
		 * @private
		 *
		 * @param	target
		 */
		public function onRelease(target:Object):void
		{
			if (target == ctn_main)
			{
				_spellWindowManager.createUi(_countdownData);
			}
		}
	}
}
