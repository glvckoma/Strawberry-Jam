package gui.itemWindows
{
   import achievement.Achievement;
   import flash.filters.ColorMatrixFilter;
   
   public class ItemWindowWithSeparators extends ItemWindowBase
   {
      private var _sizeCont:Object;
      
      private var _secondaryIndex:int;
      
      private var _myAchievementsByType:Array;
      
      public function ItemWindowWithSeparators(param1:Function, param2:*, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         if(param2.hasOwnProperty("width"))
         {
            _sizeCont = {
               "height":(!!param2.hasOwnProperty("scrollContentHeight") ? param2.scrollContentHeight : param2.height),
               "width":param2.width
            };
         }
         _secondaryIndex = !!param9 ? param9.secondaryIndex as int : 0;
         _myAchievementsByType = !!param9 ? param9.myAchievementsByType : [];
         super(param9 != null && param9.itemClassName != null ? param9.itemClassName : param2,param1,param2,param3,param4,param5,param6,param7,param8,false);
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:int = 0;
         if(_currItem is Achievement)
         {
            if(_myAchievementsByType != null)
            {
               _loc1_ = 0;
               while(_loc1_ < _myAchievementsByType.length)
               {
                  if(_myAchievementsByType[_loc1_].defId == _currItem.defId)
                  {
                     _currItem.image.filters = null;
                     return;
                  }
                  _loc1_++;
               }
            }
            _currItem.image.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
      }
      
      public function get sizeCont() : Object
      {
         return _sizeCont;
      }
      
      public function get secondaryIndex() : int
      {
         return _secondaryIndex;
      }
      
      public function get currItemType() : int
      {
         if(_currItem && _currItem.hasOwnProperty("type"))
         {
            return _currItem.type;
         }
         return -1;
      }
   }
}

