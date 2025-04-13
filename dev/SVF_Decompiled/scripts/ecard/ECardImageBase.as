package ecard
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import loader.MediaHelper;
   
   public class ECardImageBase
   {
      private var _mediaId:int;
      
      private var _img:MovieClip;
      
      private var _img2:MovieClip;
      
      private var _imgHelper:MediaHelper;
      
      private var _imgHelper2:MediaHelper;
      
      private var _onImageLoadedCallback:Function;
      
      public function ECardImageBase()
      {
         super();
      }
      
      public function init(param1:int, param2:Function = null) : void
      {
         _mediaId = param1;
         _onImageLoadedCallback = param2;
         _imgHelper = new MediaHelper();
         _imgHelper.init(_mediaId,imgReceived);
         _imgHelper2 = new MediaHelper();
         _imgHelper2.init(_mediaId,img2Received);
      }
      
      private function imgReceived(param1:MovieClip) : void
      {
         _img = param1.getChildAt(0) as MovieClip;
         _imgHelper.destroy();
         _imgHelper = null;
         if(_img2 && _onImageLoadedCallback != null)
         {
            _onImageLoadedCallback();
            _onImageLoadedCallback = null;
         }
      }
      
      private function img2Received(param1:MovieClip) : void
      {
         _img2 = param1.getChildAt(0) as MovieClip;
         _imgHelper2.destroy();
         _imgHelper2 = null;
         if(_img && _onImageLoadedCallback != null)
         {
            _onImageLoadedCallback();
            _onImageLoadedCallback = null;
         }
      }
      
      public function get img() : MovieClip
      {
         return _img;
      }
      
      public function get img2() : MovieClip
      {
         return _img2;
      }
      
      public function get mediaId() : int
      {
         return _mediaId;
      }
      
      public function get stamp() : MovieClip
      {
         return _img.stamp;
      }
      
      public function get msgTxt() : TextField
      {
         return _img.msgTxt;
      }
   }
}

