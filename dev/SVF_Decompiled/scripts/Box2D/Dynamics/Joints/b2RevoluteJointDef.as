package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   
   public class b2RevoluteJointDef extends b2JointDef
   {
      public var localAnchor1:b2Vec2 = new b2Vec2();
      
      public var localAnchor2:b2Vec2 = new b2Vec2();
      
      public var referenceAngle:Number;
      
      public var enableLimit:Boolean;
      
      public var lowerAngle:Number;
      
      public var upperAngle:Number;
      
      public var enableMotor:Boolean;
      
      public var motorSpeed:Number;
      
      public var maxMotorTorque:Number;
      
      public function b2RevoluteJointDef()
      {
         super();
         type = 1;
         localAnchor1.Set(0,0);
         localAnchor2.Set(0,0);
         referenceAngle = 0;
         lowerAngle = 0;
         upperAngle = 0;
         maxMotorTorque = 0;
         motorSpeed = 0;
         enableLimit = false;
         enableMotor = false;
      }
      
      public function Initialize(param1:b2Body, param2:b2Body, param3:b2Vec2) : void
      {
         body1 = param1;
         body2 = param2;
         localAnchor1 = body1.GetLocalPoint(param3);
         localAnchor2 = body2.GetLocalPoint(param3);
         referenceAngle = body2.GetAngle() - body1.GetAngle();
      }
   }
}

