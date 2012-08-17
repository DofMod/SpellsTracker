package ui
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Label;
	import d2components.Texture;
	import d2enums.ComponentHookList;
	
	/**
	 * The main conainer UI of the module. Display and track several spell's
	 * button UI.
	 *
	 * @author Relena
	 */
	public class SpellButtonContainer
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
		 * addComponentHook, loadUiInside, unloadUi
		 */
		public var uiApi:UiApi;
		
		// Conponents
		public var btn_minimize:ButtonContainer;
		public var ctr_concealable:GraphicContainer;
		public var tx_background:Texture;
		public var lbl_turn:Label;
		public var btn_previousTurn:ButtonContainer;
		public var btn_nextTurn:ButtonContainer;
		
		[Module(name="SpellsTracker")]
		/**
		 * @private
		 *
		 * SpellsTracker module reference.
		 */
		public var modSpellsTraker:Object;
		
		// Divers		
		private var spellButtonList:Array = new Array();
		
		private var uniqueId:int = 0;
		
		private const spellButtonUIName:String = "SpellButton";
		private const spellButtonWidth:int = 42;
		private const spellButtonHeight:int = 42;
		private const spaceBetweenSpellButton:int = 10;
		
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
			uiApi.addComponentHook(btn_minimize, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_previousTurn, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_nextTurn, ComponentHookList.ON_RELEASE);
		}
		
		/**
		 * Cleanup function.
		 */
		public function unload():void
		{
			unloadSpellButtons();
		}
		
		/**
		 * Create an unique instance name.
		 *
		 * @return	An unique instance name.
		 */
		private function createInstanceName():String
		{
			return "SpellButton_" + getUniqueId();
		}
		
		/**
		 * Get an unique identifier.
		 *
		 * @return An unique identifier.
		 */
		private function getUniqueId():int
		{
			return uniqueId++;
		}
		
		/**
		 * Unload all the spell's buttons.
		 */
		private function unloadSpellButtons():void
		{
			tx_background.width = 60;
			tx_background.x = 0;
			
			for each (var instanceName:String in spellButtonList)
			{
				uiApi.unloadUi(instanceName);
			}
			
			spellButtonList = new Array();
		}
		
		/**
		 * Add the spell's button instance name to the instance name list.
		 *
		 * @param	instanceName	Instance name to tack.
		 */
		private function trackSpellButtonName(instanceName:String):void
		{
			spellButtonList.push(instanceName);
		}
		
		/**
		 * Update the whole button's list.
		 *
		 * @param	spellList	Spell's list to display.
		 * @param	turn	Turn's number to display.
		 */
		public function updateSpellButtons(spellList:Array, turn:int):void
		{
			unloadSpellButtons();
			
			displayTurn(turn);
			
			for each (var spellData:SpellData in spellList)
			{
				addSpellButton(spellData);
			}
		}
		
		/**
		 * Display a new spell's button in the button's list.
		 *
		 * @param	spellData	Spell's data to display.
		 */
		public function addSpellButton(spellData:SpellData):void
		{
			var instanceName:String = createInstanceName();
			
			var newUi:Object;
			newUi = uiApi.loadUiInside(spellButtonUIName, ctr_concealable, instanceName, spellData);
			
			tx_background.width += spellButtonWidth + spaceBetweenSpellButton;
			tx_background.x -= spellButtonWidth + spaceBetweenSpellButton;
			
			newUi.x = tx_background.x + 10;
			newUi.y = 10;
			
			trackSpellButtonName(instanceName);
		}
		
		/**
		 * Display the turn <code>turn</code>.
		 *
		 * @param	turn	Turn number to display.
		 */
		private function displayTurn(turn:int):void
		{
			lbl_turn.text = turn.toString();
		}
		
		/**
		 * Get the current turn displayed.
		 *
		 * @return	The current turn displayed.
		 */
		private function getTurn():int
		{
			return parseInt(lbl_turn.text);
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * This callback is process when the button conmponent is released.
		 * Actualy we can show/hide the button's list, or request the displaying
		 * of the next or previous spell's list.
		 *
		 * @private
		 *
		 * @param	target	Button compoment released.
		 */
		public function onRelease(target:Object):void
		{
			if (target == btn_minimize)
			{
				ctr_concealable.visible = (!btn_minimize.selected);
			}
			else if (target == btn_nextTurn)
			{
				modSpellsTraker.requestUpdateSpells(getTurn() + 1);
			}
			else if (target == btn_previousTurn)
			{
				modSpellsTraker.requestUpdateSpells(getTurn() - 1);
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
