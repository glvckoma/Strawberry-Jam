package collection
{
   import Enums.StreamDef;
   
   public class StreamDefCollection extends BaseTypedCollection
   {
      public function StreamDefCollection()
      {
         super();
      }
      
      public function getStreamDefItem(param1:uint) : StreamDef
      {
         return typedItems[param1] as StreamDef;
      }
      
      public function setStreamDefItem(param1:uint, param2:StreamDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushStreamDefItem(param1:StreamDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

