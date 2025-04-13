package quest
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import gui.GuiManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowSatchel;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   
   public class SeedInventoryHandling
   {
      public const MAX_NUM_SEEDS:int = 5;
      
      private var _seedsInventory:Dictionary;
      
      private var _draggedSeed:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _mediaItems:Array;
      
      private var _clickStartX:Number;
      
      private var _clickStartY:Number;
      
      private var _satchelCont:MovieClip;
      
      private var _combinedCurrencyWindow:WindowAndScrollbarGenerator;
      
      public function SeedInventoryHandling()
      {
         super();
      }
      
      public function init(param1:Dictionary) : void
      {
         _mediaItems = [];
         _seedsInventory = param1;
         setupInventoryWindows();
      }
      
      public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         if(_draggedSeed && _draggedSeed.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(_draggedSeed);
         }
         _draggedSeed = null;
         _loc2_ = 0;
         while(_loc2_ < 5)
         {
            _loc1_ = GuiManager.mainHud["inventoriesWindow" + _loc2_];
            if(_loc1_)
            {
               _loc1_.removeEventListener("mouseDown",onSeedsClickStart);
            }
            _loc2_++;
         }
         if(_satchelCont)
         {
            if(_satchelCont.parent && _satchelCont.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_satchelCont);
            }
            _satchelCont = null;
         }
         if(_combinedCurrencyWindow)
         {
            _combinedCurrencyWindow.destroy();
            _combinedCurrencyWindow = null;
         }
         _seedsInventory = null;
      }
      
      public function updateCombinedCurrency() : void
      {
         if(_combinedCurrencyWindow)
         {
            _combinedCurrencyWindow.callUpdateInWindow();
         }
      }
      
      public function rebuildInventory(param1:Dictionary) : void
      {
         _seedsInventory = param1;
         setupInventoryWindows();
      }
      
      public function removeLastDraggedSeed() : void
      {
         if(_draggedSeed)
         {
            _draggedSeed.removeEventListener("mouseDown",onSeedsDragDown);
            _draggedSeed.removeEventListener("mouseUp",onSeedsClickStartUp);
            _draggedSeed.removeEventListener("mouseMove",onSeedMove);
            _draggedSeed.stopDrag();
            if(_draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_draggedSeed);
            }
            _draggedSeed = null;
         }
      }
      
      private function setupInventoryWindows() : void
      {
         var _loc6_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:Array = null;
         _mediaItems = [];
         for(var _loc2_ in _seedsInventory)
         {
            _loc6_ = QuestManager.getNPCDef(int(_loc2_));
            if(_loc6_)
            {
               _loc3_ = int(_loc6_.mediaRefId);
               _loc4_ = GuiManager.mainHud["inventoriesWindow" + _loc7_];
               if(_loc4_ != null && _loc4_.numChildren > 0)
               {
                  _loc8_ = _loc4_.getChildAt(0);
                  if(_loc8_.hasOwnProperty("txt"))
                  {
                     _loc5_ = int(_seedsInventory[_loc2_].count);
                     _loc1_ = int(_seedsInventory[_loc2_].max);
                     _loc8_.txt.text = _loc5_ + "/" + _loc1_;
                     if(_loc5_ == 0)
                     {
                        _loc9_ = [];
                        _loc9_ = _loc9_.concat([0.33,0.33,0.33,0,0]);
                        _loc9_ = _loc9_.concat([0.33,0.33,0.33,0,0]);
                        _loc9_ = _loc9_.concat([0.33,0.33,0.33,0,0]);
                        _loc9_ = _loc9_.concat([0,0,0,1,0]);
                        _loc8_.filters = [new ColorMatrixFilter(_loc9_)];
                        _loc4_.mouseEnabled = false;
                        _loc4_.mouseChildren = false;
                     }
                     else
                     {
                        if(_loc5_ >= _loc1_)
                        {
                           _loc8_.gotoAndPlay("on");
                        }
                        _loc8_.filters = null;
                        _loc4_.mouseEnabled = true;
                        _loc4_.mouseChildren = true;
                     }
                     _loc7_++;
                     continue;
                  }
               }
               if(_loc3_ != 0)
               {
                  _mediaHelper = new MediaHelper();
                  _mediaHelper.init(_loc3_,onSeedLoaded,{
                     "index":_loc7_,
                     "contIcon":true,
                     "defId":int(_loc2_)
                  });
                  _mediaItems[_loc7_] = _mediaHelper;
                  _mediaHelper = new MediaHelper();
                  _mediaHelper.init(_loc3_,onSeedLoaded,{
                     "index":_loc7_,
                     "contIcon":false,
                     "defId":int(_loc2_)
                  });
                  _mediaItems[_loc7_ + 1] = _mediaHelper;
                  _loc7_++;
               }
            }
         }
         while(_loc7_ < 5)
         {
            _loc4_ = GuiManager.mainHud["inventoriesWindow" + _loc7_];
            if(_loc4_ != null)
            {
               _loc4_.mouseEnabled = false;
               _loc4_.mouseChildren = false;
               _loc4_.visible = false;
            }
            _loc7_++;
         }
      }
      
      private function onSeedLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Array = null;
         if(param1)
         {
            if(param1.hasOwnProperty("setAsIcon"))
            {
               param1.setAsIcon();
            }
            if(param1.passback.contIcon)
            {
               if(param1.hasOwnProperty("getNPC"))
               {
                  _loc2_ = GETDEFINITIONBYNAME("vftCont");
               }
               else
               {
                  _loc2_ = GETDEFINITIONBYNAME("vftCont_noCount");
               }
               _loc4_ = GuiManager.mainHud["inventoriesWindow" + param1.passback.index];
               if(_seedsInventory[param1.passback.defId])
               {
                  _loc5_ = int(_seedsInventory[param1.passback.defId].count);
                  _loc3_ = int(_seedsInventory[param1.passback.defId].max);
                  if(param1.hasOwnProperty("getNPC"))
                  {
                     _loc2_.itemWindow.addChild(param1.getNPC());
                     _loc2_.txt.text = _loc5_ + "/" + _loc3_;
                     _loc2_.txt.visible = true;
                     _loc4_.dragable = true;
                     if(_loc5_ == 0)
                     {
                        _loc6_ = [];
                        _loc6_ = _loc6_.concat([0.33,0.33,0.33,0,0]);
                        _loc6_ = _loc6_.concat([0.33,0.33,0.33,0,0]);
                        _loc6_ = _loc6_.concat([0.33,0.33,0.33,0,0]);
                        _loc6_ = _loc6_.concat([0,0,0,1,0]);
                        _loc2_.filters = [new ColorMatrixFilter(_loc6_)];
                        if(_loc4_ != null)
                        {
                           _loc4_.mouseEnabled = false;
                           _loc4_.mouseChildren = false;
                        }
                     }
                     else
                     {
                        if(_loc5_ >= _loc3_)
                        {
                           _loc2_.gotoAndPlay("on");
                        }
                        _loc2_.filters = null;
                        if(_loc4_ != null)
                        {
                           _loc4_.mouseEnabled = true;
                           _loc4_.mouseChildren = true;
                        }
                     }
                  }
                  else
                  {
                     _loc2_.itemWindow.addChild(param1);
                     _loc4_.mouseEnabled = true;
                     _loc4_.mouseChildren = true;
                     _loc4_.dragable = false;
                  }
                  if(_loc4_ != null)
                  {
                     while(_loc4_.numChildren > 0)
                     {
                        _loc4_.removeChildAt(0);
                     }
                     _loc4_.addChild(_loc2_);
                     _loc4_.addEventListener("mouseDown",onSeedsClickStart,false,0,true);
                     _loc4_.visible = true;
                  }
               }
            }
            else if(GuiManager.mainHud["inventoriesWindow" + param1.passback.index] != null)
            {
               GuiManager.mainHud["inventoriesWindow" + param1.passback.index].dragIcon = param1;
            }
         }
      }
      
      private function onSeedsClickStart(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _clickStartX = param1.stageX;
         _clickStartY = param1.stageY;
         if(param1.currentTarget.dragable)
         {
            if(_draggedSeed == null || _draggedSeed.windowName != param1.currentTarget.name)
            {
               if(_draggedSeed && _draggedSeed.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_draggedSeed);
               }
               _draggedSeed = param1.currentTarget.dragIcon.getNPC();
               _draggedSeed.custom = {
                  "prevPositionX":0,
                  "prevPositionY":0,
                  "xOut":false,
                  "currWindow":param1.currentTarget
               };
               _draggedSeed.addEventListener("mouseUp",onSeedsClickStartUp,false,0,true);
               _draggedSeed.addEventListener("mouseMove",onSeedMove,false,0,true);
               _draggedSeed.addEventListener("mouseDown",onSeedsDragDown,false,0,true);
               _draggedSeed.x = param1.currentTarget.x;
               _draggedSeed.y = param1.currentTarget.y;
               _draggedSeed.custom.prevPositionX = 0;
               _draggedSeed.custom.prevPositionY = 0;
               _draggedSeed.custom.xOut = false;
               param1.currentTarget.dragIcon.setAsIcon();
               _draggedSeed.passback = param1.currentTarget.dragIcon.passback;
               GuiManager.guiLayer.addChild(_draggedSeed);
            }
            _draggedSeed.startDrag(true);
            if(_draggedSeed.passback.defId == 564)
            {
               QuestManager.playSound("ajq_SporeSelect");
            }
            else if(_draggedSeed.passback.defId == 578)
            {
               QuestManager.playSound("ajq_PeckSeedSelect");
            }
            else
            {
               QuestManager.playSound("ajq_boomSeedSelect");
            }
         }
         else
         {
            if(!_satchelCont)
            {
               _satchelCont = GETDEFINITIONBYNAME("craftSatchelCont");
            }
            if(!_combinedCurrencyWindow)
            {
               _combinedCurrencyWindow = new WindowAndScrollbarGenerator();
               _combinedCurrencyWindow.init(_satchelCont.itemWindow.width,_satchelCont.itemWindow.height,-25,0,1,5,0,0,3,0,1.5,ItemWindowSatchel,[4143,4138,4144,4142,4141,4140,4139],"",0,null,{
                  "scale":0.7,
                  "frame":"adv"
               });
               _satchelCont.itemWindow.addChild(_combinedCurrencyWindow);
               _satchelCont.x = param1.currentTarget.x - param1.currentTarget.width * 0.5;
               _satchelCont.y = param1.currentTarget.y + param1.currentTarget.height * 0.25 - 5;
               GuiManager.guiLayer.addChildAt(_satchelCont,GuiManager.guiLayer.getChildIndex(param1.currentTarget.parent as MovieClip));
            }
            else if(_satchelCont.visible)
            {
               _satchelCont.visible = false;
            }
            else
            {
               _combinedCurrencyWindow.callUpdateInWindow();
               _satchelCont.visible = true;
            }
         }
      }
      
      private function onSeedsDragDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onSeedsClickStartUp(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(Math.abs(_clickStartX - param1.stageX) > 2 || Math.abs(_clickStartY - param1.stageY) > 2)
         {
            onSeedsClickEnd(param1);
         }
         else if(_draggedSeed != null)
         {
            _clickStartX = -99999;
            _clickStartY = -99999;
         }
      }
      
      private function onSeedMove(param1:MouseEvent) : void
      {
         var _loc5_:Point = null;
         param1.stopPropagation();
         if(Math.abs(_clickStartX - param1.stageX) > 2 || Math.abs(_clickStartY - param1.stageY) > 2)
         {
            _clickStartX = -99999;
            _clickStartY = -99999;
         }
         var _loc2_:Number = param1.stageX - _draggedSeed.custom.prevPositionX;
         var _loc3_:Number = param1.stageY - _draggedSeed.custom.prevPositionY;
         var _loc4_:Number = _loc2_ * _loc2_ + _loc3_ * _loc3_;
         if(_loc4_ > 9)
         {
            _draggedSeed.custom.prevPositionX = param1.stageX;
            _draggedSeed.custom.prevPositionY = param1.stageY;
            _loc5_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            if(QuestManager.validatePlantSeedLocation(_loc5_) == false)
            {
               if(!param1.currentTarget.custom.xOut)
               {
                  param1.currentTarget.custom.currWindow.dragIcon.setAsIconX();
                  param1.currentTarget.custom.xOut = true;
               }
            }
            else if(param1.currentTarget.custom.xOut)
            {
               param1.currentTarget.custom.currWindow.dragIcon.setAsIcon();
               param1.currentTarget.custom.xOut = false;
            }
         }
      }
      
      private function onSeedsClickEnd(param1:MouseEvent) : void
      {
         var _loc3_:Point = null;
         var _loc2_:Boolean = false;
         param1.stopPropagation();
         if(_draggedSeed)
         {
            _loc3_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            _loc2_ = _draggedSeed.hitTestObject(_draggedSeed.custom.currWindow);
            if(!_loc2_)
            {
               if(QuestManager.validatePlantSeedLocation(_loc3_))
               {
                  QuestXtCommManager.sendPlantSeed(_draggedSeed.passback.defId,_loc3_.x,_loc3_.y);
                  return;
               }
            }
            removeLastDraggedSeed();
         }
      }
   }
}

