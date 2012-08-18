package
{
	
	/**
	 * Spell's data container.
	 * 
	 * @author Relena
	 */
	public class SpellData
	{
		public static const SPELL_TYPE_SPELL:int = 0;
		public static const SPELL_TYPE_WEAPON:int = 1;
		public static const SPELL_TYPE_MOVEMENT:int = 2;
		
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
		 * Spell type (Spell, Weapon, Movement)
		 */
		public var _spellType:int
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
		public var _spellCritical:int;
		
		/**
		 * Simple convenience function.
		 * 
		 * @param	fighterId
		 * @param	critical
		 * @param	spellType
		 * @param	spellId
		 * @param	spellRank
		 * @param	cellId
		 * @param	sourceCellId
		 */
		public function SpellData(fighterId:int, critical:int, spellType:int, spellId:int, spellRank:int = 0, cellId:int = 0, sourceCellId:int = 0)
		{
			_fighterId = fighterId;
			_spellCritical = critical;
			_spellType = spellType;
			_spellId = spellId;
			_spellRank = spellRank;
			_cellId = cellId;
			_sourceCellId = sourceCellId;
		}
	}
}