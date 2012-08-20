package ui
{
	import d2api.DataApi;
	import d2api.HighlightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Texture;
	import d2data.Item;
	import d2data.ItemWrapper;
	import d2data.Spell;
	import d2enums.ComponentHookList;
	import d2enums.FightSpellCastCriticalEnum;
	import d2enums.LocationEnum;
	
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
		
		// Conponents
		public var ctn_main:GraphicContainer;
		public var btn_spell:ButtonContainer;
		public var btn_spell_tx:Texture;
		public var tx_criticalHit:Texture;
		public var tx_criticalFailure:Texture;
		
		// Divers
		private var spellData:SpellData;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialize the ui.
		 *
		 * @param	params	(not used)
		 */
		public function main(spellData:SpellData):void
		{
			this.spellData = spellData;
			
			updateSpellTexture(spellData._spellType, spellData._spellId);
			displayCritical(spellData._spellCritical);
			
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_ROLL_OVER);
			
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_ROLL_OUT);
		}
		
		/**
		 * Cleanup function.
		 */
		public function unload():void
		{
		}
		
		public function updateSpellTexture(spellType:int,  spellId:int):void
		{
			if (spellType == SpellData.SPELL_TYPE_SPELL)
			{
				btn_spell_tx.uri = dataApi.getSpellItem(spellId).iconUri;
			}
			else if (spellType == SpellData.SPELL_TYPE_WEAPON)
			{
				btn_spell_tx.uri = uiApi.createUri(uiApi.me().getConstant("weapon") + dataApi.getItem(spellId).typeId);
			}
		}
		
		public function displayCritical(spellCritical:int):void
		{
			if (spellData._spellCritical == FightSpellCastCriticalEnum.CRITICAL_FAIL)
				tx_criticalFailure.visible = true;
			
			if (spellData._spellCritical == FightSpellCastCriticalEnum.CRITICAL_HIT)
				tx_criticalHit.visible = true;
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * 
		 * @param	target
		 */
		public function onRollOver(target:Object):void
		{
			if (target == ctn_main)
			{
				var cacheName:String;
				if (spellData._spellType == SpellData.SPELL_TYPE_SPELL)
				{
					var spell:Object = dataApi.getSpellItem(spellData._spellId, spellData._spellRank);
					cacheName = "spell-id" + spellData._spellId + "-lvl" + spellData._spellRank;
					
					uiApi.showTooltip(spell, target, false, "standard", LocationEnum.POINT_BOTTOMRIGHT, LocationEnum.POINT_TOPRIGHT, 3, null, null, null, cacheName);
				}
				else if (spellData._spellType == SpellData.SPELL_TYPE_WEAPON)
				{
					var weapon:ItemWrapper = dataApi.getItemWrapper(spellData._spellId);
					cacheName = "weapon-id" + spellData._spellId;
					
					uiApi.showTooltip(weapon, target, false, "standard", LocationEnum.POINT_BOTTOMRIGHT, LocationEnum.POINT_TOPRIGHT, 3, null, null, null, cacheName);
				}
			}
		}
		
		/**
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
		
		//::////////////////////////////////////////////////////////////////////
		//::// Debug
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Wrapper for sysApi.log(2, ...).
		 *
		 * @param	object	The current object to display in the console.
		 */
		public function traceDofus(object:*):void
		{
			sysApi.log(2, object);
		}
	}
}
