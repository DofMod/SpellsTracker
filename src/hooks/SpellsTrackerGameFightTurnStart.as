package hooks
{
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Hook dispatch when a fighter start his turn.
	 * 
	 * Callback parameters:
	 * - fighterId:int, Identifier of the fighter.
	 *
	 * @author Relena
	 */
	public class SpellsTrackerGameFightTurnStart
	{
		public static const name:String = getQualifiedClassName(SpellsTrackerGameFightTurnStart).split("::").pop();
	}
}