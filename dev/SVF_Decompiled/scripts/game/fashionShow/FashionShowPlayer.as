package game.fashionShow
{
   import avatar.AvatarView;
   import collection.AccItemCollection;
   
   public class FashionShowPlayer
   {
      public var pId:int;
      
      public var positionIndex:int;
      
      public var sfsId:int;
      
      public var dbId:int;
      
      public var _active:Boolean;
      
      public var customAvId:int;
      
      public var avtView:AvatarView;
      
      public var bCorrect:Boolean;
      
      public var playerBodyModList:AccItemCollection;
      
      public var userName:String;
      
      public function FashionShowPlayer()
      {
         super();
         playerBodyModList = null;
         positionIndex = -1;
         _active = false;
         customAvId = -1;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(playerBodyModList)
         {
            _loc1_ = 0;
            while(_loc1_ < playerBodyModList.length)
            {
               playerBodyModList.getAccItem(_loc1_).destroy();
               playerBodyModList.setAccItem(_loc1_,null);
               _loc1_++;
            }
            playerBodyModList = null;
         }
         if(avtView)
         {
            avtView.destroy();
            avtView = null;
         }
      }
   }
}

