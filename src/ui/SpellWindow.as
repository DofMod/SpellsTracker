package ui 
{
	import d2api.DataApi;
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Label;
	import d2components.Texture;
	import d2data.FighterInformations;
	import d2enums.ComponentHookList;
	import flash.geom.Rectangle;
	import helpers.PlayedTurnTracker;
	import managers.interfaces.SpellWindowManager;
	import types.CountdownData;
	import types.SpellWindowParams;
	/**
	 * ...
	 * @author Relena
	 */
	public class SpellWindow 
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// APIs
		/**
		 * @private
		 * 
		 * getFighterName
		 */
		public var fightApi:FightApi;
		/**
		 * @private
		 * 
		 * log
		 */
		public var sysApi:SystemApi;
		/**
		 * @private
		 * 
		 * ?
		 */
		public var uiApi:UiApi;
		/**
		 * @private
		 * 
		 * getSpellItem
		 */
		public var dataApi:DataApi;
		
		// Dependencies
		private var _spellWindowManager:SpellWindowManager;
		private var _playedTurnTracker:PlayedTurnTracker;
		
		// Conponents
		public var ctn_main:GraphicContainer;
		public var ctn_background:GraphicContainer;
		public var tx_spellIcon:Texture;
		public var lbl_spellName:Label;
		public var lbl_fighter:Label;
		public var lbl_countdown:Label;
		public var btn_quit:ButtonContainer;
		public var btn_expend:ButtonContainer;
		
		// Constants
		private const bannerHeight:int = 165;
		
		// Others
		private var _countdownData:CountdownData;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialise function, automatically call bye the core.
		 *
		 * @param	countdownData
		 */
		public function main(spellWindowParams:SpellWindowParams):void
		{
			_spellWindowManager = spellWindowParams.spellWindowManager;
			_playedTurnTracker = spellWindowParams.playedTurnTracker;
			_countdownData = spellWindowParams.countdownData;
			
			uiApi.addComponentHook(ctn_background, ComponentHookList.ON_PRESS);
			uiApi.addComponentHook(ctn_background, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(ctn_background, ComponentHookList.ON_RELEASE_OUTSIDE);
			
			uiApi.addComponentHook(btn_quit, ComponentHookList.ON_RELEASE);
			
			uiApi.addComponentHook(btn_expend, ComponentHookList.ON_RELEASE);
			
			var fighter:FighterInformations = fightApi.getFighterInformations(_countdownData._fighterId);
			if (fighter.team != "challenger")
			{
				lbl_fighter.cssClass = "opponent";
			}
			
			lbl_fighter.text = fightApi.getFighterName(_countdownData._fighterId);
			
			var spell:Object = dataApi.getSpellWrapper(_countdownData._spellId);
			
			tx_spellIcon.uri = spell.iconUri;
			lbl_spellName.text = spell.name;
			
			updateCountdown();
		}
		
		/**
		 * Cleanup function.
		 */
		public function unload():void
		{
		}
		
		/**
		 * Drag the current ui.
		 */
		private function dragUiStart() : void
		{
			ctn_main.startDrag(
				false,
				new Rectangle(
						-5,
						-5,
						uiApi.getStageWidth() - ctn_main.width,
						uiApi.getStageHeight() - ctn_main.height - bannerHeight)
				);
		}
		
		/**
		 * Drop the current ui.
		 */
		private function dragUiStop() : void
		{
			ctn_main.stopDrag();
		}
		
		public function getDisplayedFighterId():int
		{
			return _countdownData._fighterId;
		}
		
		/**
		 * Update the countdown label.
		 */
		public function updateCountdown():void
		{
			var lastTurn:int = _playedTurnTracker.getLastTurnPlayed(_countdownData._fighterId);
			var countdown:int = (_countdownData._start + _countdownData._countdown - 1) - lastTurn;
			
			if (_playedTurnTracker.getCurrentPlayingFighter() == _countdownData._fighterId && !_playedTurnTracker.isTurnDone())
				countdown += 1;
			
			countdown = (countdown > 0) ? countdown : 0;
			
			lbl_countdown.text = countdown.toString();
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 * 
		 * @param	target
		 */
		public function onPress(target:GraphicContainer):void
		{
			if (target == ctn_background)
			{
				dragUiStart();
			}
		}
		
		/**
		 * @private
		 * 
		 * @param	target
		 */
		public function onRelease(target:GraphicContainer):void
		{
			if (target == ctn_background)
			{
				dragUiStop();
			}
			else if (target == btn_quit)
			{
				_spellWindowManager.closeUi(uiApi.me().name);
			}
		}
		
		/**
		 * @private
		 * 
		 * @param	target
		 */
		public function onReleaseOutside(target:GraphicContainer):void
		{
			if (target == ctn_background)
			{
				dragUiStop();
			}
		}
	}
}