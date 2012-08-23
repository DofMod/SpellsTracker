package ui
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Label;
	import d2components.Texture;
	import d2enums.ComponentHookList;
	import types.SpellData;
	
	/**
	 * The main conainer UI of the module. Display and track several spell's
	 * button UI.
	 *
	 * @author Relena
	 */
	public class SpellButtonContainer
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// APIs
		/**
		 * @private
		 *
		 * log
		 */
		public var sysApi:SystemApi;
		/**
		 * @private
		 *
		 * addComponentHook, loadUiInside, unloadUi
		 */
		public var uiApi:UiApi;
		
		// Conponents
		public var btn_lastTurn:ButtonContainer;
		public var btn_minimize:ButtonContainer;
		public var btn_nextTurn:ButtonContainer;
		public var btn_previousTurn:ButtonContainer;
		public var ctn_buttons:GraphicContainer;
		public var ctn_concealable:GraphicContainer;
		public var lbl_turn:Label;
		public var tx_background:Texture;
		
		[Module(name="SpellsTracker")]
		/**
		 * @private
		 *
		 * SpellsTracker module reference.
		 */
		public var modSpellsTraker:Object;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Methods
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * Initialize the ui.
		 *
		 * @param	params	(not used)
		 */
		public function main(params:Object):void
		{
			uiApi.addComponentHook(btn_minimize, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_previousTurn, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_nextTurn, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_lastTurn, ComponentHookList.ON_RELEASE);
			
			uiApi.addComponentHook(btn_minimize, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_previousTurn, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_nextTurn, ComponentHookList.ON_ROLL_OVER);
			uiApi.addComponentHook(btn_lastTurn, ComponentHookList.ON_ROLL_OVER);
			
			uiApi.addComponentHook(btn_minimize, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(btn_previousTurn, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(btn_nextTurn, ComponentHookList.ON_ROLL_OUT);
			uiApi.addComponentHook(btn_lastTurn, ComponentHookList.ON_ROLL_OUT);
		}
		
		/**
		 * Display the turn <code>turn</code>.
		 *
		 * @param	turn	Turn number to display.
		 */
		public function displayTurn(turn:int):void
		{
			lbl_turn.text = turn.toString();
		}
		
		/**
		 * Get the current turn displayed.
		 *
		 * @return	The current turn displayed.
		 */
		private function getTurn():int
		{
			return parseInt(lbl_turn.text);
		}
		
		/**
		 * Return the buttons container.
		 * 
		 * @return	The button container.
		 */
		public function getSpellButtonContainer():GraphicContainer
		{
			return ctn_buttons;
		}
		
		/**
		 * Return the background component.
		 * 
		 * @return	The background component.
		 */
		public function getBackground():Texture
		{
			return tx_background;
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		/**
		 * This callback is process when the button conmponent is released.
		 * Actualy we can show/hide the button's list, or request the displaying
		 * of the next or previous spell's list.
		 *
		 * @private
		 *
		 * @param	target	Button compoment released.
		 */
		public function onRelease(target:Object):void
		{
			if (target == btn_minimize)
			{
				ctn_concealable.visible = (!btn_minimize.selected);
			}
			else if (target == btn_nextTurn)
			{
				modSpellsTraker.requestUpdateSpells(getTurn() + 1);
			}
			else if (target == btn_previousTurn)
			{
				modSpellsTraker.requestUpdateSpells(getTurn() - 1);
			}
			else if (target == btn_lastTurn)
			{
				modSpellsTraker.requestAutoUpdate();
			}
		}
		
		/**
		 * This callback is process when mouse roll over the button. Display
		 * tooltip informations.
		 *
		 * @private
		 *
		 * @param	target	Button compoment.
		 */
		public function onRollOver(target:Object):void
		{
			if (target == btn_minimize)
			{
				if (ctn_concealable.visible)
					uiApi.showTooltip("Cacher les informations de suivi", target);	
				else
					uiApi.showTooltip("Afficher les informations de suivi", target);
			}
			else if (target == btn_nextTurn)
			{
				uiApi.showTooltip("Afficher les informations du tour suivant", target);
			}
			else if (target == btn_previousTurn)
			{
				uiApi.showTooltip("Afficher les informations du tour précédant", target);
			}
			else if (target == btn_lastTurn)
			{
				uiApi.showTooltip("Afficher les informations du dernier tour", target);
			}
		}
		
		/**
		 * This callback is process when mouse roll out the button. Hide the
		 * tooltips.
		 * 
		 * @private
		 * 
		 * @param	target	Button compoment.
		 */
		public function onRollOut(target:Object):void
		{
			if (target == btn_minimize || target == btn_nextTurn || target == btn_previousTurn || target == btn_lastTurn)
			{
				uiApi.hideTooltip();
			}
		}
	}
}
