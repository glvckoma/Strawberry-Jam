package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2MouseJointDef extends b2JointDef
   {
      public var target:b2Vec2 = new b2Vec2();
      
      public var maxForce:Number;
      
      public var frequencyHz:Number;
      
      public var dampingRatio:Number;
      
      public var timeStep:Number;
      
      public function b2MouseJointDef()
      {
         super();
         type = 5;
         maxForce = 0;
         frequencyHz = 5;
         dampingRatio = 0.7;
         timeStep = 0.016666666666666666;
      }
   }
}

