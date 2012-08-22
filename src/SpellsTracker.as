package
{
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2enums.FightEventEnum;
	import d2hooks.FighterSelected;
	import d2hooks.FightEvent;
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightTurnStart;
	import d2hooks.UiLoaded;
	import flash.display.Sprite;
	import ui.SpellButtonContainer;
	import ui.SpellButton;
	import ui.SpellsTrackerConfig;
	import ui.SpellWindow;
	
	/**
	 * Main function of the SpellsTracker module. Tracks the spell's data and
	 * manage the various UIs.
	 *
	 * @author Relena
	 */
	public class SpellsTracker extends Sprite
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// Includes
		private var includes:Array = [SpellButtonContainer, SpellButton, SpellWindow, SpellsTrackerConfig];
		
		// APIs
		/**
		 * @private
		 *
		 * getCurrentPlayedFighterId, getTurnCount, getFighters
		 */
		public var fightApi:FightApi;
		/**
		 * @private
		 *
		 * addHook, log
		 */
		public var sysApi:SystemApi;
		/**
		 * @private
		 *
		 * getUi, loadUi, unloadUi
		 */
		public var uiApi:UiApi;
		
		// Components
		[Module(name = "Ankama_Common")]
		/**
		 * Module Ankama_Common reference.
		 * 
		 * @private
		 */
		public var modCommon:Object;
		
		// Divers
		private var currentFighterId:int;
		private var displayedFighterId:int;
		private var fightersDisplayedTurn:Array;
		private var fightersAutoUpdate:Array;
		private var fightersLastPlayedTurn:Array;
		private var spellList:Array;
		
		private var maxDisplayedTurn:int;
		
		private const containerUIName:String = "SpellButtonContainer";
		private const containerUIInstanceName:String = "SpellTracker";
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialize the module.
		 */
		public function main():void
		{
			initGlobals();
			reloadConfig();
			
			sysApi.addHook(FighterSelected, onFighterSelected);
			sysApi.addHook(FightEvent, onFightEvent);
			sysApi.addHook(GameFightEnd, onGameFightEnd);
			sysApi.addHook(GameFightTurnStart, onGameFightTurnStart);
			sysApi.addHook(UiLoaded, onUiLoaded);
			
			modCommon.addOptionItem("module_spellstracker",
				"(M) Spells Tracker",
				"Ces options servent à configurer le module SpellsTracker",
				"SpellsTracker::SpellsTrackerConfig");
		}
		
		/**
		 * Reset the globals
		 */
		private function initGlobals():void
		{
			currentFighterId = 0;
			displayedFighterId = 0;
			fightersDisplayedTurn = new Array();
			fightersAutoUpdate = new Array();
			fightersLastPlayedTurn = new Array();
			spellList = new Array();
		}
		
		/**
		 * Cleanup function.
		 */
		public function unload():void
		{
		}
		
		/**
		 * Reload the configuration file
		 */
		public function reloadConfig():void
		{
			maxDisplayedTurn = (sysApi.getData("cb_maxDisplayedTurn") == undefined) ? 3 : sysApi.getData("cb_maxDisplayedTurn");
		}
		
		/**
		 * Add the spell's data to the spell's list.
		 *
		 * @param	spellData	Spell's data to track.
		 */
		private function trackSpellData(spellData:SpellData):void
		{
			var fighterId:int = spellData._fighterId;
			if (spellList[fighterId] == undefined)
			{
				spellList[fighterId] = new Array();
			}
			
			if (spellList[fighterId][fightApi.getTurnsCount()] == undefined)
			{
				spellList[fighterId][fightApi.getTurnsCount()] = new Array();
			}
			
			spellList[fighterId][fightApi.getTurnsCount()].push(spellData);
		}
		
		/**
		 * Return the current spell's list.
		 *
		 * @param	fighterId	Fighter's id of the spell's list.
		 * @param	turn		Turn of the spell's list.
		 * @param	castId		Id of the spell's list.
		 *
		 * @return If <code>fighterId == 0</code>, return the spell's list of
		 * all the turn of all the fighter. Else, if <code>turn == -1</code>,
		 * return the spell's list of all the turn of the fighter
		 * <code>fighterId</code>. Else, if <code>castId == -1</code>, return
		 * the spell's list of the fighter <code>fighterId</code> of the turn
		 * <code>turn</code>. Elle, return the spell's data of the fighter
		 * <code>fighterId</code> of the turn <code>turn</code> of the
		 * <code>castId</code>.
		 * Return <code>null</code> if the spell's list requested doesn't exist.
		 */
		public function getSpellData(fighterId:int = 0, turn:int = -1, castId:int = -1):Array
		{
			if (!spellList)
				return null;
			
			if (fighterId == 0)
				return spellList;
			
			if (spellList[fighterId] == undefined)
				return null;
			
			if (turn == -1)
				return spellList[fighterId];
			
			if (spellList[fighterId][turn] == undefined)
				return null;
			
			if (castId == -1)
				return spellList[fighterId][turn];
			
			return spellList[fighterId][turn][castId];
		}
		
		/**
		 * Select the wright turn, and display the spell's list of this turn.
		 * <code>Turn</code> must be between 1 and fightApi.getTurnCount().
		 *
		 * @param	turn	Turn of the spell's list to display.
		 */
		private function updateSpells(turn:int):void
		{
			var containerUI:Object = uiApi.getUi(containerUIInstanceName);
			if (!containerUI)
				return;
			
			if (fightersLastPlayedTurn[displayedFighterId] == undefined)
				fightersLastPlayedTurn[displayedFighterId] = 1;
			
			if (turn > fightersLastPlayedTurn[displayedFighterId])
				turn = fightersLastPlayedTurn[displayedFighterId];
			
			var spellListArray:Array = new Array();
			var spellListArraySize:int = maxDisplayedTurn;
			for (var ii:int = 0; ii < maxDisplayedTurn; ii++)
			{
				if (turn - ii < 1)
				{
					spellListArraySize = ii;
					break;
				}
				
				spellListArray.push(getSpellData(displayedFighterId, turn - ii));
			}
			
			containerUI.uiClass.updateSpellButtons(spellListArray, spellListArraySize, turn);
		}
		
		/**
		 * Request the displaying of the spell's list og the turn
		 * <code>turn</code> of the current displayed fighter.
		 *
		 * @param	turn	Turn of the spell's list to display. Must be between
		 * 1 and fightApi.getTurnCount().
		 */
		public function requestUpdateSpells(turn:int):void
		{
			if (turn < 1)
				return;
			
			if (turn > fightApi.getTurnsCount())
				return;
			
			fightersAutoUpdate[displayedFighterId] = false;
			fightersDisplayedTurn[displayedFighterId] = turn;
			
			updateSpells(turn);
		}
		
		/**
		 * Toggle the auto update spell's list.
		 */
		public function requestAutoUpdate():void
		{
			var turn:int = fightApi.getTurnsCount();
			
			fightersAutoUpdate[displayedFighterId] = true;
			fightersDisplayedTurn[displayedFighterId] = (turn > 0) ? turn : 1;
			
			updateSpells(fightersDisplayedTurn[displayedFighterId]);
		}
		
		/**
		 * Display the <code>spellData</code> object if the current turn and the
		 * spellData's fighter match with the current displayed turn and the
		 * current displayed fighter.
		 *
		 * @param	spellData	Spell's data to display.
		 */
		private function tryDisplaySpellData(spellData:SpellData):void
		{
			if (spellData._fighterId != displayedFighterId || fightApi.getTurnsCount() != fightersDisplayedTurn[displayedFighterId])
				return;
			
			var containerUI:Object = uiApi.getUi(containerUIInstanceName);
			if (!containerUI)
				return;
			
			containerUI.uiClass.addSpellButton(0, spellData);
		}
		
		private var spellWindowId:int = 0
		private function createSpellWindowName(id:int = -1):String
		{
			if (id == -1)
				return "SpellWindow_" + (spellWindowId++);
			
			return "SpellWindow_" + id;
		}
		
		public function createSpellWindow(spellData:SpellData):void
		{
			uiApi.loadUi("SpellWindow", createSpellWindowName(), spellData);
		}
		
		public function closeSpellWindows():void
		{
			for (var id:int = spellWindowId; id >= 0; id--)
			{
				sysApi.log(2, createSpellWindowName(id));
				uiApi.unloadUi(createSpellWindowName(id));
			}
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * This callback is process when the FightEvent hook is raised. Track
		 * the spell's infos and display them if the right ui is loaded.
		 *
		 * @param	eventName	Name of the current event.
		 * @param	params		Parameters of the current event.
		 * @param	targetList	(not used).
		 */
		private function onFightEvent(eventName:String, params:Object, targetList:Object = null):void
		{
			var spellData:SpellData;
			if (eventName == FightEventEnum.FIGHTER_CASTED_SPELL)
			{
				spellData = new SpellData(params[0], params[5], SpellData.SPELL_TYPE_SPELL, params[3], params[4], params[1], params[2]);
				
				trackSpellData(spellData);
				
				tryDisplaySpellData(spellData);
			}
			else if (eventName == FightEventEnum.FIGHTER_CLOSE_COMBAT)
			{
				spellData = new SpellData(params[0], params[2], SpellData.SPELL_TYPE_WEAPON, params[1]);
				
				trackSpellData(spellData);
				
				tryDisplaySpellData(spellData);
			}
		}
		
		/**
		 * This callback is process when the FighterSelected hook is raised.
		 * Load the main ui if not, else if the current displayed fighter and
		 * the request displayed fighter are the same, unload the main ui. Else
		 * update the spell's buttons.
		 *
		 * @param	fighterId	Id of the selected fighter.
		 */
		private function onFighterSelected(fighterId:int):void
		{
			var containerUI:Object = uiApi.getUi(containerUIInstanceName);
			if (!containerUI)
			{
				displayedFighterId = fighterId;
				
				uiApi.loadUi(containerUIName, containerUIInstanceName);
			}
			else
			{
				if (fighterId == displayedFighterId)
					uiApi.unloadUi(containerUIInstanceName);
				else
				{
					displayedFighterId = fighterId;
					
					if (fightersAutoUpdate[displayedFighterId] || fightersDisplayedTurn[displayedFighterId] == undefined)
					{
						requestAutoUpdate();
						return;
					}
					
					requestUpdateSpells(fightersDisplayedTurn[displayedFighterId]);
				}
			}
		}
		
		/**
		 * This callback is process when the UiLoaded hook is raised. Update
		 * the splell's buttons.
		 *
		 * @param	instanceName	Instance's name of the loaded ui.
		 */
		private function onUiLoaded(instanceName:String):void
		{
			if (instanceName == containerUIInstanceName)
			{
				if (fightersAutoUpdate[displayedFighterId] || fightersDisplayedTurn[displayedFighterId] == undefined)
				{
					requestAutoUpdate();
					return;
				}
				
				requestUpdateSpells(fightersDisplayedTurn[displayedFighterId]);
			}
		}
		
		/**
		 * This callback is process when the GameFightEnd's hook is raised.
		 * Unload the main ui.
		 *
		 * @param	params	(not used).
		 */
		private function onGameFightEnd(params:Object):void
		{
			initGlobals();
			
			closeSpellWindows()
			
			uiApi.unloadUi(containerUIInstanceName);
		}
		
		
		private function onGameFightTurnStart(fighterId:int, waitTime:int, displayImage:Boolean):void
		{
			currentFighterId = fighterId;
			fightersLastPlayedTurn[fighterId] = fightApi.getTurnsCount();
			
			if (currentFighterId == displayedFighterId && fightersAutoUpdate[fighterId])
			{
				requestAutoUpdate();
			}
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Debug
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Wrapper for sysApi.log(2, ...).
		 *
		 * @param	object	The current object to display in the console.
		 */
		public function traceDofus(object:*):void
		{
			sysApi.log(2, object);
		}
		
		/**
		 * Display the spell list (sysApi.log).
		 */
		public function traceSpellList():void
		{
			traceDofus("***** Trace SpellList *****");
			for (var key1:String in spellList)
			{
				traceDofus("	SpellList du combatant : " + key1);
				for (var key2:String in spellList[key1])
				{
					traceDofus("		SpellList pour le tour " + key2 + ": " + spellList[key1][key2]);
				}
			}
		}
	}
}
