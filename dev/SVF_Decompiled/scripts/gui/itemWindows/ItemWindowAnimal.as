package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.graphics.LayerAnim;
   import den.DenRoomItem;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import gui.DenSwitch;
   import gui.LoadingSpiral;
   import localization.LocalizationManager;
   
   public class ItemWindowAnimal extends ItemWindowBase
   {
      private const COST_OF_NEW_ANIMAL:int = 1000;
      
      private const SLOTS_PER_NONMEMBER:int = 2;
      
      private var _isChoosing:Boolean;
      
      private var _isAnimal:Boolean;
      
      private var _recyclingOnly:Boolean;
      
      private var _addGrayChild:Boolean;
      
      private var _isChoosingOcean:Boolean;
      
      private var _ai:AvatarInfo;
      
      private var _nameBarData:int;
      
      private var _hasAddedEventListeners:Boolean;
      
      private var _avtView:AvatarView;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _numNonMemberOceanOnlyAvatars:int;
      
      private var _numNonMemberAvatars:int;
      
      private var _isRecycling:Function;
      
      private var _fromDeletion:Boolean;
      
      private var _ignoreEnviroType:Boolean;
      
      public function ItemWindowAnimal(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _isChoosing = param9.isChoosing;
         _isAnimal = param9.isAnimal;
         _recyclingOnly = param9.recylingOnly;
         _isChoosingOcean = param9.isChoosingOcean;
         _nameBarData = param9.nameBarData;
         if(_isAnimal)
         {
            _numNonMemberAvatars = param9.numNonMemberAvatars;
            _numNonMemberOceanOnlyAvatars = param9.numNonMemberOceanOnlyAvatars;
            _isRecycling = param9.isRecycling;
            _ignoreEnviroType = param9.ignoreEnviroType;
         }
         super("amlCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get aml() : MovieClip
      {
         return _window.aml;
      }
      
      public function get makeNew() : MovieClip
      {
         return _window.makeNew;
      }
      
      public function get recycle() : MovieClip
      {
         return _window.recycle;
      }
      
      public function get denWindow() : MovieClip
      {
         return _window.den;
      }
      
      public function get lock() : MovieClip
      {
         return _window.lock;
      }
      
      public function get gray() : MovieClip
      {
         return _window.gray;
      }
      
      public function get checkbox() : MovieClip
      {
         return _window.checkbox;
      }
      
      public function get buyDen() : MovieClip
      {
         return _window.buyDen;
      }
      
      public function set currItem(param1:DenRoomItem) : void
      {
         _currItem = param1;
      }
      
      public function get level() : int
      {
         return !!_ai ? _ai.questLevel : 0;
      }
      
      public function isUsable() : Boolean
      {
         if(AvatarSwitch.avatars[_index] == null)
         {
            return true;
         }
         return false;
      }
      
      public function removeLoadedItem() : void
      {
         _fromDeletion = true;
         if(_avtView)
         {
            _avtView.destroy();
            _avtView = null;
         }
         while(aml.amlMask.amlBox.numChildren > 0)
         {
            aml.amlMask.amlBox.removeChildAt(0);
         }
         while(gray.amlMask.amlBox.numChildren > 0)
         {
            gray.amlMask.amlBox.removeChildAt(0);
         }
         resetWindow(index);
         _fromDeletion = false;
      }
      
      public function resetWindow(param1:int) : void
      {
         if(_isAnimal)
         {
            _window.makeNew.visible = true;
            _window.priceTag.visible = false;
            _window.buy.visible = false;
            _window.lock.visible = false;
            _window.aml.visible = false;
            _window.aml.sel.visible = false;
            _window.recycle.visible = false;
            _window.gray.visible = false;
            _window.lock.visible = false;
            _window.makeNew.newAmlBtn.gray.visible = false;
            _window.xpShape.visible = false;
            AvatarSwitch.numOpenNonMemberSlots--;
            _isCurrItemLoaded = false;
            loadCurrItem();
         }
         else
         {
            if(param1 > 0)
            {
               while(_window.den.itemBlock.numChildren > 0)
               {
                  _window.den.itemBlock.removeChildAt(0);
               }
            }
            _window.buyDen.visible = true;
            _window.den.visible = false;
            _window.priceTag.visible = false;
            _window.buy.visible = false;
            _window.lock.visible = false;
            _window.aml.visible = false;
            _window.aml.sel.visible = false;
            _window.recycle.visible = false;
            _window.gray.visible = false;
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         if(!_hasAddedEventListeners && (_isChoosing || _isChoosingOcean))
         {
            addEventListeners();
         }
         super.onWindowLoadCallback();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Avatar = null;
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_hasAddedEventListeners)
         {
            addEventListeners();
         }
         if(_isAnimal)
         {
            if(!_isCurrItemLoaded)
            {
               _loc4_ = 1000;
               _window.gray.grayDen.visible = false;
               _window.aml.bg.visible = true;
               _window.aml.gray.visible = false;
               _window.aml.nameTxt.visible = true;
               _window.priceTag.txt.text = 1000;
               _window.aml.visible = true;
               if(AvatarSwitch.avatars[_index] != null && !_fromDeletion)
               {
                  _loc3_ = AvatarSwitch.avatars[_index];
                  _loc3_ = AvatarUtility.generateNew(_loc3_.perUserAvId,_loc3_,_loc3_.userName,_loc3_.sfsUserId,AvatarManager.roomEnviroType,null,false,_ignoreEnviroType);
                  _avtView = new AvatarView();
                  _avtView.init(_loc3_,null,null,false,_ignoreEnviroType);
                  _avtView.visible = false;
                  _avtView.playAnim(13,false,1,onViewLoaded);
                  if(AvatarSwitch.isSlotAvailable(_index) || _isChoosing)
                  {
                     _loadingSpiral = new LoadingSpiral(_window.aml.amlMask.amlBox.addChild(_avtView));
                     _window.priceTag.visible = false;
                     _window.buy.visible = false;
                     _window.makeNew.visible = false;
                     _window.lock.visible = false;
                     _window.aml.visible = true;
                     _window.aml.sel.visible = false;
                     _window.aml.nameTxt.text = _loc3_.avName;
                     if(_isChoosing)
                     {
                        _window.checkbox.visible = true;
                        _window.checkbox.check.visible = false;
                        _window.aml.bg.visible = false;
                        _window.aml.gray.visible = true;
                        if(_numNonMemberAvatars > 0 && _numNonMemberAvatars < 3)
                        {
                           if(!AvatarSwitch.isMemberOnlyAvatar(_index))
                           {
                              _window.checkbox.check.visible = false;
                           }
                        }
                        if(_numNonMemberAvatars - _numNonMemberOceanOnlyAvatars < 1 || _numNonMemberAvatars <= _loc4_ && AvatarSwitch.isMemberOnlyAvatar(_index))
                        {
                           _window.aml.visible = false;
                           _window.gray.visible = true;
                           _window.lock.visible = true;
                           _window.checkbox.visible = false;
                           _window.gray.nameTxt.text = _loc3_.avName;
                           _addGrayChild = true;
                        }
                     }
                     if(_index == AvatarSwitch.activeAvatarIdx)
                     {
                        _window.aml.sel.visible = true;
                     }
                     while(_window.xpShape.numChildren > 0)
                     {
                        _window.xpShape.removeChildAt(0);
                     }
                     if(_isChoosing)
                     {
                        if(!gMainFrame.userInfo.isMember && !AvatarSwitch.isMemberOnlyAvatar(_index))
                        {
                           AvatarSwitch.numOpenNonMemberSlots++;
                        }
                     }
                     else
                     {
                        AvatarSwitch.numOpenNonMemberSlots++;
                     }
                  }
                  else
                  {
                     _window.aml.visible = false;
                     _window.gray.visible = true;
                     _window.gray.nameTxt.text = _loc3_.avName;
                     _addGrayChild = true;
                     _window.gray.amlMask.amlBox.addChild(_avtView);
                  }
                  if(Utility.isOcean(_avtView.avatarData.enviroTypeFlag))
                  {
                     if(Utility.isLand(_avtView.avatarData.enviroTypeFlag))
                     {
                        if(_window.aml.visible)
                        {
                           if(_window.aml.gray.visible)
                           {
                              _window.aml.gray.gotoAndStop(3);
                           }
                           else
                           {
                              _window.aml.bg.gotoAndStop(3);
                           }
                        }
                        else
                        {
                           _window.gray.grayAml.gotoAndStop(3);
                        }
                     }
                     else if(_window.aml.visible)
                     {
                        if(_window.aml.gray.visible)
                        {
                           _window.aml.gray.gotoAndStop(2);
                        }
                        else
                        {
                           _window.aml.bg.gotoAndStop(2);
                        }
                     }
                     else
                     {
                        _window.gray.grayAml.gotoAndStop(2);
                     }
                  }
                  _window.recycle.visible = _isRecycling();
               }
               else
               {
                  if(!gMainFrame.userInfo.isMember)
                  {
                     if(AvatarSwitch.numOpenNonMemberSlots < 2 || _isChoosing && _numNonMemberAvatars - _numNonMemberOceanOnlyAvatars < 1)
                     {
                        AvatarSwitch.numOpenNonMemberSlots++;
                        _window.makeNew.visible = true;
                        _window.lock.visible = false;
                     }
                     else
                     {
                        _window.makeNew.visible = false;
                        _window.lock.visible = true;
                     }
                  }
                  else
                  {
                     _window.makeNew.visible = true;
                     _window.lock.visible = false;
                  }
                  _window.priceTag.visible = false;
                  _window.buy.visible = false;
                  _window.aml.visible = false;
                  _window.aml.sel.visible = false;
                  _window.recycle.visible = false;
                  if(_isChoosing && _numNonMemberAvatars > 1 && _numNonMemberAvatars - _numNonMemberOceanOnlyAvatars > 0)
                  {
                     _window.makeNew.newAmlBtn.gray.visible = true;
                  }
                  else
                  {
                     _window.makeNew.newAmlBtn.gray.visible = false;
                  }
                  _isCurrItemLoaded = true;
               }
            }
         }
         else if(_currItem != null)
         {
            if(!_isCurrItemLoaded)
            {
               _isCurrItemLoaded = true;
               _window.den.sel.visible = false;
               if(gMainFrame.userInfo.isMember)
               {
                  _window.den.visible = true;
                  LocalizationManager.updateToFit(_window.den.txt,_currItem.name,false,false,false);
               }
               else if(_currItem.isMemberOnly)
               {
                  _addGrayChild = true;
                  _window.den.visible = false;
                  _window.gray.visible = true;
                  LocalizationManager.updateToFit(_window.gray.nameTxt,_currItem.name,false,false,false);
               }
               else
               {
                  _window.den.visible = true;
                  LocalizationManager.updateToFit(_window.den.txt,_currItem.name,false,false,false);
               }
               if(_currItem.isLand)
               {
                  _window.den.greenBG.visible = true;
               }
               else
               {
                  _window.den.greenBG.visible = false;
               }
               if(_index == DenSwitch.activeDenIdx)
               {
                  _window.den.sel.visible = true;
               }
               _window.buyDen.visible = false;
               if(_recyclingOnly)
               {
                  _window.recycle.visible = true;
               }
            }
         }
         else
         {
            _window.den.visible = false;
            _window.buyDen.visible = true;
         }
         if(_currItem && _avtView && !_isCurrItemLoaded && _isAnimal)
         {
            _isCurrItemLoaded = true;
            if(_addGrayChild)
            {
               _window.gray.amlMask.amlBox.addChild(_avtView);
            }
            else
            {
               _window.aml.amlMask.amlBox.addChild(_avtView);
            }
         }
      }
      
      private function loadQuestShape() : void
      {
         var _loc1_:String = _window.xpShape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
         _window.xpShape.visible = true;
         if(_loc1_ == "black")
         {
            _window.xpShape.gotoAndStop(2);
            _window.xpShape.gotoAndStop(_loc1_);
         }
         if(_window.xpShape.currentFrameLabel != _loc1_)
         {
            _window.xpShape.gotoAndStop(_loc1_);
         }
         Utility.createXpShape(_ai.questLevel,true,_window.xpShape[_loc1_].mouse.up.icon,null,_nameBarData);
      }
      
      override public function destroy() : void
      {
         AvatarSwitch.numOpenNonMemberSlots = 0;
         if(_avtView)
         {
            _avtView.destroy();
            _avtView = null;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
         if(_isAnimal)
         {
            _currItem = null;
         }
         super.destroy();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.priceTag.visible = false;
         _window.priceTag.txt.textColor = "0x386630";
         _window.buy.visible = false;
         _window.makeNew.visible = false;
         _window.lock.visible = false;
         _window.recycle.visible = false;
         _window.den.visible = false;
         _window.buyDen.visible = false;
         _window.xpShape.visible = false;
         if(_isAnimal)
         {
            _window.aml.visible = true;
            _window.aml.bg.visible = false;
            _window.aml.gray.visible = true;
            _window.aml.sel.visible = false;
            _window.aml.nameTxt.visible = false;
         }
         else
         {
            _window.aml.visible = false;
         }
         _window.gray.visible = false;
         _window.buyDen.buyBtn.gray.visible = false;
         _window.buy.buyAmlBtn.gray.visible = false;
         _window.makeNew.newAmlBtn.gray.visible = false;
         _window.checkbox.visible = false;
      }
      
      override protected function addEventListeners() : void
      {
         _hasAddedEventListeners = true;
         if(_window)
         {
            if(_mouseDown != null)
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null)
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
      }
      
      private function onViewLoaded(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = null;
         if(_window && _avtView)
         {
            _loc3_ = AvatarUtility.getAnimalItemWindowOffset(_avtView.avTypeId);
            _avtView.x = _loc3_.x;
            _avtView.y = _loc3_.y;
            _window.aml.nameTxt.text = _avtView.avName;
            _window.gray.nameTxt.text = _avtView.avName;
            _ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(_avtView.userName,_avtView.perUserAvId);
            if(_ai && _ai.questLevel > 0)
            {
               loadQuestShape();
            }
            _avtView.visible = true;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
      }
   }
}

