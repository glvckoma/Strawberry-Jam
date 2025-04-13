package giftPopup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import gui.DarkenManager;
   import inventory.Iitem;
   import loader.MediaHelper;
   
   public class ReferAFriendGiftPopup extends GiftPopup
   {
      private const GIFT_POPUP_ID:int = 7162;
      
      public function ReferAFriendGiftPopup()
      {
         super();
      }
      
      override public function init(param1:DisplayObjectContainer, param2:Sprite, param3:String, param4:int, param5:int, param6:int, param7:Function = null, param8:Function = null, param9:Function = null, param10:Boolean = false, param11:int = 0, param12:int = 0, param13:String = null, param14:String = null, param15:Array = null, param16:Boolean = false, param17:Iitem = null) : void
      {
         _guiLayer = param1;
         _item = param17;
         if(_item != null)
         {
            _icon = param17.icon;
         }
         else
         {
            _icon = param2;
         }
         _name = param3;
         _enviroType = param12;
         _denyForNonMem = param10;
         _buttonsType = param11;
         _onCloseMsg = param13;
         _giftDefIdOrAmount = param4 == 0 ? param3 : String(param4);
         super.translateNonItemNameForTracking();
         _popupType = param5;
         _giftType = param6;
         _keepCallback = param7;
         _rejectCallback = param8;
         _closeCallback = param9;
         _msgText = param14;
         _giftDataArray = param15;
         _isFromStartup = param16;
         _itemColorIndex = -1;
         DarkenManager.showLoadingSpiral(true);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(7162,onMediaItemLoaded);
      }
      
      override protected function onMediaItemLoaded(param1:MovieClip, param2:int = 1) : void
      {
         super.onMediaItemLoaded(param1,param2);
         _popupContent.buttons.visible = true;
      }
   }
}

