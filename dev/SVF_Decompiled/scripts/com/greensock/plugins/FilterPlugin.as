package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import flash.filters.BitmapFilter;
   import flash.filters.BlurFilter;
   
   public class FilterPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected var _target:Object;
      
      protected var _type:Class;
      
      protected var _filter:BitmapFilter;
      
      protected var _index:int;
      
      protected var _remove:Boolean;
      
      private var _tween:TweenLite;
      
      public function FilterPlugin(param1:String = "", param2:Number = 0)
      {
         super(param1,param2);
      }
      
      protected function _initFilter(param1:*, param2:Object, param3:TweenLite, param4:Class, param5:BitmapFilter, param6:Array) : Boolean
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc11_:HexColorsPlugin = null;
         _target = param1;
         _tween = param3;
         _type = param4;
         var _loc10_:Array = _target.filters;
         var _loc9_:Object = param2 is BitmapFilter ? {} : param2;
         if(_loc9_.index != null)
         {
            _index = _loc9_.index;
         }
         else
         {
            _index = _loc10_.length;
            if(_loc9_.addFilter != true)
            {
               while(--_index > -1 && !(_loc10_[_index] is _type))
               {
               }
            }
         }
         if(_index < 0 || !(_loc10_[_index] is _type))
         {
            if(_index < 0)
            {
               _index = _loc10_.length;
            }
            if(_index > _loc10_.length)
            {
               _loc8_ = _loc10_.length - 1;
               while(true)
               {
                  _loc8_++;
                  if(_loc8_ >= _index)
                  {
                     break;
                  }
                  _loc10_[_loc8_] = new BlurFilter(0,0,1);
               }
            }
            _loc10_[_index] = param5;
            _target.filters = _loc10_;
         }
         _filter = _loc10_[_index];
         _remove = _loc9_.remove == true;
         _loc8_ = int(param6.length);
         while(true)
         {
            _loc8_--;
            if(_loc8_ <= -1)
            {
               break;
            }
            _loc7_ = param6[_loc8_];
            if(_loc7_ in param2 && _filter[_loc7_] != param2[_loc7_])
            {
               if(_loc7_ == "color" || _loc7_ == "highlightColor" || _loc7_ == "shadowColor")
               {
                  _loc11_ = new HexColorsPlugin();
                  _loc11_._initColor(_filter,_loc7_,param2[_loc7_]);
                  _addTween(_loc11_,"setRatio",0,1,_propName);
               }
               else if(_loc7_ == "quality" || _loc7_ == "inner" || _loc7_ == "knockout" || _loc7_ == "hideObject")
               {
                  _filter[_loc7_] = param2[_loc7_];
               }
               else
               {
                  _addTween(_filter,_loc7_,_filter[_loc7_],param2[_loc7_],_propName);
               }
            }
         }
         return true;
      }
      
      override public function setRatio(param1:Number) : void
      {
         super.setRatio(param1);
         var _loc2_:Array = _target.filters;
         if(!(_loc2_[_index] is _type))
         {
            _index = _loc2_.length;
            while(--_index > -1 && !(_loc2_[_index] is _type))
            {
            }
            if(_index == -1)
            {
               _index = _loc2_.length;
            }
         }
         if(param1 == 1 && _remove && _tween._time == _tween._duration && _tween.data != "isFromStart")
         {
            if(_index < _loc2_.length)
            {
               _loc2_.splice(_index,1);
            }
         }
         else
         {
            _loc2_[_index] = _filter;
         }
         _target.filters = _loc2_;
      }
   }
}

