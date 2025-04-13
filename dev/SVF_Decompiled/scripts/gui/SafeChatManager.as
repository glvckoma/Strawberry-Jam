package gui
{
   import com.sbi.debug.DebugUtility;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import localization.LocalizationManager;
   import quest.QuestManager;
   
   public class SafeChatManager
   {
      public static const TREE_SAFECHAT:int = 0;
      
      public static const TREE_ECARDTEXT:int = 1;
      
      public static const TREE_REPORTREASON:int = 2;
      
      public static const TREE_PHOTOBOOTH:int = 3;
      
      public static const TREE_ADVENTURE:int = 4;
      
      public static const TREE_PLAYERWALL:int = 5;
      
      public static var sctNodes:Array;
      
      public static var ctNodes:Array;
      
      public static var photoBoothNodes:Array;
      
      public static var adventureNodes:Array;
      
      public static var playerWallNodes:Array;
      
      private static const SCT_DIM_ALPHA:Number = 0.5;
      
      private static const SCT_BRIGHT_ALPHA:Number = 1;
      
      private static const JAG_LOCALIZATION_ID:int = 66;
      
      private static const BC_LOCALIZATION_ID:int = 47;
      
      private static const PHOTOBOOTH_LOCALIZATION_ID:int = 158;
      
      private static const ADVENTURE_LOCALIZATION_ID:int = 170;
      
      private static const PLAYERWALL_LOCALIZATION_ID:int = 333;
      
      private static var SafeChatTreeNode:Class;
      
      private static var _safeChatCallback:Function;
      
      private static var _safeChatCallbackFromOtherSystem:Function;
      
      private static var _safeChatBtn:MovieClip;
      
      private static var _safeChatTree:MovieClip;
      
      private static var _actionBtn:MovieClip;
      
      private static var _actionWindow:Sprite;
      
      private static var _emoteBtn:MovieClip;
      
      private static var _emoteWindow:Sprite;
      
      private static var _treeArray:Array;
      
      private static var _nodeYLocation:Number;
      
      private static var _lowestNodeYLocation:Number;
      
      private static var _safeTreeNodeHeight:Number;
      
      private static var _safeChatTreeNodes:MovieClip;
      
      private static var _hasLoadedLists:Boolean;
      
      public function SafeChatManager()
      {
         super();
      }
      
      public static function init(param1:Function, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:Sprite) : void
      {
         if(_safeChatCallback != null)
         {
            throw new Error("ERROR: Singleton SafeChatManager did not expect to be created twice!");
         }
         _safeChatCallback = param1;
         _safeChatBtn = param2;
         _safeChatTree = param3;
         if(sctNodes)
         {
            buildSafeChatTree(_safeChatTree);
         }
         _safeChatTree.visible = false;
         _actionBtn = param4;
         _actionWindow = param5;
         _emoteBtn = param6;
         _emoteWindow = param7;
      }
      
      public static function destroy(param1:MovieClip = null) : void
      {
         if(param1 != null)
         {
            while(param1.numChildren > 1)
            {
               param1.getChildAt(param1.numChildren - 1).removeEventListener("mouseDown",sctNodeMouseHandler);
               param1.removeChildAt(param1.numChildren - 1);
            }
            _safeChatCallbackFromOtherSystem = null;
            param1.visible = false;
            param1 = null;
            buildSafeChatTree(_safeChatTree);
         }
         else
         {
            while(_safeChatTree.numChildren > 0)
            {
               _safeChatTree.getChildAt(0).removeEventListener("mouseDown",sctNodeMouseHandler);
               _safeChatTree.removeChildAt(0);
            }
            _safeChatBtn = null;
            _safeChatTree.visible = false;
            _safeChatTree = null;
            _actionBtn = null;
            _actionWindow = null;
            _emoteBtn = null;
            _emoteWindow = null;
         }
      }
      
      public static function reload(param1:Boolean, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:Sprite) : void
      {
         _safeChatTree = param3;
         _safeChatBtn = param2;
         _safeChatTree.visible = false;
         _actionBtn = param4;
         _actionWindow = param5;
         _emoteBtn = param6;
         _emoteWindow = param7;
         if(param1)
         {
            while(_safeChatTree.numChildren > 1)
            {
               _safeChatTree.removeChildAt(_safeChatTree.numChildren - 1);
            }
            ctNodes = sctNodes = photoBoothNodes = adventureNodes = playerWallNodes = null;
            _hasLoadedLists = false;
         }
         else if(_safeChatTree.numChildren < 2 && _safeChatTreeNodes)
         {
            _safeChatTree.addChild(_safeChatTreeNodes);
         }
         _safeChatBtn.downToUpState();
      }
      
      public static function buildSafeChatTree(param1:MovieClip, param2:String = null, param3:int = 0, param4:Function = null, param5:Array = null, param6:Function = null) : void
      {
         var _loc7_:MovieClip = null;
         var _loc8_:int = 0;
         var _loc9_:* = 0;
         var _loc10_:MovieClip = null;
         if(!_hasLoadedLists)
         {
            requestSafeChatLists({
               "safeChatTreeGui":param1,
               "definitionName":param2,
               "type":param3,
               "safeChatSendCallback":param4,
               "initArray":param5,
               "onChatTreeLoaded":param6,
               "isFromSafeChat":null,
               "callback":null,
               "arguments":null,
               "open":null
            });
            return;
         }
         _safeChatCallbackFromOtherSystem = param4;
         if(param2 == null)
         {
            param2 = "SafeChatTreeNode";
         }
         SafeChatTreeNode = getDefinitionByName(param2) as Class;
         if(param5 != null)
         {
            _treeArray = param5;
         }
         else if(param3 == 1)
         {
            _treeArray = ctNodes;
         }
         else if(param3 == 3)
         {
            _treeArray = photoBoothNodes;
         }
         else if(param3 == 4)
         {
            _treeArray = adventureNodes;
         }
         else if(param3 == 5)
         {
            _treeArray = playerWallNodes;
         }
         else
         {
            _treeArray = sctNodes;
         }
         if(_treeArray)
         {
            _loc7_ = new SafeChatTreeNode();
            _loc8_ = param1.height - (_treeArray.length * _loc7_.height - 1);
            _safeChatTreeNodes = new MovieClip();
            _loc9_ = 0;
            while(_loc9_ < _treeArray.length)
            {
               _loc10_ = new SafeChatTreeNode();
               _loc10_.x = 0;
               _loc10_.y = _loc8_ + _loc9_ * (_loc10_.height - 1);
               _safeChatTreeNodes.addChild(_loc10_);
               _loc10_["menuNums"] = [_loc9_];
               _loc10_.addEventListener("mouseDown",sctNodeMouseHandler,false,0,true);
               if(_treeArray[_loc9_].length == 1)
               {
                  LocalizationManager.updateToFit(_loc10_.sctNodeTxt,_treeArray[_loc9_][0]);
                  _loc10_.sctNodeBG.gotoAndStop(1);
               }
               else
               {
                  _safeTreeNodeHeight = _loc10_.height;
                  _lowestNodeYLocation = _loc8_ + (_treeArray.length - 1) * (_safeTreeNodeHeight - 1);
                  _nodeYLocation = _loc10_.y;
                  LocalizationManager.updateToFit(_loc10_.sctNodeTxt,_treeArray[_loc9_][0]);
                  _loc10_.sctNodeBG.gotoAndStop(3);
                  buildChatTreeSubMenu(_treeArray[_loc9_],DisplayObjectContainer(_loc10_),0);
               }
               _loc9_++;
            }
            param1.addChild(_safeChatTreeNodes);
         }
         if(param6 != null)
         {
            param6();
         }
      }
      
      public static function containsInTreeArray(param1:String, param2:int = 0) : Boolean
      {
         var _loc5_:Object = null;
         var _loc7_:Array = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         if(param2 == 1)
         {
            _loc7_ = ctNodes;
         }
         else if(param2 == 3)
         {
            _loc7_ = photoBoothNodes;
         }
         else if(param2 == 4)
         {
            _loc7_ = adventureNodes;
         }
         else if(param2 == 5)
         {
            _loc7_ = playerWallNodes;
         }
         else
         {
            _loc7_ = sctNodes;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc7_.length)
         {
            _loc5_ = _loc7_[_loc4_];
            if(_loc5_ is Array)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc5_.length)
               {
                  if(_loc5_[_loc6_] == param1)
                  {
                     return true;
                  }
                  _loc6_++;
               }
            }
            else if(_loc5_ == param1)
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      private static function requestSafeChatLists(param1:Object) : void
      {
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(47,onListLoaded,param1);
         GenericListXtCommManager.requestGenericList(66,onListLoaded,param1);
         GenericListXtCommManager.requestGenericList(158,onListLoaded,param1);
         GenericListXtCommManager.requestGenericList(170,onListLoaded,param1);
         GenericListXtCommManager.requestGenericList(333,onListLoaded,param1);
      }
      
      private static function onListLoaded(param1:int, param2:Array, param3:Object) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc8_:RegExp = /\r\n|\n|\r/g;
         var _loc7_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = LocalizationManager.translateIdOnly(param2[_loc5_]).split(_loc8_);
            _loc7_.push(_loc4_);
            _loc5_++;
         }
         if(param1 == 47)
         {
            sctNodes = _loc7_;
         }
         else if(param1 == 66)
         {
            ctNodes = _loc7_;
         }
         else if(param1 == 158)
         {
            photoBoothNodes = _loc7_;
         }
         else if(param1 == 170)
         {
            adventureNodes = _loc7_;
         }
         else if(param1 == 333)
         {
            playerWallNodes = _loc7_;
         }
         else
         {
            DebugUtility.debugTrace("Loaded safe chat list that doesn\'t match!");
         }
         if(ctNodes && sctNodes && photoBoothNodes && adventureNodes && playerWallNodes)
         {
            _hasLoadedLists = true;
            DarkenManager.showLoadingSpiral(false);
            buildSafeChatTree(param3.safeChatTreeGui,param3.definitionName,param3.type,param3.safeChatSendCallback,param3.initArray,param3.onChatTreeLoaded);
            if(param3.hasOwnProperty("open") && param3.open)
            {
               openSafeChat(param3.isFromSafeChat,param3.tree);
            }
            if(param3.hasOwnProperty("callback") && param3.callback != null && Boolean(param3.hasOwnProperty("arguments")) && param3.arguments != null)
            {
               _loc6_ = param3.arguments;
               if(_loc6_.length == 1)
               {
                  param3.callback(_loc6_[0]);
               }
               else
               {
                  if(_loc6_.length != 2)
                  {
                     throw new Error("SafeChatManager too many arguments");
                  }
                  param3.callback(_loc6_[0],_loc6_[1]);
               }
            }
         }
      }
      
      private static function buildChatTreeSubMenu(param1:Array, param2:DisplayObjectContainer, param3:uint) : void
      {
         var _loc4_:* = 0;
         var _loc8_:MovieClip = null;
         var _loc5_:* = 0;
         var _loc7_:* = null;
         param3++;
         var _loc6_:Number = _nodeYLocation + (param1.length - 2) * (_safeTreeNodeHeight - 1);
         if(_loc6_ > _lowestNodeYLocation)
         {
            _nodeYLocation -= _loc6_ - _lowestNodeYLocation;
         }
         _loc4_ = 1;
         while(_loc4_ < param1.length)
         {
            _loc8_ = new SafeChatTreeNode();
            _loc8_.x = param3 * _loc8_.width - param2.x;
            _loc8_.y = _nodeYLocation + (_loc4_ - 1) * (_loc8_.height - 1);
            _loc5_ = param3;
            _loc7_ = param2;
            while(_loc5_ > 0)
            {
               _loc8_.y -= _loc7_.y;
               _loc7_ = _loc7_.parent;
               _loc5_--;
            }
            param2.addChild(_loc8_);
            _loc8_.visible = false;
            if(_loc8_.parent["menuNums"])
            {
               _loc8_["menuNums"] = _loc8_.parent["menuNums"].slice();
               _loc8_["menuNums"].push(_loc4_);
            }
            else
            {
               _loc8_["menuNums"] = [_loc4_];
            }
            _loc8_.addEventListener("mouseDown",sctNodeMouseHandler,false,0,true);
            if(param1[_loc4_] is String)
            {
               LocalizationManager.updateToFit(_loc8_.sctNodeTxt,param1[_loc4_]);
               _loc8_.sctNodeBG.gotoAndStop(1);
            }
            else
            {
               if(!(param1[_loc4_] is Array))
               {
                  throw new Error("invalid type in scSubTree...");
               }
               LocalizationManager.updateToFit(_loc8_.sctNodeTxt,param1[_loc4_][0]);
               _loc8_.sctNodeBG.gotoAndStop(3);
               buildChatTreeSubMenu(param1[_loc4_],DisplayObjectContainer(_loc8_),param3);
            }
            _loc4_++;
         }
      }
      
      private static function resetSafeChatTree(param1:Boolean, param2:MovieClip = null) : void
      {
         var _loc5_:* = 0;
         var _loc7_:DisplayObject = null;
         var _loc6_:DisplayObjectContainer = null;
         var _loc3_:* = 0;
         var _loc8_:DisplayObject = null;
         if(param1)
         {
            SafeChatTreeNode = getDefinitionByName("SafeChatTreeNode") as Class;
         }
         var _loc4_:* = MovieClip(_safeChatTree.getChildAt(1));
         if(param2)
         {
            _loc4_ = param2;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_.numChildren)
         {
            _loc7_ = _loc4_.getChildAt(_loc5_);
            if(_loc7_ && _loc7_ is DisplayObjectContainer)
            {
               if(_loc7_ is SafeChatTreeNode)
               {
                  if(SafeChatTreeNode(_loc7_).sctNodeBG.currentFrame == 4)
                  {
                     SafeChatTreeNode(_loc7_).sctNodeBG.gotoAndStop(3);
                  }
                  if(SafeChatTreeNode(_loc7_).sctNodeBG.currentFrame == 2)
                  {
                     SafeChatTreeNode(_loc7_).sctNodeBG.gotoAndStop(1);
                  }
               }
               _loc6_ = DisplayObjectContainer(_loc7_);
               _loc3_ = 0;
               while(_loc3_ < _loc6_.numChildren)
               {
                  _loc8_ = _loc6_.getChildAt(_loc3_);
                  if(_loc8_ && _loc8_ is SafeChatTreeNode)
                  {
                     _loc8_.visible = false;
                     SafeChatTreeNode(_loc8_).sctNodeBG.gotoAndStop(1);
                  }
                  _loc3_++;
               }
            }
            _loc5_++;
         }
      }
      
      private static function sctNodeMouseHandler(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         param1.stopPropagation();
         brightenSafeChat();
         if(!param1.currentTarget is SafeChatTreeNode)
         {
            DebugUtility.debugTrace("ERROR: illegal event type in sctNodeMouseHandler!");
            return;
         }
         if(!Utility.canChat())
         {
            return;
         }
         var _loc2_:String = param1.currentTarget.sctNodeTxt.text;
         if(_loc2_.indexOf("...") >= 0)
         {
            return;
         }
         if(param1.currentTarget.parent.sctNodeTxt)
         {
            _loc3_ = param1.currentTarget.parent.sctNodeTxt.text;
            if(_loc3_.indexOf("...") > 0)
            {
               _loc2_ = _loc3_.slice(0,_loc3_.indexOf("...")) + " " + _loc2_;
            }
         }
         if(_safeChatCallbackFromOtherSystem != null)
         {
            _safeChatCallbackFromOtherSystem(_loc2_,param1.currentTarget.menuNums.toString());
         }
         else
         {
            _safeChatCallback(_loc2_,param1.currentTarget.menuNums.toString());
         }
      }
      
      public static function safeChatCodeForString(param1:Function, param2:Array, param3:String, param4:int = -1) : String
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(!_hasLoadedLists)
         {
            requestSafeChatLists({
               "callback":param1,
               "arguments":param2,
               "safeChatTreeGui":_safeChatTree,
               "definitionName":null,
               "type":param4,
               "safeChatSendCallback":null,
               "initArray":null,
               "tree":null,
               "open":null,
               "onChatTreeLoaded":null,
               "isFromSafeChat":null
            });
            return "";
         }
         if(param4 != -1 || _treeArray == null)
         {
            if(param4 == 1)
            {
               _loc5_ = ctNodes;
            }
            else if(param4 == 3)
            {
               _loc5_ = photoBoothNodes;
            }
            else if(param4 == 4)
            {
               _loc5_ = adventureNodes;
            }
            else if(param4 == 5)
            {
               _loc5_ = playerWallNodes;
            }
            else
            {
               _loc5_ = sctNodes;
            }
         }
         else
         {
            _loc5_ = _treeArray;
         }
         _loc7_ = 0;
         while(_loc7_ < _loc5_.length)
         {
            if(_loc5_[_loc7_] is String)
            {
               if(_loc5_[_loc7_] == param3)
               {
                  return _loc7_ + "0";
               }
            }
            else
            {
               _loc6_ = _loc5_[_loc7_][0];
               if(param3 == _loc6_)
               {
                  return String(_loc7_);
               }
               _loc8_ = 1;
               while(_loc8_ < _loc5_[_loc7_].length)
               {
                  if(_loc6_.indexOf("...") > -1)
                  {
                     if(param3 == _loc6_.substr(0,_loc6_.length - 3) + " " + _loc5_[_loc7_][_loc8_])
                     {
                        return _loc7_ + "," + _loc8_;
                     }
                  }
                  else if(_loc5_[_loc7_][_loc8_] == param3)
                  {
                     return _loc7_ + "," + _loc8_;
                  }
                  _loc8_++;
               }
            }
            _loc7_++;
         }
         return null;
      }
      
      public static function safeChatStringForCode(param1:Function, param2:Array, param3:String, param4:int = -1) : String
      {
         var _loc6_:String = null;
         var _loc8_:* = 0;
         if(!_hasLoadedLists)
         {
            requestSafeChatLists({
               "callback":param1,
               "arguments":param2,
               "safeChatTreeGui":_safeChatTree,
               "definitionName":null,
               "type":param4,
               "safeChatSendCallback":null,
               "initArray":null,
               "tree":null,
               "open":null,
               "onChatTreeLoaded":null,
               "isFromSafeChat":null
            });
            return "";
         }
         var _loc7_:Array = param3.split(",");
         if(param4 != -1 || _treeArray == null)
         {
            if(param4 == 1)
            {
               _treeArray = ctNodes;
            }
            else if(param4 == 3)
            {
               _treeArray = photoBoothNodes;
            }
            else if(param4 == 4)
            {
               _treeArray = adventureNodes;
            }
            else if(param4 == 5)
            {
               _treeArray = playerWallNodes;
            }
            else
            {
               _treeArray = sctNodes;
            }
         }
         else if(gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom())
         {
            _treeArray = adventureNodes;
         }
         else
         {
            _treeArray = sctNodes;
         }
         var _loc5_:Array = _treeArray;
         _loc8_ = 0;
         while(_loc8_ < _loc7_.length)
         {
            if(_loc8_ >= _loc7_.length - 1)
            {
               if(_loc5_[_loc7_[_loc8_]] is String)
               {
                  if(_loc6_ && _loc6_.indexOf("...") > 0 && _loc6_.indexOf("...") == _loc6_.length - 3)
                  {
                     return _loc6_.substr(0,_loc6_.length - 3) + " " + _loc5_[_loc7_[_loc8_]];
                  }
                  return _loc5_[_loc7_[_loc8_]];
               }
               if(_loc5_[_loc7_[_loc8_]] is Array)
               {
                  return _loc5_[_loc7_[_loc8_]][0];
               }
               return null;
            }
            if(_loc5_[_loc7_[_loc8_]] is String)
            {
               return null;
            }
            if(!(_loc5_[_loc7_[_loc8_]] is Array))
            {
               return null;
            }
            _loc6_ = _loc5_[_loc7_[_loc8_]][0];
            _loc5_ = _loc5_[_loc7_[_loc8_]];
            _loc8_++;
         }
         return null;
      }
      
      public static function openSafeChat(param1:Boolean, param2:MovieClip = null) : void
      {
         if(!_hasLoadedLists)
         {
            requestSafeChatLists({
               "open":true,
               "safeChatTreeGui":_safeChatTree,
               "isFromSafeChat":param1,
               "tree":param2,
               "definitionName":null,
               "type":0,
               "safeChatSendCallback":null,
               "initArray":null,
               "tree":null,
               "open":null,
               "onChatTreeLoaded":null,
               "isFromSafeChat":null
            });
         }
         else if(param2 && !param2.visible)
         {
            param2.visible = true;
            resetSafeChatTree(param1,MovieClip(param2.getChildAt(1)));
         }
         else if(!_safeChatTree.visible)
         {
            _safeChatTree.visible = true;
            resetSafeChatTree(param1);
            brightenSafeChat();
         }
      }
      
      public static function dimSafeChat() : void
      {
         if(_safeChatTree.visible && _safeChatTree.alpha != 0.5)
         {
            _safeChatTree.alpha = 0.5;
         }
      }
      
      public static function brightenSafeChat() : void
      {
         if(_safeChatTree.alpha != 1)
         {
            _safeChatTree.alpha = 1;
         }
      }
      
      public static function closeSafeChat(param1:MovieClip = null) : void
      {
         if(param1 && param1.visible)
         {
            param1.visible = false;
         }
         if(_safeChatTree)
         {
            if(_safeChatTree.visible)
            {
               _safeChatTree.visible = false;
            }
            _safeChatBtn.downToUpState();
         }
      }
      
      public static function get hasLoadedLists() : Boolean
      {
         return _hasLoadedLists;
      }
   }
}

