package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   
   public class b2DistanceJointDef extends b2JointDef
   {
      public var localAnchor1:b2Vec2 = new b2Vec2();
      
      public var localAnchor2:b2Vec2 = new b2Vec2();
      
      public var length:Number;
      
      public var frequencyHz:Number;
      
      public var dampingRatio:Number;
      
      public function b2DistanceJointDef()
      {
         super();
         type = 3;
         length = 1;
         frequencyHz = 0;
         dampingRatio = 0;
      }
      
      public function Initialize(param1:b2Body, param2:b2Body, param3:b2Vec2, param4:b2Vec2) : void
      {
         body1 = param1;
         body2 = param2;
         localAnchor1.SetV(body1.GetLocalPoint(param3));
         localAnchor2.SetV(body2.GetLocalPoint(param4));
         var _loc5_:Number = param4.x - param3.x;
         var _loc6_:Number = param4.y - param3.y;
         length = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         frequencyHz = 0;
         dampingRatio = 0;
      }
   }
}

