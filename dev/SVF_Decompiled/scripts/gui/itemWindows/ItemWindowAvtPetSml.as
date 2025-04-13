package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import buddy.BuddyCard;
   import com.sbi.graphics.LayerAnim;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import pet.GuiPet;
   
   public class ItemWindowAvtPetSml extends ItemWindowBase
   {
      private var _isPet:Boolean;
      
      private var _ai:AvatarInfo;
      
      private var _isMember:Boolean;
      
      private var _nameBarData:int;
      
      private var _currFrameName:String;
      
      private var _avtView:AvatarView;
      
      private var _petView:GuiPet;
      
      private var _currPerUserAvId:int;
      
      private var _hasSetInitialConditions:Boolean;
      
      public function ItemWindowAvtPetSml(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _isPet = param9 != null ? param9.isPet : false;
         _isMember = param9 != null ? param9.isMember : false;
         _nameBarData = param9 != null ? param9.nameBarData : 0;
         if(!_isPet)
         {
            _ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param2.userName,param2.perUserAvId);
            _currPerUserAvId = param9.currPerUserAvId;
         }
         super("charBtnSmlCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get sel() : MovieClip
      {
         return _window.sel;
      }
      
      public function get isPet() : Boolean
      {
         return _isPet;
      }
      
      public function get charLayer() : MovieClip
      {
         return _window.charLayer;
      }
      
      public function get xpShape() : MovieClip
      {
         return _window.xpShape;
      }
      
      public function get toolTipName() : String
      {
         if(_isPet && _petView)
         {
            return _petView.petName;
         }
         if(_avtView)
         {
            return _avtView.avName;
         }
         return "";
      }
      
      override public function gotoAndStop(param1:Object, param2:String = null) : void
      {
         _window.gotoAndStop(param1,param2);
         if(_currFrameName)
         {
            if(param1 == "over")
            {
               xpShape[_currFrameName].mouse.gotoAndPlay(1);
            }
            else
            {
               xpShape[_currFrameName].mouse.gotoAndStop(1);
            }
         }
      }
      
      override public function destroy() : void
      {
         if(_avtView)
         {
            _avtView.destroy();
            _avtView = null;
         }
         if(_petView)
         {
            _petView.destroy();
            _petView = null;
         }
         super.destroy();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded)
         {
            if(!_hasSetInitialConditions)
            {
               setChildrenAndInitialConditions();
            }
            _isCurrItemLoaded = true;
            _window.charLayer.addChild(DisplayObject(_isPet ? _petView : _avtView));
            if(_ai && _ai.questLevel > 0)
            {
               _currFrameName = xpShape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
               if(xpShape.currentFrameLabel != _currFrameName)
               {
                  xpShape.gotoAndStop(_currFrameName);
               }
               Utility.createXpShape(_ai.questLevel,_isMember,xpShape[_currFrameName].mouse.up.icon,xpShape[_currFrameName].mouse.mouse.icon,2147483647);
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _hasSetInitialConditions = true;
         _window.sel.visible = false;
         if(_isPet)
         {
            _petView = new GuiPet(_currItem.createdTs,_currItem.idx,_currItem.lBits,_currItem.uBits,_currItem.eBits,_currItem.type,_currItem.name,_currItem.personalityDefId,_currItem.favoriteToyDefId,_currItem.favoriteFoodDefId,onPetViewLoaded);
         }
         else
         {
            _currItem = AvatarUtility.generateNew(Avatar(_currItem).perUserAvId,Avatar(_currItem),Avatar(_currItem).userName,AvatarManager.roomEnviroType);
            _avtView = new AvatarView();
            _avtView.init(Avatar(_currItem),null);
            _avtView.playAnim(13,false,1,onAvtAnimLoaded);
            if(_currPerUserAvId == Avatar(_currItem).perUserAvId)
            {
               sel.visible = true;
            }
         }
         addEventListeners();
      }
      
      private function onPetViewLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         if(_window)
         {
            param2.x = this.width * 0.3;
            param2.y = this.height * 0.4;
            param2.scaleY = 1.1;
            param2.scaleX = 1.1;
         }
      }
      
      private function onAvtAnimLoaded(param1:LayerAnim, param2:int) : void
      {
         BuddyCard.updateViewPosition(_avtView);
      }
   }
}

