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
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		public var spellData:SpellData;
		public var spellWindowManager:SpellWindowManager;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		public function SpellButtonParams(spellData:SpellData, spellWindowManager:SpellWindowManager)
		{
			this.spellData = spellData;
			this.spellWindowManager = spellWindowManager;
		}
	}
}