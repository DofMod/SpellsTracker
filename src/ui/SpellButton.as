package ui
{
	import d2api.DataApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Texture;
	import d2data.Spell;
	import d2enums.ComponentHookList;
	
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
		 * getSpellItem
		 */
		public var dataApi:DataApi;
		
		// Conponents
		public var ctn_main:GraphicContainer;
		public var btn_spell:ButtonContainer;
		public var btn_spell_tx:Texture;
		
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
			
			var spellItem:Object = dataApi.getSpellItem(spellData._spellId);
			btn_spell_tx.uri = uiApi.createUri(spellItem.iconUri);
			
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_ROLL_OVER);
			
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_ROLL_OUT);
		}
		
		/**
		 * Cleanup function.
		 */
		public function unload():void
		{
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
				var spell:Spell = dataApi.getSpell(spellData._spellId);
				
				uiApi.showTooltip(spell.description, target);
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
