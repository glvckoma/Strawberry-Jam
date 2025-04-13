package com.greensock.plugins
{
   import com.greensock.TweenLite;
   
   public class HexColorsPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected var _colors:Array;
      
      public function HexColorsPlugin()
      {
         super("hexColors");
         _overwriteProps = [];
         _colors = [];
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         for(var _loc4_ in param2)
         {
            _initColor(param1,_loc4_,uint(param2[_loc4_]));
         }
         return true;
      }
      
      public function _initColor(param1:Object, param2:String, param3:uint) : void
      {
         var _loc8_:* = false;
         var _loc5_:* = 0;
         _loc8_ = typeof param1[param2] == "function";
         var _loc7_:uint = uint(!_loc8_ ? param1[param2] : param1[param2.indexOf("set") || !("get" + param2.substr(3) in param1) ? param2 : "get" + param2.substr(3)]());
         if(_loc7_ != param3)
         {
            _loc5_ = uint(_loc7_ >> 16);
            var _loc6_:uint = uint(_loc7_ >> 8 & 0xFF);
            var _loc4_:uint = uint(_loc7_ & 0xFF);
            _colors[_colors.length] = new ColorProp(param1,param2,_loc8_,_loc5_,(param3 >> 16) - _loc5_,_loc6_,(param3 >> 8 & 0xFF) - _loc6_,_loc4_,(param3 & 0xFF) - _loc4_);
            _overwriteProps[_overwriteProps.length] = param2;
         }
      }
      
      override public function _kill(param1:Object) : Boolean
      {
         var _loc2_:int = int(_colors.length);
         while(_loc2_--)
         {
            if(param1[_colors[_loc2_].p] != null)
            {
               _colors.splice(_loc2_,1);
            }
         }
         return super._kill(param1);
      }
      
      override public function setRatio(param1:Number) : void
      {
         var _loc3_:ColorProp = null;
         var _loc2_:Number = NaN;
         var _loc4_:int = int(_colors.length);
         while(true)
         {
            _loc4_--;
            if(_loc4_ <= -1)
            {
               break;
            }
            _loc3_ = _colors[_loc4_];
            _loc2_ = _loc3_.rs + param1 * _loc3_.rc << 16 | _loc3_.gs + param1 * _loc3_.gc << 8 | _loc3_.bs + param1 * _loc3_.bc;
            if(_loc3_.f)
            {
               _loc3_.t[_loc3_.p](_loc2_);
            }
            else
            {
               _loc3_.t[_loc3_.p] = _loc2_;
            }
         }
      }
   }
}

class ColorProp
{
   public var t:Object;
   
   public var p:String;
   
   public var f:Boolean;
   
   public var rs:int;
   
   public var rc:int;
   
   public var gs:int;
   
   public var gc:int;
   
   public var bs:int;
   
   public var bc:int;
   
   public function ColorProp(param1:Object, param2:String, param3:Boolean, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int)
   {
      super();
      this.t = param1;
      this.p = param2;
      this.f = param3;
      this.rs = param4;
      this.rc = param5;
      this.gs = param6;
      this.gc = param7;
      this.bs = param8;
      this.bc = param9;
   }
}
