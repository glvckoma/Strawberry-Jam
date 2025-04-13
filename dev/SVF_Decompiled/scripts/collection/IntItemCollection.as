package collection
{
   public class IntItemCollection extends BaseTypedCollection
   {
      public function IntItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getIntItem(param1:uint) : int
      {
         return typedItems[param1] as int;
      }
      
      public function setIntItem(param1:uint, param2:int) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushIntItem(param1:int) : uint
      {
         return pushCommon(param1);
      }
      
      public function hasIntItem(param1:uint) : Boolean
      {
         return typedItems[param1] != null;
      }
   }
}

