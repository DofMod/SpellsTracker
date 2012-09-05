package managers.interfaces
{
	import types.CountdownData;
	
	/**
	 * Spell windows manager interface.
	 *
	 * @author Relena
	 */
	public interface SpellWindowManager
	{
		function createUi(countdownData:CountdownData):void;
		function closeUi(instanceName:String):void;
		function closeUis():void;
	}
}