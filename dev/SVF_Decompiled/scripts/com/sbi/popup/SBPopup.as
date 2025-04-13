package com.sbi.popup
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public dynamic class SBPopup extends Sprite
   {
      public var skin:SBPopupSkin;
      
      public var content:DisplayObject;
      
      public var popupFilters:Array;
      
      public var _enabled:Boolean = true;
      
      public var _selected:Boolean = true;
      
      public var _modal:Boolean = false;
      
      public var _darken:Boolean = false;
      
      public var suppressMouseDown:Boolean = false;
      
      public var closeCallback:Function;
      
      public var restoreLastPos:Boolean = true;
      
      public var lastPosX:Number;
      
      public var lastPosY:Number;
      
      public var draggable:Boolean = true;
      
      public var soundsEnabled:Boolean = true;
      
      public var bxClosesPopup:Boolean = true;
      
      public function SBPopup(param1:DisplayObjectContainer, param2:MovieClip, param3:DisplayObject, param4:Boolean = true, param5:Boolean = true, param6:Boolean = false, param7:Boolean = false, param8:Boolean = false, param9:String = null, param10:Number = undefined, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Array = null, param15:Array = null)
      {
         super();
         skin = new SBPopupSkin(param2);
         this.addChild(skin.s);
         if(param3)
         {
            content = param3;
            content.name = "content";
            content.x = skin.s["c"].x;
            content.y = skin.s["c"].y;
            content.width = skin.s["c"].width;
            content.height = skin.s["c"].height;
            skin.s.addChildAt(content,skin.s.getChildIndex(skin.s["c"]));
         }
         skin.s["c"].visible = false;
         if(skin.s.getChildByName("bx"))
         {
            skin.s["bx"].addEventListener("mouseDown",bxHandler,false,0,true);
         }
         param1.addChild(this);
         visible = false;
         width = !!param12 ? param12 : skin.s.width;
         height = !!param13 ? param13 : skin.s.height;
         if(parent.stage)
         {
            x = !!param10 ? param10 : 900 * 0.5;
            y = !!param11 ? param11 : 550 * 0.5;
         }
         lastPosX = x;
         lastPosY = y;
         modal = param6;
         draggable = param7;
         enabled = param5;
         suppressMouseDown = false;
         popupFilters = param14;
         SBPopupManager.popups.push(this);
         if(param8)
         {
            _darken = true;
         }
         if(param4)
         {
            open();
         }
      }
      
      public static function isChildOf(param1:DisplayObjectContainer, param2:DisplayObjectContainer, param3:DisplayObject) : Boolean
      {
         var _loc4_:* = param3;
         while(_loc4_ != param2)
         {
            if(_loc4_ == param1)
            {
               return true;
            }
            _loc4_ = _loc4_.parent;
         }
         return false;
      }
      
      public function get darken() : Boolean
      {
         return _darken;
      }
      
      public function get selected() : Boolean
      {
         return _selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(param1)
         {
         }
         _selected = param1;
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(param1)
         {
            mouseChildren = true;
         }
         else
         {
            mouseChildren = false;
         }
         _enabled = param1;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1)
         {
            if(_modal)
            {
               SBPopupManager.modalSBPopup = this;
            }
            if(_darken && SBPopupManager.darken != null)
            {
               SBPopupManager.darken(this);
            }
         }
         else
         {
            if(_modal && SBPopupManager.modalSBPopup == this)
            {
               SBPopupManager.modalSBPopup = null;
            }
            if(!_darken && SBPopupManager.lighten != null)
            {
               SBPopupManager.lighten(this);
            }
         }
         super.visible = param1;
      }
      
      public function get modal() : Boolean
      {
         return _modal && visible;
      }
      
      public function set modal(param1:Boolean) : void
      {
         if(param1)
         {
            if(visible)
            {
               if(SBPopupManager.modalSBPopup && SBPopupManager.modalSBPopup != this && SBPopupManager.modalSBPopup.modal)
               {
                  throw new Error("Attempted to make two or more modal dialogs active at once!");
               }
               SBPopupManager.modalSBPopup = this;
            }
         }
         else if(SBPopupManager.modalSBPopup == this)
         {
            SBPopupManager.modalSBPopup = null;
         }
         _modal = param1;
      }
      
      public function addListeners() : void
      {
         addEventListener("mouseDown",mouseDownHandler,false,0,true);
         addEventListener("mouseUp",mouseUpHandler,false,0,true);
      }
      
      public function removeListeners() : void
      {
         removeEventListener("mouseDown",mouseDownHandler);
         removeEventListener("mouseUp",mouseUpHandler);
      }
      
      public function open() : void
      {
         if(visible)
         {
            trace("WARNING: Tried to open an already opened popup... ignored...");
            return;
         }
         if(_darken)
         {
            if(SBPopupManager && SBPopupManager.darken != null)
            {
               SBPopupManager.darken(this);
            }
         }
         addListeners();
         setFilters(popupFilters);
         visible = true;
         if(parent)
         {
            bringToFront();
         }
         if(_modal)
         {
            SBPopupManager.modalSBPopup = this;
         }
      }
      
      public function close() : void
      {
         if(!visible)
         {
            trace("WARNING: Tried to close an already closed popup... ignored...");
            return;
         }
         if(_darken)
         {
            if(SBPopupManager && SBPopupManager.lighten != null)
            {
               SBPopupManager.lighten(this);
            }
         }
         removeListeners();
         setFilters([]);
         lastPosX = x;
         lastPosY = y;
         visible = false;
         if(_modal)
         {
            if(SBPopupManager.modalSBPopup == this)
            {
               SBPopupManager.modalSBPopup = null;
            }
         }
         if(closeCallback != null)
         {
            closeCallback();
         }
      }
      
      public function destroy() : void
      {
         if(visible)
         {
            close();
         }
         if(skin && skin.s)
         {
            removeChild(skin.s);
            if(content)
            {
               skin.s.removeChild(content);
               content = null;
            }
            skin.s = null;
         }
         closeCallback = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         var _loc1_:int = int(SBPopupManager.popups.indexOf(this));
         if(_loc1_ > 0)
         {
            SBPopupManager.popups.splice(_loc1_,1);
         }
      }
      
      public function setFilters(param1:Array = null) : void
      {
      }
      
      public function bxHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(visible && bxClosesPopup)
         {
            close();
         }
      }
      
      public function bringContentToFront() : void
      {
         skin.s.setChildIndex(content,skin.s.getChildIndex(skin.s["c"]));
      }
      
      public function mouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(suppressMouseDown)
         {
            suppressMouseDown = false;
            return;
         }
         if(!(param1.target is DisplayObject))
         {
            throw new Error("mouseDownHandler mouse event got a non-DisplayObject object!");
         }
         if(draggable && SBPopupManager.checkModalSBPopup(this,true) && (SBPopup.isChildOf(skin.s["ba"],this,DisplayObject(param1.target)) || param1.target == content || content is DisplayObjectContainer && DisplayObjectContainer(content).getChildByName("titleDragBar") && param1.target == content["titleDragBar"]))
         {
            startDrag();
         }
      }
      
      public function bringToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function mouseUpHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!(param1.target is DisplayObject))
         {
            throw new Error("mouseDownHandler mouse event got a non-DisplayObject object!");
         }
         if(draggable && SBPopupManager.checkModalSBPopup(this,false) && (SBPopup.isChildOf(skin.s["ba"],this,DisplayObject(param1.target)) || param1.target == content || content is DisplayObjectContainer && DisplayObjectContainer(content).getChildByName("titleDragBar") && param1.target == content["titleDragBar"]))
         {
            stopDrag();
         }
      }
      
      public function get closeBtn() : MovieClip
      {
         return skin.s["bx"];
      }
   }
}

