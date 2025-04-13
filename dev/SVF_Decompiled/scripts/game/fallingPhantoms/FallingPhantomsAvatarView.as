package game.fallingPhantoms
{
   import avatar.AvatarView;
   import avatar.AvatarViewExt_Splash;
   import flash.display.Shape;
   import flash.filters.GlowFilter;
   
   public class FallingPhantomsAvatarView extends AvatarView
   {
      private static const GLOW_LAND_DEFAULT_COLOR:int = 5586479;
      
      private static const GLOW_OCEAN_DEFAULT_COLOR:int = 2775381;
      
      private var _splash:AvatarViewExt_Splash;
      
      private var _glow:GlowFilter;
      
      public var _bInSplashVolume:Boolean;
      
      private var _splashLiquid:String;
      
      public var rectangle:Shape;
      
      public function FallingPhantomsAvatarView()
      {
         super();
      }
      
      public function InitFallingPhantomsAvatarView() : void
      {
      }
      
      public function setBlendColor(param1:uint = 0, param2:uint = 4294967295) : void
      {
      }
      
      public function toggleSplash(param1:Boolean, param2:String = null) : void
      {
      }
      
      public function heartbeat() : void
      {
      }
   }
}

