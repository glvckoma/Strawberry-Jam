package it.gotoandplay.smartfoxserver.handlers
{
   import it.gotoandplay.smartfoxserver.SFSEvent;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
   
   public class ExtHandler implements IMessageHandler
   {
      private var sfs:SmartFoxClient;
      
      public function ExtHandler(param1:SmartFoxClient)
      {
         super();
         this.sfs = param1;
      }
      
      public function handleMessage(param1:Object, param2:String) : void
      {
         var _loc6_:Object = null;
         var _loc3_:SFSEvent = null;
         var _loc9_:XML = null;
         var _loc4_:String = null;
         var _loc8_:int = 0;
         var _loc7_:String = null;
         var _loc5_:Object = null;
         if(param2 == "xml")
         {
            _loc9_ = param1 as XML;
            _loc4_ = _loc9_.body.@action;
            _loc8_ = int(_loc9_.body.@id);
            if(_loc4_ == "xtRes")
            {
               _loc7_ = _loc9_.body.toString();
               _loc5_ = ObjectSerializer.getInstance().deserialize(_loc7_);
               _loc6_ = {};
               _loc6_.dataObj = _loc5_;
               _loc6_.type = param2;
               _loc3_ = new SFSEvent("onExtensionResponse",_loc6_);
               sfs.dispatchEvent(_loc3_);
            }
         }
         else if(param2 == "json")
         {
            _loc6_ = {};
            _loc6_.dataObj = param1.o;
            _loc6_.type = param2;
            _loc3_ = new SFSEvent("onExtensionResponse",_loc6_);
            sfs.dispatchEvent(_loc3_);
         }
         else if(param2 == "str")
         {
            _loc6_ = {};
            _loc6_.dataObj = param1;
            _loc6_.type = param2;
            _loc3_ = new SFSEvent("onExtensionResponse",_loc6_);
            sfs.dispatchEvent(_loc3_);
         }
      }
   }
}

