package collection
{
   import Enums.WorldItemDef;
   
   public class WorldItemCollection extends BaseTypedCollection
   {
      public function WorldItemCollection()
      {
         super();
      }
      
      public function getWorldDefItem(param1:uint) : WorldItemDef
      {
         return typedItems[param1] as WorldItemDef;
      }
      
      public function setWorldDefItem(param1:uint, param2:WorldItemDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushWorldDefItem(param1:WorldItemDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

