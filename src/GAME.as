// ---------------------------------------
//	Team Miscreants
// ---------------------------------------

package {
	import Events.LOADING_EVENT;
	import Extended.*;
	import starling.events.*;
	import starling.utils.AssetManager;
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.text.TextField;
	import starling.text.BitmapFont;
	
	public class GAME extends DISPLAY {
		
		private var _Asset_Loader:AssetLoader;
		private var Assets:AssetManager;
		private var Config:XML;
		private var Math_Config:XML;
		private var Directory:String;
		
		
		
		private var Menu:MATCH_MENU_SCREEN;
		private var Game:MATCH_GAME_SCREEN;
		private var Win:MATCH_WIN_SCREEN;
		private var Info:MATCH_INFO_SCREEN;
		
		public static const EXIT_STATE:int = 0;
		public static const MENU_STATE:int = 1;
		public static const INFO_STATE:int = 2;
		public static const GAME_STATE:int = 3;
		public static const  WIN_STATE:int = 4;
		
		public static var Screen_State:int;
		public static var Has_State_Changed:Boolean;
		
		
		public function GAME(directory:String) 
		{
			Directory = directory + "/";
			_Asset_Loader = new AssetLoader(Directory, Asset_Loader_Handler);
			_Asset_Loader.Add_Directory(Directory);
			_Asset_Loader.Start();
			
		}

		private function Asset_Loader_Handler(ratio:Number):void 
		{
			var Loading_Event:LOADING_EVENT = new LOADING_EVENT(LOADING_EVENT.EVENT_LOADING_STATUS);
			Loading_Event.Percentage = ratio;
			dispatchEvent(Loading_Event);
			
			if(ratio < 1) return;
			Assets	= _Asset_Loader.Get_Assets();
			Config	= Assets.getXml("Game");
			Math_Config = Assets.getXml("Math");
			
			var inkyTexture:Texture = Assets.getTexture("InkyThinPixels_0");
			var inkyXML:XML = Assets.getXml("InkyThinPixels");
			var metalLordTexture:Texture = Assets.getTexture("MetalLord_0.png");
			var metalLordXML:XML = Assets.getXml("MetalLord.xml");
			var InkyThinPixels:BitmapFont = new BitmapFont(inkyTexture, inkyXML); 
			var MetalLord:BitmapFont = new BitmapFont(metalLordTexture, metalLordXML);
			TextField.registerCompositor(InkyThinPixels, "InkyThinPixels");
			TextField.registerCompositor(MetalLord, "MetalLord");
			
			Menu = new MATCH_MENU_SCREEN(Assets);
			Game = new MATCH_GAME_SCREEN(Assets);
			Win = new MATCH_WIN_SCREEN(Assets);
			Info = new MATCH_INFO_SCREEN(Assets);
			
			Add_Children([Game, Menu, Win, Info]);
			
			Screen_State = GAME.MENU_STATE;
			
			Set_State();
			
			this.addEventListener(Event.ENTER_FRAME, Update);
		}

		private function Update():void 
		{
			if (Has_State_Changed) 
			{
				Set_State();
				Has_State_Changed = false;
			}
			if (Screen_State == GAME.GAME_STATE && Game) 
			{
				Game.Update();
			}
			else if (Screen_State == GAME.WIN_STATE) 
			{
				Win.Update();
			}
		}
		
		public function Set_State():void 
		{
			if (Screen_State == GAME.EXIT_STATE) 
			{
				//Exit
			}
			else if (Screen_State == GAME.MENU_STATE) 
			{
				
				Menu.Background_Music.Play_Forever();
				//Menu Screen
				Game.Hide();
				Win.Hide();
				Menu.Show();
				Info.Hide();
			}
			else if (Screen_State == GAME.INFO_STATE) 
			{
				//Info Screen
				Info.Show();
				Game.Hide();
				Win.Hide();
				Menu.Hide();
			}
			else if (Screen_State == GAME.GAME_STATE) 
			{
				//Game Screen
				
				//Get predetermined winning tier from menu and pass it to game
				Game.Generate_Entity_Picks(Menu.Winning_Tier);
				Game.Set_Payouts(Menu.P1, Menu.P2, Menu.P3, Menu.P4);
				
				
				Menu.Background_Music.Stop();
				if(!Game.Background_Music.Playing)
					Game.Background_Music.Play_Forever();
				
				Menu.Hide();
				Win.Hide();
				Game.Show();
				Info.Hide();
			}
			else if (Screen_State == GAME.WIN_STATE) 
			{
				//Win Screen
				Win.Payout.Text = "You Win $" + Menu.Payout + "!";
				
				
				Game.Background_Music.Stop();
				Win.Background_Music.Play_Forever();
				
				Menu.Hide();
				Game.Hide();
				Win.Show();
				Info.Hide();
			}
		}
		
		public function get Asset_Loader():AssetLoader 
		{
			return _Asset_Loader;
		}
		
	}
}