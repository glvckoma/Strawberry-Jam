package masterpiece
{
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import gui.GuiSoundButton;
   import loader.MasterpieceDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MasterpieceDisplayItem extends MovieClip
   {
      private static var _frameIds:Array;
      
      private const MASTERPIECE_FRAME_LIST_ID:int = 424;
      
      private var _currDenItem:DenItem;
      
      private var _invId:int;
      
      private var _versionId:int;
      
      private var _uniqueImageId:String;
      
      private var _uniqueImageCreator:String;
      
      private var _uniqueImageCreatorDbId:int;
      
      private var _uniqueImageCreatorUUID:String;
      
      private var _onLoadedCallback:Function;
      
      private var _passback:Object;
      
      private var _frame:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _masterpieceDefHelper:MasterpieceDefHelper;
      
      private var _isAlive:Boolean;
      
      private var _hasLoaded:Boolean;
      
      private var _namebarVisibility:Boolean;
      
      private var _originalWidth:Number;
      
      private var _originalHeight:Number;
      
      public function MasterpieceDisplayItem()
      {
         super();
      }
      
      public function init(param1:DenItem, param2:Function, param3:Object = null) : void
      {
         _currDenItem = param1;
         _invId = param1.invIdx;
         _versionId = param1.version;
         _uniqueImageId = param1.uniqueImageId;
         _namebarVisibility = true;
         if(param1.uniqueImageCreator.charAt(0) == "#")
         {
            _uniqueImageCreator = LocalizationManager.translateIdOnly(int(param1.uniqueImageCreator.substr(1)));
         }
         else
         {
            _uniqueImageCreator = param1.uniqueImageCreator;
         }
         _uniqueImageCreatorDbId = param1.uniqueImageCreatorDbId;
         _uniqueImageCreatorUUID = param1.uniqueImageCreatorUUID;
         _onLoadedCallback = param2;
         _passback = param3;
         _isAlive = true;
         _hasLoaded = false;
         if(_frameIds == null)
         {
            GenericListXtCommManager.requestGenericList(424,onMasterpieceFrameItemsLoaded);
         }
         else
         {
            loadFrameAndImage();
         }
      }
      
      public function initFromPool(param1:Object, param2:Function, param3:Object = null) : void
      {
         _invId = 0;
         _versionId = param1.frameId;
         _uniqueImageId = param1.resourceId;
         _namebarVisibility = true;
         if(param1.userName)
         {
            if(param1.userName.charAt(0) == "#")
            {
               _uniqueImageCreator = LocalizationManager.translateIdOnly(int(param1.userName.substr(1)));
            }
            else
            {
               _uniqueImageCreator = param1.userName;
            }
         }
         else
         {
            _uniqueImageCreator = "";
         }
         _uniqueImageCreatorDbId = param1.creatorDBId;
         _uniqueImageCreatorUUID = param1.creatorId;
         _onLoadedCallback = param2;
         _passback = param3;
         _isAlive = true;
         _hasLoaded = false;
         if(_frameIds == null)
         {
            GenericListXtCommManager.requestGenericList(424,onMasterpieceFrameItemsLoaded);
         }
         else
         {
            loadFrameAndImage();
         }
      }
      
      public function destroy() : void
      {
         _onLoadedCallback = null;
         _isAlive = false;
         _hasLoaded = false;
      }
      
      public function set onLoadedCallback(param1:Function) : void
      {
         _onLoadedCallback = param1;
      }
      
      public function get invId() : int
      {
         return _invId;
      }
      
      public function get versionId() : int
      {
         return _versionId;
      }
      
      public function get uniqueImageId() : String
      {
         return _uniqueImageId;
      }
      
      public function get uniqueImageCreator() : String
      {
         return _uniqueImageCreator;
      }
      
      public function get uniqueImageCreatorDbId() : int
      {
         return _uniqueImageCreatorDbId;
      }
      
      public function get uniqueImageCreatorUUID() : String
      {
         return _uniqueImageCreatorUUID;
      }
      
      public function get hasLoaded() : Boolean
      {
         return _hasLoaded;
      }
      
      public function set nameBarVisibility(param1:Boolean) : void
      {
         _namebarVisibility = param1;
         if(_frame)
         {
            if(param1 && _uniqueImageCreator != "" && _uniqueImageId != "")
            {
               _frame.nameBar.visible = true;
            }
            else
            {
               _frame.nameBar.visible = false;
            }
         }
      }
      
      public function clone(param1:Function) : MasterpieceDisplayItem
      {
         var _loc2_:MasterpieceDisplayItem = new MasterpieceDisplayItem();
         _loc2_.init(_currDenItem,param1);
         return _loc2_;
      }
      
      private function onMasterpieceFrameItemsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _frameIds = param2;
         loadFrameAndImage();
      }
      
      private function loadFrameAndImage() : void
      {
         if(_isAlive)
         {
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_frameIds[_versionId],onFrameLoaded);
         }
      }
      
      private function onFrameLoaded(param1:MovieClip) : void
      {
         if(_isAlive)
         {
            _frame = param1.getChildAt(0) as MovieClip;
            addChild(_frame);
            _originalWidth = this.width;
            _originalHeight = this.height;
            if(_uniqueImageCreator != "" && _uniqueImageId != "")
            {
               (_frame.nameBar as GuiSoundButton).setTextInLayer(_uniqueImageCreator,"name_txt");
               _frame.nameBar.mouseChildren = false;
               _frame.nameBar.mouseEnabled = false;
               _frame.nameBar.visible = _namebarVisibility;
            }
            else
            {
               _frame.nameBar.visible = false;
            }
            _frame.report_btn.visible = false;
            _frame.likeBtn.visible = false;
            if(_mediaHelper)
            {
               _mediaHelper.destroy();
               _mediaHelper = null;
            }
            if(_uniqueImageId != "")
            {
               _masterpieceDefHelper = new MasterpieceDefHelper();
               _masterpieceDefHelper.init(_uniqueImageId,onUniqueImageIdLoaded);
            }
            else if(_onLoadedCallback != null)
            {
               _onLoadedCallback(this,_passback);
               _hasLoaded = true;
            }
         }
      }
      
      private function onUniqueImageIdLoaded(param1:Sprite) : void
      {
         var _loc2_:Number = NaN;
         if(_masterpieceDefHelper)
         {
            _masterpieceDefHelper.destroy();
            _masterpieceDefHelper = null;
         }
         this.width = _originalWidth;
         this.height = _originalHeight;
         if(_frame)
         {
            _loc2_ = _frame.itemWindow.width / Math.max(param1.width,param1.height);
            param1.scaleX = param1.scaleY = _loc2_;
            param1.x = -param1.width * 0.5;
            param1.y = -param1.height * 0.5;
            _frame.itemWindow.addChild(param1);
         }
         if(_onLoadedCallback != null)
         {
            _onLoadedCallback(this,_passback);
            _hasLoaded = true;
         }
      }
   }
}

