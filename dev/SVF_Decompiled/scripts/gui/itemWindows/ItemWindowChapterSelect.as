package gui.itemWindows
{
   import localization.LocalizationManager;
   import movie.MovieNode;
   
   public class ItemWindowChapterSelect extends ItemWindowBase
   {
      private var _currMovieNodeDef:MovieNode;
      
      private var _isGray:Boolean;
      
      private var _baseDefId:int;
      
      public function ItemWindowChapterSelect(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super(2162,param1,param2,param3,param4,param5,param6,param7,param8);
         _currMovieNodeDef = MovieNode(param2);
         _baseDefId = param9.baseDefId;
      }
      
      public function getMovieNodeDef() : MovieNode
      {
         return _currMovieNodeDef;
      }
      
      public function activateGrayState(param1:Boolean) : void
      {
         _isGray = param1;
         _window.activateGrayState(param1);
      }
      
      public function get isGray() : Boolean
      {
         return _isGray;
      }
      
      override protected function onWindowLoadCallback() : void
      {
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
         }
         super.onWindowLoadCallback();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:Boolean = false;
         if(_currMovieNodeDef.defId != _baseDefId && !gMainFrame.userInfo.userVarCache.isBitSet(_currMovieNodeDef.userVarId,_currMovieNodeDef.bitIndex))
         {
            if(_currMovieNodeDef.bitIndex > 0 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(_currMovieNodeDef.userVarId,_currMovieNodeDef.bitIndex - 1)))
            {
               activateGrayState(false);
               _loc1_ = true;
            }
            else
            {
               activateGrayState(true);
            }
         }
         if(_currMovieNodeDef.thisChapterHasGift && (_loc1_ || _isGray))
         {
            _window.btnCont.showGift(true);
         }
         else
         {
            _window.btnCont.showGift(false);
         }
         var _loc2_:String = LocalizationManager.translateIdOnly(_currMovieNodeDef.streamTitleId);
         if(_isGray)
         {
            _loc2_ = _loc2_.slice(0,_loc2_.indexOf(":"));
         }
         LocalizationManager.updateToFit(_window.btnCont.mouse.up.txt,_loc2_);
         LocalizationManager.updateToFit(_window.btnCont.gray.txt,_loc2_);
      }
      
      override protected function addEventListeners() : void
      {
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
   }
}

