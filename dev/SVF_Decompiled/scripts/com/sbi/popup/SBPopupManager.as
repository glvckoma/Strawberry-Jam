package com.sbi.popup
{
   import flash.filters.*;
   
   public class SBPopupManager
   {
      public static var enabled:Boolean = true;
      
      public static var _selected:SBPopup;
      
      public static var _modalSBPopup:SBPopup;
      
      public static var _prevModalSBPopup:SBPopup;
      
      public static var darken:Function;
      
      public static var lighten:Function;
      
      public static var popups:Array = [];
      
      public static var nonSBPopups:Array = [];
      
      public function SBPopupManager()
      {
         super();
      }
      
      public static function get selected() : SBPopup
      {
         return _selected;
      }
      
      public static function set selected(param1:SBPopup) : void
      {
         if(param1.selected)
         {
            return;
         }
         param1.selected = true;
         _selected = param1;
      }
      
      public static function get modalSBPopup() : SBPopup
      {
         return _modalSBPopup;
      }
      
      public static function set modalSBPopup(param1:SBPopup) : void
      {
         for each(var _loc2_ in popups)
         {
            if(_loc2_ != param1)
            {
               _loc2_.enabled = param1 == null;
            }
         }
         var _loc3_:SBPopup = _prevModalSBPopup;
         if(param1 && _modalSBPopup && param1 != _modalSBPopup)
         {
            _prevModalSBPopup = _modalSBPopup;
         }
         _modalSBPopup = param1;
         if(_modalSBPopup == null && _loc3_)
         {
            _modalSBPopup = _loc3_;
            _prevModalSBPopup = null;
         }
      }
      
      public static function checkModalSBPopup(param1:SBPopup, param2:Boolean) : Boolean
      {
         if(_modalSBPopup == null)
         {
            return true;
         }
         if(_modalSBPopup != param1)
         {
            if(param2)
            {
               _modalSBPopup.alpha = 0.5;
            }
            else
            {
               _modalSBPopup.alpha = 1;
            }
            return false;
         }
         return true;
      }
      
      public static function getBlurFilter(param1:Number = 2, param2:Number = 2, param3:int = 3) : BlurFilter
      {
         var _loc4_:BlurFilter = new BlurFilter();
         _loc4_.blurX = param1;
         _loc4_.blurY = param2;
         _loc4_.quality = param3;
         return _loc4_;
      }
      
      public static function getColorFilter(param1:Number = 1, param2:Number = 1, param3:Number = 1, param4:Number = 1) : ColorMatrixFilter
      {
         var _loc5_:Array = [];
         _loc5_ = _loc5_.concat([param2,0,0,0,0]);
         _loc5_ = _loc5_.concat([0,param3,0,0,0]);
         _loc5_ = _loc5_.concat([0,0,param4,0,0]);
         _loc5_ = _loc5_.concat([0,0,0,param1,0]);
         return new ColorMatrixFilter(_loc5_);
      }
      
      public static function setAllPopupEffects(param1:Array = null) : void
      {
         for each(var _loc2_ in popups)
         {
            _loc2_.setFilters(param1);
         }
      }
      
      public static function setAllModalPopupEffects(param1:Array = null) : void
      {
         for each(var _loc2_ in popups)
         {
            if(_loc2_.modal)
            {
               _loc2_.setFilters(param1);
            }
         }
      }
      
      public static function closeAll() : void
      {
         modalSBPopup = null;
         for each(var _loc1_ in popups)
         {
            if(_loc1_.visible)
            {
               _loc1_.close();
            }
         }
      }
      
      public static function destroyAll() : void
      {
         modalSBPopup = null;
         for each(var _loc1_ in popups)
         {
            _loc1_.destroy();
         }
         while(popups.length > 0)
         {
            popups.pop();
         }
      }
      
      public static function destroyNonSBPopups() : void
      {
         for each(var _loc1_ in nonSBPopups)
         {
            _loc1_.destroy();
         }
         while(nonSBPopups.length > 0)
         {
            nonSBPopups.pop();
         }
      }
      
      public static function destroySpecificNonSBPopup(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < nonSBPopups.length)
         {
            if(nonSBPopups[_loc2_] == param1)
            {
               nonSBPopups.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
   }
}

