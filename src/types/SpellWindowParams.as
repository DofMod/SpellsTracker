package types
{
	import helpers.PlayedTurnTracker;
	import managers.interfaces.SpellWindowManager;
	
	/**
	 * SpellWindow parameters.
	 *
	 * @author Relena
	 */
	public class SpellWindowParams
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		public var countdownData:CountdownData;
		public var spellWindowManager:SpellWindowManager;
		public var playedTurnTracker:PlayedTurnTracker;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		public function SpellWindowParams(countdownData:CountdownData, spellWindowManager:SpellWindowManager, playedTurnTracker:PlayedTurnTracker)
		{
			this.countdownData = countdownData;
			this.spellWindowManager = spellWindowManager;
			this.playedTurnTracker = playedTurnTracker;
		}
	}
}