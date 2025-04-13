package collection
{
   import avatar.CustomAvatarDef;
   
   public class CustomAvatarDefCollection extends BaseTypedCollection
   {
      public function CustomAvatarDefCollection()
      {
         super();
      }
      
      public function getCustomAvatarDefItem(param1:uint) : CustomAvatarDef
      {
         return typedItems[param1] as CustomAvatarDef;
      }
      
      public function setCustomAvatarDefItem(param1:uint, param2:CustomAvatarDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushCustomAvatarDefItem(param1:CustomAvatarDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

