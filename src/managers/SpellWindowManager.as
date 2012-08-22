package managers
{
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
		private static var _instance:SpellWindowManager;
		
		// Constants
		private const _uiName:String = "SpellWindow";
		private const _uiInstanceNamePrefix:String = "SpellWindow_";
		private const _uiMainContainerName:String = "ctn_main";
		
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
		 * @throws	Error	The SpellWindow instance is already initialized.
		 */
		public function SpellWindowManager()
		{
			if (_instance)
				throw Error("SpellWindowManager already initilized.");
		}
		
		/**
		 * Return the unique instance of the SpellWindowManager class.
		 *
		 * @return	The unique instance of the SpellWindowManager class.
		 */
		public static function getInstance():SpellWindowManager
		{
			if (!_instance)
				_instance = new SpellWindowManager();
			
			return _instance;
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
		 * Create a new instance of the SpellWindow UI.
		 *
		 * @param	spellData	Parameter to send to the SpellWindow instance.
		 */
		public function createUi(spellData:SpellData):void
		{
			var newUi:Object = Api.ui.loadUi(_uiName, createInstanceName(), spellData);
			
			initUiPosition(newUi, getLastUi());
			trackUi(newUi);
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
			if (refUi == null)
				return
			
			var refUiContainer:Object = refUi.getElement(_uiMainContainerName);
			var uiContainer:Object = ui.getElement(_uiMainContainerName);
			
			uiContainer.x = refUiContainer.x;
			uiContainer.y = refUiContainer.y + refUiContainer.height;
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
		 * Unload the SpellWindow instance
		 */
		public function closeUi(instanceName:String):void
		{
			var pos:int = _uiInstanceNames.indexOf(instanceName);
			if (pos == -1)
				return;
			
			Api.ui.unloadUi(_uiInstanceNames.splice(pos, 1)[0]);
		}
		
		/**
		 * 
		 * @param	ui
		 */
		private function trackUi(ui:Object):void
		{
			_uiInstanceNames.push(ui.name);
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
	}
}