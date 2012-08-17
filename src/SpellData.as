package
{
	
	/**
	 * Spell's data container.
	 * 
	 * @author Relena
	 */
	public class SpellData
	{
		/**
		 * Fighter id.
		 */
		public var _fighterId:int;
		/**
		 * Target cell id.
		 */
		public var _cellId:int;
		/**
		 * Source cell id.
		 */
		public var _sourceCellId:int;
		/**
		 * Spell id.
		 */
		public var _spellId:int;
		/**
		 * Spell level.
		 */
		public var _spellRank:int;
		/**
		 * 1 : normal, 2 : cricial, 3 : critical failure ?
		 */
		public var _spellCritical:Boolean;
	}
}