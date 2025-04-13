package gui.itemWindows
{
   import flash.display.MovieClip;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   
   public class ItemWindowPlayerWallDecor extends ItemWindowBase
   {
      private var _clone:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currMediaId:int;
      
      private var _loadingSpiral:LoadingSpiral;
      
      public function ItemWindowPlayerWallDecor(param1:Function, param2:Object, param3:String, param4:int, param5:Function, param6:Function, param7:Function, param8:Function, param9:Boolean = false)
      {
         _currMediaId = int(param2);
         super(param2,param1,null,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_mouseDown != null)
         {
            addEventListener("mouseDown",_mouseDown,false,0,true);
         }
      }
      
      public function downToUpState() : void
      {
         if(_window)
         {
            _window.downToUpState();
         }
      }
      
      public function getClone(param1:Function) : MovieClip
      {
         _clone = new MovieClip();
         _loadingSpiral = new LoadingSpiral(_clone);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_currMediaId,onCloneLoaded,param1);
         return _clone;
      }
      
      private function onCloneLoaded(param1:MovieClip) : void
      {
         _loadingSpiral.destroy();
         _clone.addChild(param1);
         if(param1.passback != null)
         {
            param1.passback();
         }
      }
   }
}

