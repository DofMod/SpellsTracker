package types
{
	import managers.interfaces.SpellWindowManager;
	
	/**
	 * SpellButton parameters.
	 *
	 * @author Relena
	 */
	public class SpellButtonParams
	{
		public var spellData:SpellData;
		public var spellWindowManager:SpellWindowManager;
		
		public function SpellButtonParams(spellData:SpellData, spellWindowManager:SpellWindowManager)
		{
			this.spellData = spellData;
			this.spellWindowManager = spellWindowManager;
		}
	}
}