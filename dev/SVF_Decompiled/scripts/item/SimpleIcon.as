package item
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.ImageArrayHelper;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   
   public class SimpleIcon
   {
      public static const GLOBAL_ANIM_FPS:int = 24;
      
      public static const THROTTLE_FRAME_UPDATES:int = 4;
      
      public static const ANIM_ICON:int = 18;
      
      public static const AN_ICON_L:int = 25;
      
      public static const AN_ICON_S:int = 26;
      
      private var _bitmap:LayerBitmap;
      
      private var _color:uint;
      
      private var _accId:int;
      
      private var _avatarType:int;
      
      private var _currImageData:Object;
      
      private var _hflip:Boolean;
      
      private var _callBack:Function;
      
      private var _expectingNewData:uint;
      
      private var _anIconId:int;
      
      public function SimpleIcon()
      {
         super();
      }
      
      public function init(param1:uint, param2:int, param3:int, param4:Boolean = false, param5:Boolean = false, param6:Function = null) : void
      {
         _bitmap = new LayerBitmap();
         _color = param1;
         _accId = param2;
         _hflip = param5;
         _callBack = param6;
         _avatarType = param3;
         _anIconId = param4 ? 25 : 26;
         _expectingNewData = 4294967295;
         _currImageData = null;
         ImageServerURL.instance.addEventListener("OnNewData",handleIconData,false,0,true);
         paint();
      }
      
      public function destroy() : void
      {
         ImageServerURL.instance.removeEventListener("OnNewData",handleIconData);
         _bitmap.destroy();
         _bitmap = null;
      }
      
      public function paint() : void
      {
         _expectingNewData = ImageArrayHelper.packId(_avatarType,_anIconId,_accId);
         ImageServerURL.instance.requestImage(_expectingNewData);
      }
      
      public function updateLayerColor(param1:int, param2:uint) : void
      {
         _bitmap.setLayerColor(param1,param2);
         _bitmap.paint(0);
      }
      
      public function get iconBitmap() : LayerBitmap
      {
         return _bitmap;
      }
      
      private function handleIconData(param1:ImageServerEvent) : void
      {
         if(param1.id != _expectingNewData)
         {
            return;
         }
         ImageServerURL.instance.removeEventListener("OnNewData",handleIconData);
         if(param1.success)
         {
            _currImageData = param1.imageData;
            _bitmap.setLayer(param1.layer,_currImageData,_color,String(param1.id));
            _expectingNewData = 4294967295;
            drawFrame();
         }
         else
         {
            handleCallback();
         }
      }
      
      private function drawFrame() : void
      {
         if(!_currImageData || _currImageData.length == 0)
         {
            DebugUtility.debugTrace("Icon skipping drawFrame due to invalid _currImageData:" + _currImageData + " _currImageData.length:" + _currImageData.length);
            return;
         }
         _bitmap.paint(0,_hflip);
         handleCallback();
      }
      
      private function handleCallback() : void
      {
         if(_callBack != null)
         {
            _callBack();
            _callBack = null;
         }
      }
   }
}

