package achievement
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class Achievement
   {
      public static var GEMS_EARNED:int = 1;
      
      public static var GEMS_SPENT:int = 2;
      
      public static var SHOP_DEN_ITEM:int = 3;
      
      public static var SHOP_ACCESSORY:int = 4;
      
      public static var MAIL_SEND:int = 38;
      
      public static var MAIL_GIFT:int = 39;
      
      public static var BUDDY_ADDED:int = 40;
      
      public static var MEMBER_NEW:int = 66;
      
      public static var HOLIDAY_BANNER:int = 409;
      
      public static var BASE_MEDAL_ID:int = 289;
      
      public static var BASE_RIBBON_ID:int = 290;
      
      public static var BASE_TROPHY_ID:int = 291;
      
      private var _invId:int;
      
      private var _baseImageMediaId:int;
      
      private var _iconMediaId:int;
      
      private var _name:String;
      
      private var _descr:String;
      
      private var _mediaText:String;
      
      private var _nameId:int;
      
      private var _descId:int;
      
      private var _type:int;
      
      private var _defId:int;
      
      private var _userVarId:int;
      
      private var _baseImage:Sprite;
      
      private var _baseImageHelper:MediaHelper;
      
      private var _icon:Sprite;
      
      private var _iconHelper:MediaHelper;
      
      private var _baseImageReceived:Boolean;
      
      private var _iconReceived:Boolean;
      
      private var _shouldUseFullScale:Boolean;
      
      private var _scalePercent:Number = 1;
      
      private var _xPos:Number = 0;
      
      private var _yPos:Number = 0;
      
      public function Achievement()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:Boolean = false) : void
      {
         var _loc4_:Array = null;
         _invId = param1;
         _defId = param2;
         var _loc5_:Object = AchievementManager.getAchievementDef(_defId);
         if(_loc5_)
         {
            _userVarId = _loc5_.userVarRef;
            _baseImageMediaId = _loc5_.baseMediaRef;
            _iconMediaId = _loc5_.iconMediaRef;
            _nameId = _loc5_.titleStrRef;
            _name = LocalizationManager.translateIdOnly(_nameId);
            _mediaText = _loc5_.extraText;
            if(_mediaText != "")
            {
               _loc4_ = _mediaText.split(",");
               if(_loc4_.length > 1)
               {
                  _mediaText = Utility.convertNumberToString(int(_loc4_.join("")));
               }
            }
            _descId = _loc5_.descStrRef;
            _descr = LocalizationManager.translateIdOnly(_descId);
            _type = _loc5_.type;
            _shouldUseFullScale = param3;
            _baseImage = new Sprite();
            _baseImageHelper = new MediaHelper();
            _baseImageHelper.init(_baseImageMediaId,baseImageReceived);
            _icon = new Sprite();
            _iconHelper = new MediaHelper();
            _iconHelper.init(_iconMediaId,iconReceived);
            return;
         }
         throw new Error("Could not find achievement def");
      }
      
      public function destroy() : void
      {
         if(_iconHelper)
         {
            _iconHelper.destroy();
         }
         if(_baseImageHelper)
         {
            _baseImageHelper.destroy();
         }
      }
      
      public function clone() : Achievement
      {
         var _loc1_:Achievement = null;
         _loc1_ = new Achievement();
         _loc1_.init(_invId,_defId,_shouldUseFullScale);
         return _loc1_;
      }
      
      public function setScale(param1:Number) : void
      {
         _scalePercent = param1;
         if(_iconReceived && _baseImageReceived)
         {
            _baseImage.scaleX = _scalePercent;
            _baseImage.scaleY = _scalePercent;
         }
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         _xPos = param1;
         _yPos = param2;
         if(_iconReceived && _baseImageReceived)
         {
            _baseImage.x = -_baseImage.width * _xPos;
            _baseImage.y = -_baseImage.height * _yPos;
         }
      }
      
      private function baseImageReceived(param1:MovieClip) : void
      {
         var _loc2_:Number = NaN;
         if(param1)
         {
            param1 = MovieClip(param1.getChildAt(0));
            _baseImage.addChild(param1);
            if(_iconReceived)
            {
               param1.itemBlock.addChild(_icon);
               allImagesLoaded();
            }
            if(_mediaText == "")
            {
               param1.num.visible = false;
            }
            else
            {
               param1.num.txt.text = _mediaText;
               _loc2_ = Number(param1.num.txt.textWidth);
               if(_loc2_ > 15)
               {
                  if(_loc2_ > 25)
                  {
                     param1.num.gotoAndStop(3);
                  }
                  else
                  {
                     param1.num.gotoAndStop(2);
                  }
               }
            }
            _baseImageHelper.destroy();
            _baseImageHelper = null;
            _baseImageReceived = true;
         }
      }
      
      private function iconReceived(param1:MovieClip) : void
      {
         if(param1)
         {
            _icon.addChild(param1);
            if(_baseImageReceived)
            {
               MovieClip(_baseImage.getChildAt(0)).itemBlock.addChild(_icon);
               allImagesLoaded();
            }
            _iconHelper.destroy();
            _iconHelper = null;
            _iconReceived = true;
         }
      }
      
      private function allImagesLoaded() : void
      {
         var _loc1_:Number = 0.9;
         if(_shouldUseFullScale)
         {
            _loc1_ = 1;
         }
         _baseImage.scaleX = _loc1_ * _scalePercent;
         _baseImage.scaleY = _loc1_ * _scalePercent;
         _baseImage.x = -_baseImage.width * _xPos;
         _baseImage.y = -_baseImage.height * _yPos;
      }
      
      public function get invId() : int
      {
         return _invId;
      }
      
      public function get baseImageMediaId() : int
      {
         return _baseImageMediaId;
      }
      
      public function get iconMediaId() : int
      {
         return _iconMediaId;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get descr() : String
      {
         return _descr;
      }
      
      public function get mediaText() : String
      {
         return _mediaText;
      }
      
      public function get image() : Sprite
      {
         return _baseImage;
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get userVarId() : int
      {
         return _userVarId;
      }
   }
}

