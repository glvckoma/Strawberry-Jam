package playerWall
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class StickerItem extends MovieClip
   {
      private var _sticker:MovieClip;
      
      private var _stickerMediaId:int;
      
      private var _onLoadedCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _passback:Object;
      
      public function StickerItem(param1:int, param2:Function, param3:Object = null)
      {
         super();
         _onLoadedCallback = param2;
         _passback = param3;
         _mediaHelper = new MediaHelper();
         _stickerMediaId = param1;
         _mediaHelper.init(param1,onStickerLoaded);
      }
      
      public function destroy() : void
      {
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
      }
      
      public function get mediaId() : int
      {
         return _stickerMediaId;
      }
      
      public function clone(param1:Function) : StickerItem
      {
         return new StickerItem(mediaId,param1);
      }
      
      private function onStickerLoaded(param1:MovieClip) : void
      {
         _sticker = MovieClip(param1.getChildAt(0));
         addChild(_sticker);
         if(_onLoadedCallback.length > 0)
         {
            if(_passback != null)
            {
               _onLoadedCallback(this,_passback);
            }
            else
            {
               _onLoadedCallback(this);
            }
         }
         else if(_passback != null)
         {
            _onLoadedCallback(_passback);
         }
         else
         {
            _onLoadedCallback();
         }
      }
   }
}

