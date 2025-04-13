package Box2D.Dynamics.Contacts
{
   import Box2D.Dynamics.b2ContactListener;
   
   public class b2NullContact extends b2Contact
   {
      public function b2NullContact()
      {
         super();
      }
      
      override public function Evaluate(param1:b2ContactListener) : void
      {
      }
      
      override public function GetManifolds() : Array
      {
         return null;
      }
   }
}

