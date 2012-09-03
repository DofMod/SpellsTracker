package managers
{
	import d2enums.StrataEnum;
	import d2hooks.GameFightTurnEnd;
	import d2hooks.UiLoaded;
	import errors.SingletonError;
	import helpers.PlayedTurnTracker;
	import managers.interfaces.SpellWindowManager;
	import types.CountdownData;
	import types.SpellWindowParams;
	import ui.SpellWindow;
	
	/**
	 * Manager for the SpellWindow UIs.
	 *
	 * @author Relena
	 */
	public class SpellWindowManagerImp implements SpellWindowManager
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Dependencies
		private var _playedTurnTracker:PlayedTurnTracker;
		
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
		 * 
		 */
		public function SpellWindowManagerImp(playedTurnTracker:PlayedTurnTracker)
		{
			_playedTurnTracker = playedTurnTracker;
			
			Api.system.addHook(GameFightTurnEnd, onGameFightTurnEnd);
		}
		
		/**
		 * Create a new instance of the SpellWindow UI.
		 *
		 * @param	countdownData	Parameter to send to the SpellWindow instance.
		 */
		public function createUi(counddownData:CountdownData):void
		{
			var spellWindowParams:SpellWindowParams = new SpellWindowParams(counddownData, this, _playedTurnTracker);
			
			var newUi:Object = Api.ui.loadUi(_uiName, createInstanceName(), spellWindowParams, StrataEnum.STRATA_LOW);
			
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
			var uiContainer:Object = Object(ui).getElement(_uiMainContainerName);
			
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
			_uiInstanceNames.push(Object(ui).name);
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
			var uiInstance:Object;
			var uiClass:SpellWindow;
			for each (var instanceName:String in _uiInstanceNames)
			{
				uiInstance = Api.ui.getUi(instanceName);
				if (!uiInstance)
					continue;
				
				uiClass = uiInstance.uiClass;
				if (fighterId == uiClass.getDisplayedFighterId())
				{
					uiClass.updateCountdown();
				}
			}
		}
	}
}