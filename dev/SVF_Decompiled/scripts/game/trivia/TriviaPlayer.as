package game.trivia
{
   import avatar.AvatarView;
   
   public class TriviaPlayer
   {
      public var pId:int;
      
      public var sfsId:int;
      
      public var dbId:int;
      
      public var userName:String;
      
      public var avtView:AvatarView;
      
      public var bCorrect:Boolean;
      
      public function TriviaPlayer()
      {
         super();
      }
      
      public function destroy() : void
      {
         if(avtView)
         {
            avtView.destroy();
            avtView = null;
         }
      }
   }
}

