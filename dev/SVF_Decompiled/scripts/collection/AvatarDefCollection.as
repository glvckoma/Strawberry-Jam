package collection
{
   import avatar.AvatarDef;
   
   public class AvatarDefCollection extends BaseTypedCollection
   {
      public function AvatarDefCollection()
      {
         super();
      }
      
      public function getAvatrDefItem(param1:uint) : AvatarDef
      {
         return typedItems[param1] as AvatarDef;
      }
      
      public function setAvatarDefItem(param1:uint, param2:AvatarDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushAvatrDefItem(param1:AvatarDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

