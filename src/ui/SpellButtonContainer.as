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
		
		// Default values
		private var spellButtonWidth:int;
		private var spellButtonHeight:int;
		private var spellButtonX:int;
		private var spellButtonY:int;
		private var spaceBetweenSpellButton:int;
		private var backgroundWidth:int;
		private var backgroundHeight:int;
		private var backgroundX:int;
		private var backgroundY:int;
		
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
			spellButtonWidth = uiApi.me().getConstant("spellButtonWidth");
			spellButtonHeight = uiApi.me().getConstant("spellButtonHeight");
			spellButtonX = uiApi.me().getConstant("spellButtonX");
			spellButtonY = uiApi.me().getConstant("spellButtonY");
			spaceBetweenSpellButton = uiApi.me().getConstant("spaceBetweenSpellButton");
			backgroundWidth = uiApi.me().getConstant("backgroundWidth");
			backgroundHeight = uiApi.me().getConstant("backgroundHeight");
			backgroundX = uiApi.me().getConstant("backgroundX");
			backgroundY = uiApi.me().getConstant("backgroundY");
			
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
			for each (var list:Array in spellButtonList)
			{
				for each (var instanceName:String in list)
				{
					uiApi.unloadUi(instanceName);
				}
			}
			
			spellButtonList = new Array();
		}
		
		/**
		 * Add the spell's button instance name to the instance name list.
		 *
		 * @param	instanceName	Instance name to tack.
		 */
		private function trackSpellButton(line:int, instanceName:String):void
		{
			if (spellButtonList[line] == undefined)
				spellButtonList[line] = new Array();
			
			spellButtonList[line].push(instanceName);
		}
		
		/**
		 * Get the number of spell buttons of the longest line.
		 *
		 * @return The number of spell buttons.
		 */
		private function getNbSpellButtonsMax():int
		{
			var max:int = 0;
			
			for each (var list:Array in spellButtonList)
				if (list.length > max)
					max = list.length;
			
			return max;
		}
		
		/**
		 * Get the number of spell buttons of the line <code>line</code>.
		 *
		 * @return The number of spell buttons.
		 */
		private function getNbSpellButtons(line:int):int
		{
			if (spellButtonList[line] == undefined)
				return 0;
			
			return spellButtonList[line].length;
		}
		
		/**
		 * Update the whole button's list.
		 *
		 * @param	spellList	Spell's list to display.
		 * @param	turn	Turn's number to display.
		 */
		public function updateSpellButtons(spellList:Array, spellListSize:int, turn:int):void
		{
			unloadSpellButtons();

			actualizeAssets(0, spellListSize);
			
			displayTurn(turn);
			
			for (var ii:int = 0; ii < spellListSize; ii++)
			{
				for each (var spellData:SpellData in spellList[ii])
				{
					addSpellButton(ii, spellData);
				}
			}
		}
		
		/**
		 * Display a new spell's button in the button's list.
		 *
		 * @param	spellData	Spell's data to display.
		 */
		public function addSpellButton(line:int, spellData:SpellData):void
		{
			var instanceName:String = createInstanceName();
			
			var spellButton:Object = uiApi.loadUiInside(spellButtonUIName, ctr_concealable, instanceName, spellData);
			
			trackSpellButton(line, instanceName);
			
			actualizeAssets(getNbSpellButtonsMax());
			actualizeSpellButton(spellButton, getNbSpellButtons(line) - 1, line);
		}
		
		/**
		 * ...
		 * 
		 * @param	nbButtons
		 * @param	nbLines
		 */
		public function actualizeAssets(nbButtons:int = -1, nbLines:int = -1):void
		{
			if (nbLines != -1)
			{
				var height:int = backgroundHeight * (nbLines - 1);
				tx_background.height = backgroundHeight + height;
				tx_background.y = backgroundY - height;
			}
			
			if (nbButtons != -1)
			{
				var width:int = spaceBetweenSpellButton * nbButtons;
				tx_background.width = backgroundWidth + width;
				tx_background.x = backgroundX - width;
			}
		}
		
		/**
		 * ...
		 * 
		 * @param	spellButton
		 */
		private function actualizeSpellButton(spellButton:Object, collumn:int, line:int):void
		{
			spellButton.x = spellButtonX - (collumn * spaceBetweenSpellButton);
			spellButton.y = spellButtonY - (line * backgroundHeight);
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
