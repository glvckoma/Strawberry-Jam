package collection
{
   import adoptAPet.AdoptAPetData;
   
   public class AdoptAPetDataCollection extends BaseTypedCollection
   {
      public function AdoptAPetDataCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getAdoptAPetDataItem(param1:uint) : AdoptAPetData
      {
         return typedItems[param1] as AdoptAPetData;
      }
      
      public function setAdoptAPetDataItem(param1:uint, param2:AdoptAPetData) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushAdoptAPetDataItem(param1:AdoptAPetData) : uint
      {
         return pushCommon(param1);
      }
   }
}

