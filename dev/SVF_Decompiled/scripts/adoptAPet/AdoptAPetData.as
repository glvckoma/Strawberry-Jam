package adoptAPet
{
   import Enums.AdoptAPetDef;
   
   public class AdoptAPetData
   {
      public static var LAST_INV_ID:int = 0;
      
      private var _invId:int;
      
      private var _defId:int;
      
      private var _time:Number;
      
      private var _hasBeenSeen:Boolean;
      
      private var _series:int;
      
      public function AdoptAPetData(param1:Object)
      {
         super();
         var _loc2_:AdoptAPetDef = null;
         if(param1 is int)
         {
            _invId = ++LAST_INV_ID;
            _defId = param1 as int;
            _time = new Date().valueOf() / 1000;
            _hasBeenSeen = false;
         }
         else
         {
            _invId = param1.invId;
            _defId = param1.defId;
            _time = param1.ts;
            _hasBeenSeen = param1.hasSeen;
            if(!("skipInvIdUpdate" in param1))
            {
               if(_invId > LAST_INV_ID)
               {
                  LAST_INV_ID = _invId;
               }
            }
         }
         _loc2_ = AdoptAPetManager.getAdoptAPetDef(_defId);
         if(_loc2_)
         {
            _series = _loc2_.series;
         }
         else
         {
            _series = 1;
         }
      }
      
      public static function defaultAdoptAPetData(param1:int, param2:int) : Object
      {
         var _loc3_:AdoptAPetDef = AdoptAPetManager.getAdoptAPetDef(param1);
         var _loc4_:int = int(!!_loc3_ ? _loc3_.series : 1);
         return {
            "invId":param2,
            "defId":param1,
            "ts":0,
            "hasSeen":true,
            "skipInvIdUpdate":true,
            "series":_loc4_
         };
      }
      
      public function get invId() : int
      {
         return _invId;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get time() : Number
      {
         return _time;
      }
      
      public function get hasBeenSeen() : Boolean
      {
         return _hasBeenSeen;
      }
      
      public function set hasBeenSeen(param1:Boolean) : void
      {
         _hasBeenSeen = param1;
      }
      
      public function get series() : int
      {
         return _series;
      }
      
      public function set series(param1:int) : void
      {
         _series = param1;
      }
   }
}

