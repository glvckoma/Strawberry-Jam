package gui
{
   import Party.PartyManager;
   import com.sbi.analytics.SBTracker;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestXtCommManager;
   
   public class BarrierPopup
   {
      public static const TYPE_PARTY:int = 0;
      
      public static const TYPE_ADVENTURE:int = 1;
      
      private const PARTY_BARRIER_MEDIA_ID:int = 1299;
      
      private var _barrierPopup:MovieClip;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _type:int;
      
      private var _closeCallback:Function;
      
      private var _isTryingToSwitch:Boolean;
      
      private var _doesNotHaveRequiredPet:Boolean;
      
      private var _secondaryDefId:int;
      
      public function BarrierPopup()
      {
         super();
      }
      
      public function init(param1:int, param2:Function = null, param3:Boolean = false, param4:Boolean = false, param5:int = -1) : void
      {
         if(param5 == -1)
         {
            param5 = int(gMainFrame.clientInfo.secondaryDefId);
         }
         _type = param1;
         _closeCallback = param2;
         _isTryingToSwitch = param3;
         _doesNotHaveRequiredPet = param4;
         _secondaryDefId = param5;
         DarkenManager.showLoadingSpiral(true);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1299,onMediaItemLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:Function = null;
         DarkenManager.showLoadingSpiral(false);
         if(_closeCallback != null)
         {
            _loc1_ = _closeCallback;
            _closeCallback = null;
            _loc1_();
            return;
         }
         if(_loadingMediaHelper)
         {
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
         if(_barrierPopup.parent == GuiManager.guiLayer)
         {
            DarkenManager.unDarken(_barrierPopup);
            GuiManager.guiLayer.removeChild(_barrierPopup);
         }
         _barrierPopup = null;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _barrierPopup = MovieClip(param1.getChildAt(0));
            _barrierPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _barrierPopup.bx.addEventListener("mouseDown",onBarrierClose,false,0,true);
            _barrierPopup.x = 900 * 0.5;
            _barrierPopup.y = 550 * 0.5;
            _loc2_ = getCurrDef();
            if(_loc2_ != null)
            {
               switch(_type)
               {
                  case 0:
                     if(int(_loc2_.restrictions) == 4 || int(_loc2_.restrictions) == 8)
                     {
                        setupBarrier(_loc2_.petDefScalableFlags,false);
                        break;
                     }
                     setupBarrier(_loc2_.avatarDefFlags,true);
                     break;
                  case 1:
                     setupBarrier(_loc2_.avatarDefFlags,true);
                     break;
                  default:
                     destroy();
               }
            }
            else
            {
               destroy();
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onBarrierClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function setupBarrier(param1:Number, param2:Boolean) : void
      {
         var _loc9_:Boolean = false;
         var _loc5_:Array = null;
         var _loc8_:int = 0;
         var _loc12_:Array = null;
         var _loc6_:Boolean = false;
         var _loc10_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         GuiManager.guiLayer.addChild(_barrierPopup);
         DarkenManager.darken(_barrierPopup);
         var _loc11_:String = param2 ? "Avatar" : "Pet";
         var _loc3_:String = param1.toString(2);
         var _loc7_:int = _loc3_.length - 1;
         var _loc4_:String = null;
         _loc7_;
         while(_loc7_ >= 0)
         {
            if(_loc3_.charAt(_loc7_) == "1")
            {
               if(_loc4_ == null)
               {
                  _loc4_ = _loc11_ + (_loc3_.length - 1 - _loc7_ + 1);
               }
               if(_loc7_ == 0)
               {
                  break;
               }
               if(_loc9_)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _barrierPopup.currentLabels.length)
                  {
                     _loc5_ = _barrierPopup.currentLabels[_loc8_].name.split(_loc11_);
                     if(_loc5_.length == 2)
                     {
                        if(_loc3_.indexOf(String(_loc5_[1])) != -1)
                        {
                           _loc4_ = _barrierPopup.currentLabels[_loc8_].name;
                        }
                     }
                     _loc8_++;
                  }
                  break;
               }
               _loc9_ = true;
            }
            _loc7_--;
         }
         if(_loc4_ == null)
         {
            _loc4_ = _loc11_ + _loc7_;
         }
         if(_barrierPopup.currentFrameLabel != _loc4_)
         {
            if(!param2)
            {
               _loc12_ = _barrierPopup.currentLabels;
               _loc6_ = false;
               _loc10_ = 0;
               while(_loc10_ < _loc12_.length)
               {
                  if(_loc12_[_loc10_].name == _loc4_)
                  {
                     _barrierPopup.gotoAndStop(_loc10_ + 1);
                     _loc6_ = true;
                     break;
                  }
                  _loc10_++;
               }
               if(!_loc6_)
               {
                  _barrierPopup.gotoAndStop("Pets");
               }
            }
            else
            {
               _barrierPopup.gotoAndStop(_loc4_);
            }
         }
         if(!isNaN(Number(_barrierPopup.Message_txt.text)))
         {
            LocalizationManager.translateIdAndInsert(_barrierPopup.Message_txt,int(_barrierPopup.Message_txt.text),typeName);
         }
         LocalizationManager.findAllTextfields(_barrierPopup);
         if(param2)
         {
            if(gMainFrame.userInfo.isMember)
            {
               if(_isTryingToSwitch)
               {
                  SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/member/switch");
               }
               else
               {
                  SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/member");
               }
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/nonMember");
            }
         }
         else if(gMainFrame.userInfo.isMember)
         {
            if(_isTryingToSwitch)
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#petParty/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#petParty/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#petParty/nonMember");
         }
      }
      
      private function getCurrDef() : Object
      {
         switch(_type)
         {
            case 0:
               return PartyManager.getPartyDef(_secondaryDefId);
            case 1:
               return QuestXtCommManager.getScriptDef(_secondaryDefId);
            default:
               return null;
         }
      }
      
      private function get typeName() : String
      {
         switch(_type)
         {
            case 0:
               return LocalizationManager.translateIdOnly(25694);
            case 1:
               return LocalizationManager.translateIdOnly(25695);
            default:
               return "";
         }
      }
   }
}

