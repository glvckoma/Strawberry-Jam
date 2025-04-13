package Box2D.Dynamics.Joints
{
   import Box2D.Dynamics.b2Body;
   
   public class b2JointDef
   {
      public var type:int;
      
      public var userData:*;
      
      public var body1:b2Body;
      
      public var body2:b2Body;
      
      public var collideConnected:Boolean;
      
      public function b2JointDef()
      {
         super();
         type = 0;
         userData = null;
         body1 = null;
         body2 = null;
         collideConnected = false;
      }
   }
}

