package managers
{	
	import d2components.GraphicContainer;
	import d2components.Texture;
	import d2hooks.UiLoaded;
	import errors.SingletonError;
	import managers.interfaces.SpellButtonManager;
	import managers.interfaces.SpellWindowManager;
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
		private var _uiSpellButtonInstanceNames:Array = new Array();
		private var _onUiLoadedCallback:Function;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
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
			
			trackSpellButton(line, instanceName);
			
			var spellButton:Object = Api.ui.loadUiInside(_uiSpellButtonName, interfaceScript.getSpellButtonContainer(), instanceName, spellData);
			
			initSpellButtonPosition(spellButton, getNbSpellButtons(line) - 1, line);
			
			var background:GraphicContainer = getInterfaceScript().getBackground();
			updateBackgroundWidth(background, getNbSpellButtonsMax());
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
		 * Add the spell's button instance name to the instance name list.
		 *
		 * @param	instanceName	Instance name to tack.
		 */
		private function trackSpellButton(line:int, instanceName:String):void
		{
			if (_uiSpellButtonInstanceNames[line] == undefined)
				_uiSpellButtonInstanceNames[line] = new Array();
			
			_uiSpellButtonInstanceNames[line].push(instanceName);
		}
		
		/**
		 * Check if a spellButton instance is track.
		 * 
		 * @param	instanceName
		 * 
		 * @return	True or False.
		 */
		private function isTrackedSpellButton(instanceName:String):Boolean
		{
			for each (var list:Array in _uiSpellButtonInstanceNames)
				if (list.indexOf(instanceName) != -1)
					return true;
			
			return false;
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
			else if (isTrackedSpellButton(instanceName))
			{
				var uiInstance:Object = Api.ui.getUi(instanceName);
				if (!uiInstance)
					return;
				
				var uiClass:ui.SpellButton = uiInstance.uiClass;
				uiClass.initDependencies(_spellWindowManager);
				uiClass.initUi();
			}
		}
	}
}