package collection
{
   import newspaper.NewspaperDef;
   
   public class NewspaperDefCollection extends BaseTypedCollection
   {
      public function NewspaperDefCollection()
      {
         super();
      }
      
      public function getNewspaperDefItem(param1:uint) : NewspaperDef
      {
         return typedItems[param1] as NewspaperDef;
      }
      
      public function setNewspaperDefItem(param1:uint, param2:NewspaperDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushNewspaperDefItem(param1:NewspaperDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

