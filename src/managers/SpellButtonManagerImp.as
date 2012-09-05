package managers
{
	import d2components.GraphicContainer;
	import d2hooks.UiLoaded;
	import managers.interfaces.SpellButtonManager;
	import managers.interfaces.SpellWindowManager;
	import types.SpellButtonParams;
	import types.SpellData;
	import ui.SpellButtonContainer;
	
	/**
	 * Manager for the main fight UI.
	 *
	 * @author Relena
	 */
	public class SpellButtonManagerImp implements SpellButtonManager
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Dependencies
		private var _spellWindowManager:SpellWindowManager;
		
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
		private var _nbSpellButtonByLine:Array = new Array();
		private var _onUiLoadedCallback:Function;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Constructor.
		 *
		 * @param	spellWindowManager
		 */
		public function SpellButtonManagerImp(spellWindowManager:SpellWindowManager)
		{
			_spellWindowManager = spellWindowManager;
			
			Api.system.addHook(UiLoaded, onUiLoaded);
		}
		
		/**
		 * Load the button container.
		 *
		 * @param	callback	Function call when the button container is
		 * loaded.
		 *
		 * @throws	Error	SpellButtonContainer already loaded.
		 */
		public function loadInterface(callback:Function = null):void
		{
			if (isInterfaceLoaded())
				throw Error("SpellButtonContainer already loaded");
			
			_onUiLoadedCallback = callback;
			
			Api.ui.loadUi(_uiContainerName, _uiContainerInstanceName);
		}
		
		/**
		 * Unload the button container.
		 *
		 * @throws	Error	SpellButtonContainer is not loaded.
		 */
		public function unloadInterface():void
		{
			if (!isInterfaceLoaded())
				throw Error("SpellButtonContainer is not loaded");
			
			unloadSpellButtons();
			
			Api.ui.unloadUi(_uiContainerInstanceName);
		}
		
		/**
		 * Test if the button container is loaded.
		 *
		 * @return	True if the button container is loaded, else false.
		 */
		public function isInterfaceLoaded():Boolean
		{
			return Api.ui.getUi(_uiContainerInstanceName) != null;
		}
		
		/**
		 * Return the button container instance.
		 *
		 * @return	The button container instance.
		 */
		private function getInterfaceScript():SpellButtonContainer
		{
			return Api.ui.getUi(_uiContainerInstanceName).uiClass;
		}
		
		/**
		 * Update the whole button's list.
		 *
		 * @param	spellList	Spell's list to display.
		 * @param	spellListSize	The size of the spell list.
		 * @param	turn	Turn's number to display.
		 *
		 * @throws	Error	SpellButtonContainer is not loaded.
		 */
		public function updateSpellButtons(spellList:Array, spellListSize:int, turn:int):void
		{
			if (!isInterfaceLoaded())
				throw Error("SpellButtonContainer is not loaded");
			
			unloadSpellButtons();
			
			var background:GraphicContainer = getInterfaceScript().getBackground();
			updateBackgroundHeight(background, (spellListSize > 0) ? spellListSize : 1);
			updateBackgroundWidth(background, 0);
			
			getInterfaceScript().displayTurn(turn);
			
			for (var ii:int = 0; ii < spellListSize; ii++)
			{
				for each (var spellData:SpellData in spellList[ii])
				{
					addSpellButtonToLine(ii, spellData);
				}
			}
		}
		
		/**
		 * Display a new spell's button in the button's list.
		 *
		 * @param	spellData	Spell's data to display.
		 *
		 * @throws	Error	SpellButtonContainer is not loaded.
		 */
		public function addSpellButton(spellData:SpellData):void
		{
			if (!isInterfaceLoaded())
				throw Error("SpellButtonContainer is not loaded");
			
			addSpellButtonToLine(0, spellData);
		}
		
		/**
		 * Display a new spell's button in the button's list at line
		 * <code>line</code>.
		 *
		 * @param	line	The line number to display the button
		 * @param	spellData	Spell's data to display.
		 */
		private function addSpellButtonToLine(line:int, spellData:SpellData):void
		{
			var interfaceScript:SpellButtonContainer = getInterfaceScript();
			var instanceName:String = createSpellButtonInstanceName();
			
			var spellButtonParams:SpellButtonParams = new SpellButtonParams(spellData, _spellWindowManager);
			
			var spellButton:Object = Api.ui.loadUiInside(_uiSpellButtonName, interfaceScript.getSpellButtonContainer(), instanceName, spellButtonParams);
			
			incrementNbSpellButton(line);
			
			initSpellButtonPosition(spellButton, getNbSpellButtons(line) - 1, line);
			
			var background:GraphicContainer = getInterfaceScript().getBackground();
			updateBackgroundWidth(background, getNbSpellButtonsMax());
		}
		
		/**
		 * Unload all the spell's buttons.
		 */
		private function unloadSpellButtons():void
		{
			for each (var uiInstance:Object in Api.ui.getUiInstances())
			{
				if (uiInstance.name.indexOf(_uiSpellButtonInstanceNamePrefix) == 0)
				{
					Api.ui.unloadUi(uiInstance.name);
				}
			}
			
			_nbSpellButtonByLine = new Array();
		}
		
		/**
		 * Initialize the position of the spell button <code>spellButton</code>.
		 *
		 * @param	spellButton	The button to move.
		 * @param	collumn	The collumn number where place the button.
		 * @param	line	The line number where place the button.
		 */
		private function initSpellButtonPosition(spellButton:Object, collumn:int, line:int):void
		{
			spellButton.x = _spellButtonX - (collumn * _spaceBetweenSpellButton);
			spellButton.y = _spellButtonY - (line * _backgroundHeight);
		}
		
		/**
		 * Update the with of the background.
		 *
		 * @param	background
		 * @param	nbButtons
		 */
		private function updateBackgroundWidth(background:GraphicContainer, nbButtons:int):void
		{
			var width:int = _spaceBetweenSpellButton * nbButtons;
			background.width = _backgroundWidth + width;
			background.x = _backgroundX - width;
		}
		
		/**
		 * Update the height of the background.
		 *
		 * @param	background
		 * @param	nbLines
		 */
		private function updateBackgroundHeight(background:GraphicContainer, nbLines:int):void
		{
			var height:int = _backgroundHeight * (nbLines - 1);
			background.height = _backgroundHeight + height;
			background.y = _backgroundY - height;
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
		 * Increment the number of spell button of line <code>line</code>.
		 *
		 * @param	line
		 */
		private function incrementNbSpellButton(line:int):void
		{
			if (_nbSpellButtonByLine[line] == undefined)
				_nbSpellButtonByLine[line] = 0;
			
			_nbSpellButtonByLine[line]++;
		}
		
		/**
		 * Get the number of spell buttons of the line <code>line</code>.
		 *
		 * @param	line
		 *
		 * @return The number of spell buttons.
		 */
		private function getNbSpellButtons(line:int):int
		{
			if (_nbSpellButtonByLine[line] == undefined)
				return 0;
			
			return _nbSpellButtonByLine[line];
		}
		
		/**
		 * Get the number of spell buttons of the longest line.
		 *
		 * @return The number of spell buttons.
		 */
		private function getNbSpellButtonsMax():int
		{
			var max:int = 0;
			
			for each (var nbButton:int in _nbSpellButtonByLine)
				if (nbButton > max)
					max = nbButton;
			
			return max;
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
				if (_onUiLoadedCallback == null)
					return;
				
				_onUiLoadedCallback();
			}
		}
	}
}