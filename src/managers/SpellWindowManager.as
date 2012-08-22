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
		
		// Others
		private var _uniqueId:int = 0;
		
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
		 * Create an return a new instance name. If <code>id</code> is not
		 * <code>-1</code>, return the instane name create with this
		 * <code>id</code>.
		 *
		 * @param	id	An identifier to use to create the instance name.
		 *
		 * @return	An instance name.
		 */
		private function createInstanceName(id:int = -1):String
		{
			if (id == -1)
				return _uiInstanceNamePrefix + getUniqueId().toString();
			
			return _uiInstanceNamePrefix + id.toString();
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
			Api.ui.loadUi(_uiName, createInstanceName(), spellData);
		}
		
		/**
		 * Unload all the SpellWindow instances.
		 */
		public function closeUis():void
		{
			for (var id:int = _uniqueId; id >= 0; id--)
			{
				Api.ui.unloadUi(createInstanceName(id));
			}
		}
	}
}