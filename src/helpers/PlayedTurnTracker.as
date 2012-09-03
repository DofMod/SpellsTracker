package helpers
{
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightLeave;
	import d2hooks.GameFightTurnEnd;
	import d2hooks.GameFightTurnStart;
	import errors.SingletonError;
	
	/**
	 * This class is an helper for the turn tracking. A Turn begin with the
	 * reception of the hook GameFightTurnStart and end with the hook
	 * GameFightTurnEnd. If you want to call this class within some handler of
	 * these two hook, be sure that the handler of this class has been process
	 * first, else you will get wrong informations.
	 *
	 * @author Relena
	 */
	public class PlayedTurnTracker
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Others
		private var _initialized:Boolean;
		private var _fightersLastPlayedTurn:Array;
		private var _currentPlayingFighter:int;
		private var _turnDone:Boolean;
		
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
		public function PlayedTurnTracker()
		{
			resetGlobals();
			
			Api.system.addHook(GameFightTurnStart, onGameFightTurnStart);
			Api.system.addHook(GameFightTurnEnd, onGameFightTurnEnd);
			Api.system.addHook(GameFightEnd, onGameFightEnd);
			Api.system.addHook(GameFightLeave, onGameFightLeave);
		}
		
		/**
		 * Initialize the globals.
		 */
		private function resetGlobals():void
		{
			_initialized = false;
			_fightersLastPlayedTurn = new Array();
			_currentPlayingFighter = 0;
			_turnDone = false;
		}
		
		/**
		 * Initialise the class.
		 * 
		 * @param	playingFighterId Identifier of the current playing fighter.
		 */
		private function initialize(playingFighterId:int = 0):void
		{
			var fighterId:int;
			var currentTurn:int = Api.fight.getTurnsCount();
			if (currentTurn == 0)
			{
				for each (fighterId in Api.fight.getFighters())
				{
					_fightersLastPlayedTurn[fighterId] = 0;
				}
			}
			else if (playingFighterId != 0)
			{
				for each (fighterId in Api.fight.getFighters())
				{
					_fightersLastPlayedTurn[fighterId] = currentTurn;
					
					if (fighterId == playingFighterId)
						currentTurn--;
				}
			}
			else
			{
				// Debug.
				throw Error("Turn is not 0 and we do not know the current playing fighter ?")
			}
			
			_initialized = true;
		}
		
		/**
		 * Get the number of the last turn played by a fighter.
		 *
		 * @param	fighterId	The fighter identifier.
		 *
		 * @return	The last turn played.
		 * 
		 * @throws	Error	Unalowed call to getLastTurnPlayer while not in fight context.
		 */
		public function getLastTurnPlayed(fighterId:int):int
		{
			if (!Api.system.isFightContext())
				throw Error("Unalowed call to getLastTurnPlayer while not in fight context");
			
			if (!_initialized)
				initialize();
			
			return _fightersLastPlayedTurn[fighterId];
		}
		
		/**
		 * Return the current playing fighter.
		 * 
		 * @return	Identifier of the current playing fighter.
		 * 
		 * @throws	Error	Unalowed call to getLastTurnPlayer while not in fight context.
		 */
		public function getCurrentPlayingFighter():int {
			if (!Api.system.isFightContext())
				throw Error("Unalowed call to getLastTurnPlayer while not in fight context");
			
			return _currentPlayingFighter;
		}
		
		/**
		 * The meaning of this function is to know if the current fighter has
		 * finish his turn.
		 * 
		 * @return	True of we are between the turn of two consecutive fighter.
		 * 
		 * @throws	Error	Unalowed call to isTurnDone while not in fight context.
		 */
		public function isTurnDone():Boolean {
			if (!Api.system.isFightContext())
				throw Error("Unalowed call to isTurnDone while not in fight context");
			
			return _turnDone;
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
			_turnDone = false;
			
			if (!_initialized)
				initialize(_currentPlayingFighter);
		}
		
		/**
		 * 
		 * @param	fighterId
		 */
		private function onGameFightTurnEnd(fighterId:int):void
		{
			_turnDone = true;
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