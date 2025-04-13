package Enums
{
   public class StreamDef
   {
      private var _defId:int;
      
      private var _thumbnailId:int;
      
      private var _baseTitleId:int;
      
      private var _individualTitleId:int;
      
      private var _status:int;
      
      private var _subtitleId:int;
      
      public function StreamDef(param1:int, param2:int = 0, param3:String = "", param4:int = 0, param5:int = 0)
      {
         super();
         _defId = param1;
         _thumbnailId = param2;
         var _loc6_:Array = param3.split("|");
         _baseTitleId = _loc6_[0];
         if(_loc6_[1])
         {
            _individualTitleId = _loc6_[1];
         }
         else
         {
            _individualTitleId = _loc6_[0];
         }
         _status = param4;
         _subtitleId = param5;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get thumbnailId() : int
      {
         return _thumbnailId;
      }
      
      public function get baseTitleId() : int
      {
         return _baseTitleId;
      }
      
      public function get individualTitleId() : int
      {
         return _individualTitleId;
      }
      
      public function get subtitleId() : int
      {
         return _subtitleId;
      }
      
      public function set status(param1:int) : void
      {
         _status = param1;
      }
      
      public function get isOnSale() : Boolean
      {
         return _status == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return _status == 3;
      }
      
      public function get isRare() : Boolean
      {
         return _status == 4;
      }
      
      public function get isNew() : Boolean
      {
         return _status == 1;
      }
   }
}

