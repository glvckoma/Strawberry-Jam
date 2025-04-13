package newspaper
{
   public class NewspaperData
   {
      private var _defId:int;
      
      private var _timeSeen:int;
      
      public function NewspaperData(param1:Object)
      {
         super();
         _defId = param1.defId;
         _timeSeen = param1.ts;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get timeSeen() : int
      {
         return _timeSeen;
      }
      
      public function set timeSeen(param1:int) : void
      {
         _timeSeen = param1;
      }
   }
}

