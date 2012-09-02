package managers.interfaces
{
	import types.SpellData;
	
	/**
	 * Spell buttons manager interface.
	 *
	 * @author Relena
	 */
	public interface SpellButtonManager
	{
		function loadInterface(callback:Function):void;
		function unloadInterface():void;
		function isInterfaceLoaded():Boolean
		function updateSpellButtons(spellList:Array, spellListSize:int, turn:int):void;
		function addSpellButton(spellData:SpellData):void
	}
}