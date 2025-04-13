package Box2D.Dynamics.Joints
{
   import Box2D.Dynamics.b2Body;
   
   public class b2JointEdge
   {
      public var other:b2Body;
      
      public var joint:b2Joint;
      
      public var prev:b2JointEdge;
      
      public var next:b2JointEdge;
      
      public function b2JointEdge()
      {
         super();
      }
   }
}

