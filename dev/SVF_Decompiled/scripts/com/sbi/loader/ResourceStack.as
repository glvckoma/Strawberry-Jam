package com.sbi.loader
{
   import com.sbi.debug.DebugUtility;
   import flash.display.LoaderInfo;
   
   public class ResourceStack
   {
      public static var hudAssetsLoaderInfo:LoaderInfo;
      
      private var _stack:Array;
      
      private var _callback:Function;
      
      private var _path:String;
      
      private var _openFile:Function;
      
      public function ResourceStack(param1:String, param2:Function)
      {
         super();
         _path = param1;
         _openFile = param2;
         _stack = [];
      }
      
      public function pushFile(param1:String, param2:Boolean = false) : void
      {
         _stack.push({
            "type":"file",
            "data":param1,
            "isBlocking":param2,
            "inProgress":false
         });
      }
      
      public function pushClass(param1:IResourceStackable, param2:Boolean = false) : void
      {
         _stack.push({
            "type":"class",
            "data":param1,
            "isBlocking":param2,
            "inProgress":false
         });
      }
      
      public function start(param1:Function) : void
      {
         _callback = param1;
         fifo();
      }
      
      private function fifo() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc1_:int = int(_stack.length);
         DebugUtility.debugTrace("ResourceStack fifo len:" + _loc1_);
         if(!_loc1_)
         {
            DebugUtility.debugTrace("ResourceStack _callback:" + _callback);
            if(_callback != null)
            {
               _callback();
               _callback = null;
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc3_ = _stack[_loc2_];
               DebugUtility.debugTrace("ResourceStack fifo next - o:" + _loc3_ + " o.inProgress:" + _loc3_.inProgress + " o.type:" + _loc3_.type + " o.data:" + _loc3_.data + " o.isBlocking:" + _loc3_.isBlocking);
               if(!_loc3_.inProgress)
               {
                  _loc3_.inProgress = true;
                  switch(_loc3_.type)
                  {
                     case "file":
                        loadFile(_loc3_.data);
                        break;
                     case "class":
                        _loc3_.data.init(onInitClassComplete);
                  }
                  _loc2_ = -1;
                  _loc1_ = int(_stack.length);
               }
               else if(_loc3_.isBlocking)
               {
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function loadFile(param1:String) : void
      {
         var _loc2_:String = _path + param1;
         _openFile(_loc2_,onLoadComplete,onLoadProgress);
      }
      
      private function onLoadComplete(param1:LoaderEvent) : void
      {
         if(param1.status)
         {
            DebugUtility.debugTrace("ResourceStack onLoadComplete e:" + param1 + " name:" + param1.entry.name);
            if(param1.entry.name == "assets/HUDAssets.swf")
            {
               hudAssetsLoaderInfo = param1.entry.loader.contentLoaderInfo;
            }
            removeResource("file",param1.entry.name);
            fifo();
            return;
         }
         throw new Error("could not load required resource!!! msg:" + param1.message);
      }
      
      private function onLoadProgress(param1:LoaderEvent) : void
      {
      }
      
      private function onInitClassComplete(param1:IResourceStackable) : void
      {
         removeResource("class",param1);
         fifo();
      }
      
      private function removeResource(param1:String, param2:*) : void
      {
         var _loc5_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:int = int(_stack.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = _stack[_loc5_];
            if(_loc3_.type == param1 && _loc3_.data == param2)
            {
               _stack.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
      }
   }
}

