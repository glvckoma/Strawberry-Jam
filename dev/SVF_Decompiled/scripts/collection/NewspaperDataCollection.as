package collection
{
   import newspaper.NewspaperData;
   
   public class NewspaperDataCollection extends BaseTypedCollection
   {
      public function NewspaperDataCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getNewspaperDataItem(param1:uint) : NewspaperData
      {
         return typedItems[param1] as NewspaperData;
      }
      
      public function setNewspaperDataItem(param1:uint, param2:NewspaperData) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushNewspaperDataItem(param1:NewspaperData) : uint
      {
         return pushCommon(param1);
      }
   }
}

