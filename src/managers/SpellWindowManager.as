package managers
{
	import d2enums.StrataEnum;
	import d2hooks.GameFightTurnEnd;
	import errors.SingletonError;
	import types.SpellData;
	
	/**
	 * Manager for the SpellWindow UIs.
	 *
	 * @author Relena
	 */
	public class SpellWindowManager
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Statics
		private static var _instance:SpellWindowManager = null;
		private static var _allowInstance:Boolean = false;
		
		// Constants
		private const _uiName:String = "SpellWindow";
		private const _uiInstanceNamePrefix:String = "SpellWindow_";
		private const _uiMainContainerName:String = "ctn_main";
		
		private const windowMinX:int = 0;
		private const windowMinY:int = 0;
		private const windowMaxY:int = 800;
		private const windowMaxX:int = 1050;
		
		// Others
		private var _uniqueId:int = 0;
		private var _uiInstanceNames:Array = new Array();
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Constructor (do not call!).
		 *
		 * @private
		 *
		 * @throws	SingletonError	Can't create instance.
		 */
		public function SpellWindowManager()
		{
			if (!_allowInstance)
				throw new SingletonError();
			
			Api.system.addHook(GameFightTurnEnd, onGameFightTurnEnd);
		}
		
		/**
		 * Return the unique instance of the SpellWindowManager class.
		 *
		 * @return	The unique instance of the SpellWindowManager class.
		 */
		public static function getInstance():SpellWindowManager
		{
			if (!_instance)
			{
				_allowInstance = true;
				_instance = new SpellWindowManager();
				_allowInstance = false;
			}
			
			return _instance;
		}
		
		/**
		 * Create a new instance of the SpellWindow UI.
		 *
		 * @param	spellData	Parameter to send to the SpellWindow instance.
		 */
		public function createUi(spellData:SpellData):void
		{
			var newUi:Object = Api.ui.loadUi(_uiName, createInstanceName(), spellData, StrataEnum.STRATA_LOW);
			
			initUiPosition(newUi, getLastUi());
			trackUi(newUi);
		}
		
		/**
		 * Unload the SpellWindow instance.
		 */
		public function closeUi(instanceName:String):void
		{
			var pos:int = _uiInstanceNames.indexOf(instanceName);
			if (pos == -1)
				return;
			
			Api.ui.unloadUi(_uiInstanceNames.splice(pos, 1)[0]);
		}
		
		/**
		 * Unload all the SpellWindow instances.
		 */
		public function closeUis():void
		{
			for each (var instanceName:String in _uiInstanceNames)
			{
				Api.ui.unloadUi(instanceName);
			}
			
			_uiInstanceNames = new Array();
		}
		
		/**
		 * Initilize the position of <code>ui</code> according to
		 * <code>refUi</code> positon.
		 * 
		 * @param	ui	Ui to move.
		 * @param	refUi Reference Ui.
		 */
		private function initUiPosition(ui:Object, refUi:Object):void
		{
			if (ui == null || refUi == null)
				return
			
			var refUiContainer:Object = refUi.getElement(_uiMainContainerName);
			var uiContainer:Object = ui.getElement(_uiMainContainerName);
			
			var x:int = refUiContainer.x;
			var y:int = refUiContainer.y + refUiContainer.height;
			
			if (y >= windowMinY && y <= windowMaxY)
				uiContainer.y = y;
			else
				x += 100;
			
			if (x >= windowMinX && x <= windowMaxX)
				uiContainer.x = x;
		}
		
		/**
		 * Create an return a new instance name.
		 *
		 * @return	A new instance name.
		 */
		private function createInstanceName():String
		{
			return _uiInstanceNamePrefix + getUniqueId().toString();
		}
		
		/**
		 * Create and return an unique identifier.
		 *
		 * @return An unique identifier.
		 */
		private function getUniqueId():int
		{
			return _uniqueId++;
		}
		
		/**
		 * 
		 * @return
		 */
		private function getLastUi():Object
		{
			if (_uiInstanceNames.length == 0)
				return null;
			
			return Api.ui.getUi(_uiInstanceNames[_uiInstanceNames.length - 1]);
		}
		
		/**
		 * 
		 * @param	ui
		 */
		private function trackUi(ui:Object):void
		{
			_uiInstanceNames.push(ui.name);
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * 
		 * @param	fighterId
		 */
		private function onGameFightTurnEnd(fighterId:int):void
		{
			for each (var instanceName:String in _uiInstanceNames)
			{
				var ui:Object = Api.ui.getUi(instanceName);
				if (ui && fighterId == ui.uiClass.getDisplayedFighterId())
				{
					ui.uiClass.updateCooldown()
				}
			}
		}
	}
}