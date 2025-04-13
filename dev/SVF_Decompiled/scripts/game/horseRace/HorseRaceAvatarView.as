package game.horseRace
{
   import avatar.AvatarView;
   import avatar.AvatarViewExt_Splash;
   import com.sbi.graphics.LayerBitmap;
   import flash.filters.GlowFilter;
   
   public class HorseRaceAvatarView extends AvatarView
   {
      private static const GLOW_LAND_DEFAULT_COLOR:int = 5586479;
      
      private static const GLOW_OCEAN_DEFAULT_COLOR:int = 2775381;
      
      private var _splash:AvatarViewExt_Splash;
      
      private var _glow:GlowFilter;
      
      public var _bInSplashVolume:Boolean;
      
      private var _splashLiquid:String;
      
      public function HorseRaceAvatarView()
      {
         super();
      }
      
      public function InitHorseRaceAvatarView() : void
      {
         _layerAnim.avDefId = 23;
         var _loc1_:LayerBitmap = _layerAnim.bitmap;
         _loc1_.x = 0;
         _loc1_.y = 0;
         _glow = new GlowFilter(0,1,4,4,4);
         _layerAnim.bitmap.filters = [_glow];
         setBlendColor();
         _splash = new AvatarViewExt_Splash(this,_layerAnim.bitmap);
         _bInSplashVolume = false;
      }
      
      public function setBlendColor(param1:uint = 0, param2:uint = 4294967295) : void
      {
         var _loc3_:Array = null;
         if(param2 == 4294967295)
         {
            if(param1 == 0)
            {
               param2 = 5586479;
            }
            else
            {
               param2 = uint(param1 & 0xFFFFFF);
            }
         }
         if(_layerAnim.bitmap.filters != null && _layerAnim.bitmap.filters[0].color != param2)
         {
            _loc3_ = _layerAnim.bitmap.filters;
            _loc3_[0].color = param2;
            _layerAnim.bitmap.filters = _loc3_;
         }
         _layerAnim.bitmap.setBlendColor(param1);
      }
      
      public function toggleSplash(param1:Boolean, param2:String = null) : void
      {
         _bInSplashVolume = param1;
         if(_bInSplashVolume)
         {
            _splashLiquid = param2;
         }
      }
      
      public function heartbeat() : void
      {
         _splash.heartbeat(_bInSplashVolume,true,_splashLiquid,false);
      }
   }
}

