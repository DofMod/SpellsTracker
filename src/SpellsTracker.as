package
{
	import d2api.ConfigApi;
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2enums.FightEventEnum;
	import d2hooks.FighterSelected;
	import d2hooks.FightEvent;
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightLeave;
	import flash.display.Sprite;
	import helpers.PlayedTurnTracker;
	import hooks.SpellsTrackerGameFightTurnStart;
	import managers.interfaces.SpellButtonManager;
	import managers.SpellButtonManagerImp;
	import types.SpellData;
	import ui.SpellButton;
	import ui.SpellButtonContainer;
	import ui.SpellsTrackerConfig;
	
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
		private var includes:Array = [SpellButtonContainer, SpellButton, SpellsTrackerConfig];
		
		// APIs
		/**
		 * @private
		 *
		 * ?
		 */
		public var configApi:ConfigApi;
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
		[Module(name="Ankama_Common")]
		/**
		 * Module Ankama_Common reference.
		 *
		 * @private
		 */
		public var modCommon:Object;
		
		// Dependencies
		private var spellButtonManager:SpellButtonManager;
		private var playedTurnTracker:PlayedTurnTracker;
		
		// Divers
		private var displayedFighterId:int;
		private var fightersDisplayedTurn:Array;
		private var fightersAutoUpdate:Array;
		private var spellList:Array;
		
		private var maxDisplayedTurn:int;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 *
		 * Initialize the module.
		 */
		public function main():void
		{
			initApis();
			initDependencies();
			initGlobals();
			reloadConfig();
			
			sysApi.addHook(FighterSelected, onFighterSelected);
			sysApi.addHook(FightEvent, onFightEvent);
			sysApi.addHook(GameFightEnd, onGameFightEnd);
			sysApi.addHook(GameFightLeave, onGameFightLeave);
			sysApi.addHook(SpellsTrackerGameFightTurnStart, onGameFightTurnStart);
			
			modCommon.addOptionItem("module_spellstracker", "(M) Spells Tracker", "Ces options servent à configurer le module SpellsTracker", "SpellsTracker::SpellsTrackerConfig");
		}
		
		/**
		 * Initialize the Api class.
		 */
		private function initApis():void
		{
			Api.config = configApi;
			Api.fight = fightApi;
			Api.system = sysApi;
			Api.ui = uiApi;
		}
		
		/**
		 * Initialize dependencies.
		 */
		private function initDependencies():void
		{
			playedTurnTracker = new PlayedTurnTracker();
			spellButtonManager = new SpellButtonManagerImp();
		}
		
		/**
		 * Reset the globals
		 */
		private function initGlobals():void
		{
			displayedFighterId = 0;
			fightersDisplayedTurn = new Array();
			fightersAutoUpdate = new Array();
			spellList = new Array();
		}
		
		/**
		 * @private
		 *
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
		 * all the turns of all the fighters. Else, if <code>turn == -1</code>,
		 * return the spell's list of all the turns of the fighter
		 * <code>fighterId</code>. Else, if <code>castId == -1</code>, return
		 * the spell's list of the fighter <code>fighterId</code> of the turn
		 * <code>turn</code>. Else, return the spell's data of the fighter
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
		 * Select the right turn, and display the spell's list of this turn.
		 *
		 * @param	turn	Turn of the spell's list to display.
		 */
		private function updateSpells(turn:int):void
		{
			var spellListArray:Array = new Array();
			var spellListArraySize:int = (turn < maxDisplayedTurn) ? turn : maxDisplayedTurn;
			for (var ii:int = 0; ii < spellListArraySize; ii++)
			{
				spellListArray.push(getSpellData(displayedFighterId, turn - ii));
			}
			
			spellButtonManager.updateSpellButtons(spellListArray, spellListArraySize, turn);
		}
		
		/**
		 * Request the displaying of the spell's list og the turn
		 * <code>turn</code> of the current displayed fighter.
		 *
		 * @param	turn	Turn of the spell's list to display. Must be between
		 * 1 and the last played turn.
		 */
		public function requestUpdateSpells(turn:int):void
		{
			if (turn < 1)
				return;
			
			if (turn > playedTurnTracker.getLastTurnPlayed(displayedFighterId))
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
			var turn:int = playedTurnTracker.getLastTurnPlayed(displayedFighterId);
			
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
			if (spellData._fighterId != displayedFighterId)
				return;
			
			if (playedTurnTracker.getLastTurnPlayed(displayedFighterId) != fightersDisplayedTurn[displayedFighterId])
				return;
			
			if (!spellButtonManager.isInterfaceLoaded())
				return;
			
			spellButtonManager.addSpellButton(spellData);
		}
		
		private function uiLoadedCallback():void
		{
			if (fightersAutoUpdate[displayedFighterId] || fightersDisplayedTurn[displayedFighterId] == undefined)
			{
				requestAutoUpdate();
				return;
			}
			
			requestUpdateSpells(fightersDisplayedTurn[displayedFighterId]);
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
				spellData = new SpellData(params[0], params[5], fightApi.getTurnsCount(), SpellData.SPELL_TYPE_SPELL, params[3], params[4], params[1], params[2]);
				
				trackSpellData(spellData);
				
				tryDisplaySpellData(spellData);
			}
			else if (eventName == FightEventEnum.FIGHTER_CLOSE_COMBAT)
			{
				spellData = new SpellData(params[0], params[2], fightApi.getTurnsCount(), SpellData.SPELL_TYPE_WEAPON, params[1]);
				
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
			if (!spellButtonManager.isInterfaceLoaded())
			{
				displayedFighterId = fighterId;
				
				spellButtonManager.loadInterface(uiLoadedCallback);
			}
			else
			{
				if (fighterId == displayedFighterId)
				{
					spellButtonManager.unloadInterface();
				}
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
		 * This callback is process when the GameFightEnd's hook is raised.
		 * Unload the main ui.
		 *
		 * @param	params	(not used).
		 */
		private function onGameFightEnd(params:Object):void
		{
			initGlobals();
			
			if (spellButtonManager.isInterfaceLoaded())
			{
				spellButtonManager.unloadInterface();
			}
		}
		
		/**
		 * This callback is process when the GameFightLeave hook is dispatched.
		 * Unload the main ui.
		 *
		 * @param	fighterId	Identifier of the fighter
		 */
		private function onGameFightLeave(fighterId:int):void
		{
			if (fighterId == fightApi.getCurrentPlayedFighterId())
			{
				initGlobals();
				
				if (spellButtonManager.isInterfaceLoaded())
				{
					spellButtonManager.unloadInterface();
				}
			}
		}
		
		/**
		 * This callback is process when the SpellsTrackerGameFightTurnStart
		 * hook is dispatched. Request the update of the displayed spell list
		 * if the auto update mode is enable.
		 *
		 * @param	fighterId	Identifier of the fighter who start his turn.
		 */
		private function onGameFightTurnStart(fighterId:int):void
		{
			if (fighterId == displayedFighterId && fightersAutoUpdate[fighterId])
			{
				requestAutoUpdate();
			}
		}
	}
}
