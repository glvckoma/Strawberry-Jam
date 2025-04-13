package game
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class MinigameInfo
   {
      public var gameDefId:uint;
      
      public var titleStrId:uint;
      
      public var extName:String;
      
      public var swfName:String;
      
      public var minPlayers:uint;
      
      public var maxPlayers:uint;
      
      public var maxSpectators:uint;
      
      public var type:uint;
      
      public var gameCardMediaId:uint;
      
      public var gameCountUserVarRef:uint;
      
      public var custom1UserVarRef:uint;
      
      public var custom2UserVarRef:uint;
      
      public var readyForPVP:Boolean;
      
      public var gemMultiplier:Number;
      
      public var petDefId:int;
      
      public var proModeUserVarRefId:int;
      
      public var lbUseVarRef:int;
      
      public var gameLibraryIconMediaId:int;
      
      public var requiredAvatarType:int;
      
      private var _gameCardScreen:MovieClip;
      
      private var _hasLoadedScreen:Boolean;
      
      public function MinigameInfo()
      {
         super();
      }
      
      public function init(param1:uint, param2:uint, param3:String, param4:String, param5:uint, param6:uint, param7:uint, param8:uint, param9:uint, param10:uint, param11:uint, param12:uint, param13:uint, param14:Number, param15:MovieClip, param16:int, param17:int, param18:int, param19:int, param20:int) : void
      {
         gameDefId = param1;
         titleStrId = param2;
         extName = param3;
         swfName = param4;
         minPlayers = param5;
         maxPlayers = param6;
         maxSpectators = param7;
         type = param8;
         gameCardMediaId = param9;
         gameCountUserVarRef = param10;
         custom1UserVarRef = param11;
         custom2UserVarRef = param12;
         readyForPVP = param13 != 0;
         gemMultiplier = param14;
         gameCardScreen = param15;
         petDefId = param16;
         proModeUserVarRefId = param17;
         lbUseVarRef = param18;
         gameLibraryIconMediaId = param19;
         requiredAvatarType = param20;
      }
      
      public function get isInRoomGame() : Boolean
      {
         return type == 0;
      }
      
      public function get gameCardScreen() : MovieClip
      {
         var _loc1_:MediaHelper = null;
         if(_hasLoadedScreen)
         {
            return _gameCardScreen;
         }
         _gameCardScreen = new MovieClip();
         _loc1_ = new MediaHelper();
         _loc1_.init(gameCardMediaId,onScreenLoaded);
         return _gameCardScreen;
      }
      
      public function set gameCardScreen(param1:MovieClip) : void
      {
         if(param1 != null)
         {
            _hasLoadedScreen = true;
         }
         _gameCardScreen = param1;
      }
      
      private function onScreenLoaded(param1:MovieClip) : void
      {
         _gameCardScreen.addChild(param1);
      }
   }
}

