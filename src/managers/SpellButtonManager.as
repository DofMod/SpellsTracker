package managers
{	
	import d2components.Texture;
	import d2hooks.UiLoaded;
	import types.SpellData;
	import ui.SpellButtonContainer;
	/**
	 * Manager for the main fight UI.
	 *
	 * @author Relena
	 */
	public class SpellButtonManager
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Statics
		private static var _instance:SpellButtonManager;
		
		// Constants
		private const _uiContainerName:String = "SpellButtonContainer";
		private const _uiContainerInstanceName:String = "SpellButtonContainer";
		private const _uiSpellButtonName:String = "SpellButton";
		private const _uiSpellButtonInstanceNamePrefix:String = "SpellButton_";
				
		private const _spellButtonWidth:int = 44;
		private const _spellButtonHeight:int = 44;
		private const _spellButtonX:int = -44;
		private const _spellButtonY:int = 9;
		private const _spaceBetweenSpellButton:int = _spellButtonWidth + _spellButtonY;
		private const _backgroundWidth:int = _spellButtonWidth + 17;
		private const _backgroundHeight:int = 62;
		private const _backgroundX:int = 0;
		private const _backgroundY:int = 0;
		
		// Others
		private var _uniqueId:int = 0;
		private var _uiSpellButtonInstanceNames:Array = new Array();
		private var _onUiLoadedCallback:Function;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Constructor (do not call!).
		 *
		 * @private
		 *
		 * @throws	Error	The SpellButtonManager instance is already
		 * initialized.
		 */
		public function SpellButtonManager()
		{
			if (_instance)
				throw Error("SpellButtonManager already initilized.");
		}
		
		/**
		 * Return the unique instance of the SpellButtonManager class.
		 *
		 * @return	The unique instance of the SpellButtonManager class.
		 */
		public static function getInstance():SpellButtonManager
		{
			if (!_instance)
				_instance = new SpellButtonManager();
			
			return _instance;
		}
		
		/**
		 * Update the whole button's list.
		 *
		 * @param	spellList	Spell's list to display.
		 * @param	turn	Turn's number to display.
		 */
		public function updateSpellButtons(spellList:Array, spellListSize:int, turn:int):void
		{
			if (!isInterfaceLoaded())
				throw Error("SpellButtonContainer is not loaded");
			
			unloadSpellButtons();
			
			actualizeBackgroundHeight(spellListSize);
			actualizeBackgroundWidth(0);
			
			getInterfaceScript().displayTurn(turn);
			
			for (var ii:int = 0; ii < spellListSize; ii++)
			{
				for each (var spellData:SpellData in spellList[ii])
				{
					addSpellButton(ii, spellData);
				}
			}
		}
		
		/**
		 * Unload all the spell's buttons.
		 */
		private function unloadSpellButtons():void
		{
			for each (var list:Array in _uiSpellButtonInstanceNames)
			{
				for each (var instanceName:String in list)
				{
					Api.ui.unloadUi(instanceName);
				}
			}
			
			_uiSpellButtonInstanceNames = new Array();
		}
		
		/**
		 * Display a new spell's button in the button's list.
		 *
		 * @param	spellData	Spell's data to display.
		 */
		public function addSpellButton(line:int, spellData:SpellData):void
		{
			var interfaceScript:SpellButtonContainer = getInterfaceScript();
			var instanceName:String = createSpellButtonInstanceName();
			
			var spellButton:Object = Api.ui.loadUiInside(_uiSpellButtonName, interfaceScript.getSpellButtonContainer(), instanceName, spellData);
			
			trackSpellButton(line, instanceName);
			
			actualizeSpellButton(spellButton, getNbSpellButtons(line) - 1, line);
			
			actualizeBackgroundWidth(getNbSpellButtonsMax());
		}
		
		/**
		 * Create an unique instance name.
		 *
		 * @return	An unique instance name.
		 */
		private function createSpellButtonInstanceName():String
		{
			return _uiSpellButtonInstanceNamePrefix + getUniqueId().toString();
		}
		
		/**
		 * Get an unique identifier.
		 *
		 * @return An unique identifier.
		 */
		private function getUniqueId():int
		{
			return _uniqueId++;
		}
		
		/**
		 * Add the spell's button instance name to the instance name list.
		 *
		 * @param	instanceName	Instance name to tack.
		 */
		private function trackSpellButton(line:int, instanceName:String):void
		{
			if (_uiSpellButtonInstanceNames[line] == undefined)
				_uiSpellButtonInstanceNames[line] = new Array();
			
			Api.system.log(2, "track line: " + line);
			_uiSpellButtonInstanceNames[line].push(instanceName);
		}
		
		/**
		 * Get the number of spell buttons of the longest line.
		 *
		 * @return The number of spell buttons.
		 */
		private function getNbSpellButtonsMax():int
		{
			var max:int = 0;
			
			for each (var list:Array in _uiSpellButtonInstanceNames)
				if (list.length > max)
					max = list.length;
			
			return max;
		}
		
		public function actualizeBackgroundWidth(nbButtons:int):void
		{
			var tx_background:Texture = getInterfaceScript().getBackground();
			var width:int = _spaceBetweenSpellButton * nbButtons;
			tx_background.width = _backgroundWidth + width;
			tx_background.x = _backgroundX - width;
		}
		
		public function actualizeBackgroundHeight(nbLines:int):void
		{
			var tx_background:Texture = getInterfaceScript().getBackground();
			var height:int = _backgroundHeight * (nbLines - 1);
			tx_background.height = _backgroundHeight + height;
			tx_background.y = _backgroundY - height;
		}
		
		/**
		 * Get the number of spell buttons of the line <code>line</code>.
		 *
		 * @return The number of spell buttons.
		 */
		private function getNbSpellButtons(line:int):int
		{
			if (_uiSpellButtonInstanceNames[line] == undefined)
				return 0;
			
			return _uiSpellButtonInstanceNames[line].length;
		}
		
		/**
		 * Actualize the position of the spell button <code>spellButton</code>.
		 * 
		 * @param	spellButton	The button to move.
		 * @param	collumn	The collumn number where place the button.
		 * @param	line	The line number where place the button.
		 */
		private function actualizeSpellButton(spellButton:Object, collumn:int, line:int):void
		{
			spellButton.x = _spellButtonX - (collumn * _spaceBetweenSpellButton);
			spellButton.y = _spellButtonY - (line * _backgroundHeight);
		}
		
		public function isInterfaceLoaded():Boolean
		{
			return Api.ui.getUi(_uiContainerInstanceName) != null;
		}
		
		public function loadInterface(callback:Function):void
		{
			if (isInterfaceLoaded())
				throw Error("SpellButtonContainer already loaded");
			
			_onUiLoadedCallback = callback;
			
			Api.system.addHook(UiLoaded, onUiLoaded);
			Api.ui.loadUi(_uiContainerName, _uiContainerInstanceName);
		}
		
		public function unloadInterface():void
		{
			if (!isInterfaceLoaded())
				throw Error("SpellButtonContainer is not loaded");
			
			Api.ui.unloadUi(_uiContainerInstanceName);
		}
		
		private function getInterfaceScript():SpellButtonContainer
		{
			return Api.ui.getUi(_uiContainerInstanceName).uiClass;
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * This callback is process when the UiLoaded hook is raised.
		 *
		 * @param	instanceName	Instance's name of the loaded ui.
		 */
		private function onUiLoaded(instanceName:String):void
		{
			if (instanceName == _uiContainerInstanceName)
			{
				Api.system.removeHook(UiLoaded);
				
				_onUiLoadedCallback();
			}
		}
	}
}