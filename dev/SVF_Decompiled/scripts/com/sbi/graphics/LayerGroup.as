package com.sbi.graphics
{
   public class LayerGroup
   {
      private var _layers:Array;
      
      private var _paintedFrames:Array;
      
      private var _ttl:int;
      
      private var _checkColors:Boolean;
      
      public function LayerGroup()
      {
         super();
         _layers = [];
         _paintedFrames = [];
         _checkColors = true;
      }
      
      public function destroy() : void
      {
         for each(var _loc1_ in _paintedFrames)
         {
         }
         _layers = null;
         _paintedFrames = null;
      }
      
      public function invalidate() : void
      {
         for each(var _loc1_ in _paintedFrames)
         {
            for each(var _loc2_ in _loc1_)
            {
               _loc2_.isValid = false;
            }
         }
      }
      
      public function get length() : int
      {
         var _loc1_:Object = _layers[0];
         if(!_loc1_)
         {
            _loc1_ = _layers[1];
         }
         return !_loc1_ ? 0 : _loc1_.o.f.length;
      }
      
      public function get layers() : Array
      {
         return _layers;
      }
      
      public function get paintedFrames() : Array
      {
         return _paintedFrames;
      }
      
      public function resetTtl() : void
      {
         _ttl = 30;
      }
      
      public function decrementTtl() : int
      {
         return _ttl--;
      }
      
      public function get checkColors() : Boolean
      {
         return _checkColors;
      }
      
      public function set checkColors(param1:Boolean) : void
      {
         _checkColors = param1;
      }
   }
}

