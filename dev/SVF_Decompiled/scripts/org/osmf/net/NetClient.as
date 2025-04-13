package org.osmf.net
{
   import flash.utils.Dictionary;
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class NetClient extends Proxy
   {
      private var handlers:Dictionary = new Dictionary();
      
      public function NetClient()
      {
         super();
      }
      
      public function addHandler(param1:String, param2:Function, param3:int = 0) : void
      {
         var _loc5_:Boolean = false;
         var _loc7_:int = 0;
         var _loc4_:Object = null;
         var _loc6_:Array = !!handlers.hasOwnProperty(param1) ? handlers[param1] : (handlers[param1] = []);
         if(_loc6_.indexOf(param2) == -1)
         {
            _loc5_ = false;
            param3 = Math.max(0,param3);
            if(param3 > 0)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  _loc4_ = _loc6_[_loc7_];
                  if(_loc4_.priority < param3)
                  {
                     _loc6_.splice(_loc7_,0,{
                        "handler":param2,
                        "priority":param3
                     });
                     _loc5_ = true;
                     break;
                  }
                  _loc7_++;
               }
            }
            if(!_loc5_)
            {
               _loc6_.push({
                  "handler":param2,
                  "priority":param3
               });
            }
         }
      }
      
      public function removeHandler(param1:String, param2:Function) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc3_:Object = null;
         if(handlers.hasOwnProperty(param1))
         {
            _loc4_ = handlers[param1];
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc3_ = _loc4_[_loc5_];
               if(_loc3_.handler == param2)
               {
                  _loc4_.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
         }
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         return invokeHandlers(param1,rest);
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         var result:*;
         var name:* = param1;
         if(handlers.hasOwnProperty(name))
         {
            result = function():*
            {
               return invokeHandlers(arguments.callee.name,arguments);
            };
            result.name = name;
         }
         return result;
      }
      
      override flash_proxy function hasProperty(param1:*) : Boolean
      {
         return handlers.hasOwnProperty(param1);
      }
      
      private function invokeHandlers(param1:String, param2:Array) : *
      {
         var _loc3_:Array = null;
         var _loc5_:Array = null;
         if(handlers.hasOwnProperty(param1))
         {
            _loc3_ = [];
            _loc5_ = handlers[param1];
            for each(var _loc4_ in _loc5_)
            {
               _loc3_.push(_loc4_.handler.apply(null,param2));
            }
         }
         return _loc3_;
      }
   }
}

