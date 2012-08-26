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
	import managers.SpellWindowManager;
	import types.SpellData;
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
		
		// Conponents
		public var ctn_main:GraphicContainer;
		public var ctn_background:GraphicContainer;
		public var tx_spellIcon:Texture;
		public var lbl_spellName:Label;
		public var lbl_fighter:Label;
		public var lbl_cooldown:Label;
		public var btn_quit:ButtonContainer;
		public var btn_expend:ButtonContainer;
		
		// Constants
		private const bannerHeight:int = 165;
		
		// Others
		private var _spellData:SpellData;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialize the ui.
		 *
		 * @param	params	(not used)
		 */
		public function main(spellData:SpellData):void
		{
			uiApi.addComponentHook(ctn_background, ComponentHookList.ON_PRESS);
			uiApi.addComponentHook(ctn_background, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(ctn_background, ComponentHookList.ON_RELEASE_OUTSIDE);
			
			uiApi.addComponentHook(btn_quit, ComponentHookList.ON_RELEASE);
			
			uiApi.addComponentHook(btn_expend, ComponentHookList.ON_RELEASE);
			
			_spellData = spellData;
			
			var fighter:FighterInformations = fightApi.getFighterInformations(_spellData._fighterId);
			if (fighter.team != "challenger")
			{
				lbl_fighter.cssClass = "opponent";
			}
			
			lbl_fighter.text = fightApi.getFighterName(_spellData._fighterId);
			
			var spell:Object = dataApi.getSpellItem(_spellData._spellId, _spellData._spellRank);
			
			tx_spellIcon.uri = spell.iconUri;
			lbl_spellName.text = spell.name;
			
			updateCooldown();
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
						5,
						5,
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
			return _spellData._fighterId;
		}
		
		/**
		 * Update the cooldown label.
		 */
		public function updateCooldown():void
		{
			var turnTracker:PlayedTurnTracker = PlayedTurnTracker.getInstance();
			var spell:Object = dataApi.getSpellItem(_spellData._spellId, _spellData._spellRank);
			var lastTurn:int = turnTracker.getLastTurnPlayed(_spellData._fighterId);
			var cooldown:int = (_spellData._turn + spell.minCastInterval - 1) - lastTurn;
			
			if (turnTracker.getCurrentPlayingFighter() == _spellData._fighterId && !turnTracker.isTurnDone())
				cooldown += 1;
			
			cooldown = (cooldown > 0) ? cooldown : 0;
			
			lbl_cooldown.text = cooldown.toString();
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
				SpellWindowManager.getInstance().closeUi(uiApi.me().name);
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