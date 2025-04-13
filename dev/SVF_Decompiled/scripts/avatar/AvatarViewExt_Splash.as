package avatar
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class AvatarViewExt_Splash
   {
      private static const SHADOW_X_OFFSET:int = -100;
      
      private static const SHADOW_Y_OFFSET:int = -20;
      
      private static const Shadow:Class = Shadow_png$1df963b087c9c7239527ec2ed626ea3e1163450447;
      
      private static const WaterSplashSWF:Class = WaterSplash_swf$d6c2db4bff6ebed1f7d66de2e03d1ee2308143425;
      
      private const _constSplash:ByteArray = new WaterSplashSWF();
      
      private var _mask:Shape;
      
      private var _shadow:Bitmap;
      
      private var _splash:Loader;
      
      private var _parent:Sprite;
      
      private var _maskLayer:DisplayObject;
      
      private var _bLastSplashVolume:Boolean;
      
      private var _bSplashInProgress:Boolean;
      
      private var _lastSplashLiquid:String;
      
      private var _shadowChildIndex:int;
      
      public function AvatarViewExt_Splash(param1:Sprite, param2:DisplayObject)
      {
         super();
         _parent = param1;
         _bSplashInProgress = false;
         _bLastSplashVolume = false;
         createShadow();
         createMask(param2);
         _parent.addChild(param2);
         createSplash();
      }
      
      public function destroy() : void
      {
         if(_shadow && _shadow.parent != null)
         {
            _shadow.parent.removeChild(_shadow);
            _shadow = null;
         }
         if(_splash)
         {
            _parent.removeChild(_splash);
            _splash.unloadAndStop();
            _splash = null;
         }
         if(_mask)
         {
            _parent.removeChild(_mask);
            _mask = null;
         }
      }
      
      public function showShadow(param1:Boolean = true) : void
      {
         _shadow.visible = param1;
      }
      
      private function createShadow() : void
      {
         _shadow = new Shadow();
         _shadow.x = -100;
         _shadow.y = -20;
         _parent.addChild(_shadow);
      }
      
      private function createMask(param1:DisplayObject) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         _maskLayer = param1;
         _mask = new Shape();
         _parent.addChild(_mask);
         _mask.graphics.lineStyle();
         _mask.graphics.beginFill(16777215,1);
         _loc2_ = -250;
         _loc3_ = -475;
         _mask.graphics.moveTo(_loc2_,_loc3_);
         _mask.graphics.lineTo(_loc2_ + 445,_loc3_);
         _mask.graphics.lineTo(_loc2_ + 445,_loc3_ + 435);
         _mask.graphics.curveTo(_loc2_ + 222.5,_loc3_ + 460,_loc2_,_loc3_ + 435);
         _mask.graphics.lineTo(_loc2_,_loc3_);
         _mask.graphics.endFill();
         _maskLayer.mask = null;
         _mask.visible = false;
      }
      
      private function createSplash() : void
      {
         _splash = new Loader();
         var _loc1_:LoaderContext = new LoaderContext();
         _loc1_.allowCodeImport = true;
         _splash.loadBytes(_constSplash,_loc1_);
         _splash.x = -18;
         _splash.y = -28;
         _parent.addChild(_splash);
         _splash.visible = false;
      }
      
      public function flipSplash(param1:Boolean) : void
      {
         var _loc2_:Matrix = _shadow.transform.matrix;
         if(param1)
         {
            if(_loc2_.a != -1)
            {
               _loc2_.scale(-1,1);
               _shadow.transform.matrix = _loc2_;
               _loc2_ = _splash.content.transform.matrix;
               _loc2_.scale(-1,1);
               _splash.content.transform.matrix = _loc2_;
            }
         }
         else if(_loc2_.a == -1)
         {
            _loc2_.scale(-1,1);
            _shadow.transform.matrix = _loc2_;
            _loc2_ = _splash.content.transform.matrix;
            _loc2_.scale(-1,1);
            _splash.content.transform.matrix = _loc2_;
         }
      }
      
      public function heartbeat(param1:Boolean, param2:Boolean, param3:String, param4:Boolean) : void
      {
         if(_shadow)
         {
            if(param4)
            {
               if(_shadow.parent != null)
               {
                  _shadowChildIndex = _shadow.parent.getChildIndex(_shadow);
                  _shadow.parent.removeChild(_shadow);
               }
            }
            else if(_shadow.parent == null)
            {
               _parent.addChildAt(_shadow,_shadowChildIndex);
            }
         }
         var _loc5_:MovieClip = MovieClip(_splash.content);
         if(_loc5_)
         {
            if(param3 == "ice" || param3 == "fire" || param3 == "ghost")
            {
               param1 = false;
            }
            if(param1)
            {
               _loc5_.setState(param2 ? 1 : 2);
            }
            else if(_loc5_.currentFrame == 1 && _splash.visible == true)
            {
               _splash.visible = false;
            }
            if(param1 != _bLastSplashVolume || param3 != _lastSplashLiquid)
            {
               _loc5_.setLiquid(param3);
               _bLastSplashVolume = param1;
               _lastSplashLiquid = param3;
               showMask(param3 == "fallleaves" ? false : param1);
               if(param1)
               {
                  if(_splash.visible == false)
                  {
                     _splash.visible = true;
                  }
                  _loc5_.setState(param2 ? 1 : 2);
               }
               else
               {
                  _loc5_.setState(0);
               }
            }
         }
      }
      
      private function showMask(param1:Boolean = true) : void
      {
         if(param1)
         {
            _maskLayer.mask = _mask;
            showShadow(false);
         }
         else
         {
            _maskLayer.mask = null;
            showShadow(true);
         }
      }
   }
}

