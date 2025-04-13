package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class LoadingSpiral extends MovieClip
   {
      public static const LOADING_SPIRAL_MEDIA_ID:int = 44;
      
      public static var hasBeenLoaded:Boolean;
      
      private var _isDarkenManagersSpiral:Boolean;
      
      private var _loadingSpiral:MovieClip;
      
      private var _loadingSpiralHelper:MediaHelper;
      
      private var _parent:DisplayObjectContainer;
      
      private var _addToParent:Boolean;
      
      private var _displayPercentage:Boolean;
      
      public function LoadingSpiral(param1:DisplayObjectContainer = null, param2:Number = 0, param3:Number = 0, param4:Boolean = false)
      {
         super();
         if(param1)
         {
            _parent = param1;
         }
         _addToParent = true;
         this.x = param2;
         this.y = param3;
         _loadingSpiralHelper = new MediaHelper();
         _loadingSpiralHelper.init(44,loadingSpiralHandler);
         this.addEventListener("mouseDown",onMouseDown,false,0,true);
         this.addEventListener("mouseOver",onMouseOver,false,0,true);
         hasBeenLoaded = false;
         _displayPercentage = param4;
      }
      
      public function destroy() : void
      {
         if(_parent && this.parent == _parent)
         {
            _parent.removeChild(this);
         }
         _addToParent = false;
         if(!_isDarkenManagersSpiral)
         {
            _parent = null;
         }
         _displayPercentage = false;
      }
      
      public function set isDarkenManagersSpiral(param1:Boolean) : void
      {
         _isDarkenManagersSpiral = param1;
      }
      
      public function setNewParent(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = 0, param4:Boolean = false) : void
      {
         _parent = param1;
         _addToParent = true;
         if(_parent && _loadingSpiral)
         {
            _parent.addChild(this);
         }
         if(_loadingSpiral)
         {
            if(param4)
            {
               _loadingSpiral.txt.text = "0%";
               _loadingSpiral.txt.visible = true;
            }
            else
            {
               _loadingSpiral.txt.visible = false;
            }
         }
         this.x = param2;
         this.y = param3;
      }
      
      public function updatePercentText(param1:String) : void
      {
         if(_loadingSpiral)
         {
            if(!_loadingSpiral.txt.visible)
            {
               _loadingSpiral.txt.visible = true;
            }
            _loadingSpiral.txt.text = param1;
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            bringToFront();
         }
      }
      
      private function bringToFront() : void
      {
         if(_parent && this.parent == _parent)
         {
            _parent.setChildIndex(this,_parent.numChildren - 1);
         }
      }
      
      private function loadingSpiralHandler(param1:MovieClip) : void
      {
         if(_addToParent)
         {
            _loadingSpiral = param1;
            _loadingSpiral.txt.text = "0%";
            if(_loadingSpiral)
            {
               this.addChild(_loadingSpiral);
            }
            if(_parent)
            {
               _parent.addChild(this);
            }
            if(!_displayPercentage)
            {
               _loadingSpiral.txt.visible = false;
            }
            else
            {
               _loadingSpiral.txt.visible = true;
            }
            hasBeenLoaded = true;
            _loadingSpiralHelper.destroy();
            _loadingSpiralHelper = null;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

