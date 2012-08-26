package helpers
{
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightLeave;
	import d2hooks.GameFightTurnEnd;
	import d2hooks.GameFightTurnStart;
	
	/**
	 * Manager for the main fight UI.
	 *
	 * @author Relena
	 */
	public class PlayedTurnTracker
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Statics
		private static var _instance:PlayedTurnTracker;
		
		// Others
		private var _fightersLastPlayedTurn:Array;
		private var _currentPlayingFighter:int;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Constructor (do not call!).
		 *
		 * @private
		 *
		 * @throws	Error	The PlayedTurnTracker instance is already
		 * initialized.
		 */
		public function PlayedTurnTracker()
		{
			if (_instance)
				throw Error("PlayedTurnTracker already initilized.");
			
			resetGlobals();
			
			Api.system.addHook(GameFightTurnStart, onGameFightTurnStart);
			Api.system.addHook(GameFightTurnEnd, onGameFightTurnEnd);
			Api.system.addHook(GameFightEnd, onGameFightEnd);
			Api.system.addHook(GameFightLeave, onGameFightLeave);
		}
		
		/**
		 * Return the unique instance of the PlayedTurnTracker class.
		 *
		 * @return	The unique instance of the PlayedTurnTracker class.
		 */
		public static function getInstance():PlayedTurnTracker
		{
			if (!_instance)
				_instance = new PlayedTurnTracker();
			
			return _instance;
		}
		
		/**
		 * Initialize the globals.
		 */
		private function resetGlobals():void
		{
			_fightersLastPlayedTurn = new Array();
			_currentPlayingFighter = 0;
		}
		
		/**
		 * Get the number of the last turn played by a fighter.
		 *
		 * @param	fighterId	The fighter identifier.
		 *
		 * @return	The last turn played.
		 * 
		 * @throws	Error	Unalowed call to getLastTurnPlayer while not in fight context
		 */
		public function getLastTurnPlayed(fighterId:int):int
		{
			if (!Api.system.isFightContext())
				throw Error("Unalowed call to getLastTurnPlayer while not in fight context");
			
			if (_fightersLastPlayedTurn[fighterId] == undefined)
			{
				if (Api.fight.getTurnsCount() == 0)
				{
					for each (var playerId:int in Api.fight.getFighters())
					{
						_fightersLastPlayedTurn[fighterId] = 0;
					}
				}
				else
				{
					// TODO fix when we can get the fighter who is playing his turn
					
					_fightersLastPlayedTurn[fighterId] = 0;
				}
			}
			
			return _fightersLastPlayedTurn[fighterId];
		}
		
		/**
		 * Return the current playing fighter.
		 * 
		 * @return	Identifier of the current playing fighter. 0 if between two player turn.
		 * 
		 * @throws	Error	Unalowed call to getLastTurnPlayer while not in fight context
		 */
		public function getCurrentPlayingFighter():int {
			if (!Api.system.isFightContext())
				throw Error("Unalowed call to getLastTurnPlayer while not in fight context");
			
			return _currentPlayingFighter;
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * This callback is process when the GameFightTurnStart hook is
		 * dispatched. Catch the number of the last turn played by each fighter.
		 *
		 * @param	fighterId	Identifier of the fighter who start his turn.
		 * @param	waitTime	Maximum time alowed to the fighter to play (in ms).
		 * @param	displayImage	(not used).
		 */
		private function onGameFightTurnStart(fighterId:int, waitTime:int, displayImage:Boolean):void
		{
			_fightersLastPlayedTurn[fighterId] = Api.fight.getTurnsCount();
			_currentPlayingFighter = fighterId;
		}
		
		/**
		 * 
		 * @param	fighterId
		 */
		private function onGameFightTurnEnd(fighterId:int):void
		{
			_currentPlayingFighter = 0;
		}
		
		/**
		 * This callback is process when the GameFightEnd's hook is dispatched.
		 * Reset the class variables.
		 *
		 * @param	params	(not used).
		 */
		private function onGameFightEnd(params:Object):void
		{
			resetGlobals();
		}
		
		/**
		 * This callback is process when the GameFightLeave hook is dispatched.
		 * Reset the class variables.
		 * 
		 * @param	fighterId
		 */
		private function onGameFightLeave(fighterId:int):void
		{
			if (fighterId == Api.fight.getCurrentPlayedFighterId())
			{
				resetGlobals();
			}
		}
	}
}