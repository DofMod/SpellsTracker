package ui
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.ComboBox;
	import d2enums.ComponentHookList;
	
	/**
	 * The config UI of the module.
	 *
	 * @author Relena
	 */
	public class SpellsTrackerConfig
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// APIs
		/**
		 * @private
		 *
		 * log, getData
		 */
		public var sysApi:SystemApi;
		/**
		 * @private
		 *
		 * addComponentHook
		 */
		public var uiApi:UiApi;
		
		// Components
		public var cb_maxDisplayedTurn:ComboBox;
		public var btn_mp:ButtonContainer;
		public var btn_move:ButtonContainer;
		
		[Module(name="SpellsTracker")]
		/**
		 * Module SpellsTracker reference.
		 *
		 * @private
		 */
		public var modSpellsTracker:Object;
		
		// Others
		private const maxDisplayedTurn:Array = new Array("1", "2", "3", "4", "5", "6", "7", "8", "9", "10");
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialize the ui.
		 *
		 * @param	params	(not used)
		 */
		public function main(params:Object):void
		{
			uiApi.addComponentHook(btn_mp, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_move, ComponentHookList.ON_RELEASE);
			
			btn_mp.selected = sysApi.getData(btn_mp.name);
			btn_move.selected = sysApi.getData(btn_move.name);
			
			cb_maxDisplayedTurn.dataProvider = maxDisplayedTurn;
			if (sysApi.getData(cb_maxDisplayedTurn.name) != undefined)
				cb_maxDisplayedTurn.value = maxDisplayedTurn[sysApi.getData(cb_maxDisplayedTurn.name) - 1];
			else
				cb_maxDisplayedTurn.value = maxDisplayedTurn[2];
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
		 * ...
		 *
		 * @param	target
		 */
		public function onRelease(target:ButtonContainer):void
		{
			sysApi.setData(target.name, target.selected);
		}
		
		/**
		 * ...
		 *
		 * @param	target
		 * @param	arg2
		 * @param	arg3
		 */
		public function onSelectItem(target:Object, arg2:uint, arg3:Boolean):void
		{
			if (target == cb_maxDisplayedTurn)
			{
				sysApi.setData(cb_maxDisplayedTurn.name, parseInt(maxDisplayedTurn[cb_maxDisplayedTurn.selectedIndex]));
				
				modSpellsTracker.reloadConfig();
			}
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Debug
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Wrapper for sysApi.log(2, ...).
		 *
		 * @param	object	An object to display in the console.
		 */
		public function traceDofus(object:*):void
		{
			sysApi.log(2, object);
		}
	}
}
