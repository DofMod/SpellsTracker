package helpers
{
	import d2hooks.GameFightEnd;
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
		private var fightersLastPlayedTurn:Array;
		
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
			
			fightersLastPlayedTurn = new Array();
			
			Api.system.addHook(GameFightTurnStart, onGameFightTurnStart);
			Api.system.addHook(GameFightEnd, onGameFightEnd);
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
		 * Get the number of the last turn played by a fighter.
		 *
		 * @param	fighterId	The fighter identifier.
		 *
		 * @return	The last turn played.
		 */
		public function getLastTurnPlayed(fighterId:int):int
		{
			if (!Api.system.isFightContext())
				throw Error("Unalowed call to getLastTurnPlayer while not in fight context");
			
			if (fightersLastPlayedTurn[fighterId] == undefined)
			{
				if (Api.fight.getTurnsCount() == 0)
				{
					for each (var playerId:int in Api.fight.getFighters())
					{
						fightersLastPlayedTurn[fighterId] = 0;
					}
				}
				else
				{
					// TODO fix when we can get the fighter who is playing his turn
					
					fightersLastPlayedTurn[fighterId] = 0;
				}
			}
			
			return fightersLastPlayedTurn[fighterId];
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
			fightersLastPlayedTurn[fighterId] = Api.fight.getTurnsCount();
		}
		
		/**
		 * This callback is process when the GameFightEnd's hook is dispatched.
		 * Reset the class variables.
		 *
		 * @param	params	(not used).
		 */
		private function onGameFightEnd(params:Object):void
		{
			fightersLastPlayedTurn = new Array();
		}
	}
}