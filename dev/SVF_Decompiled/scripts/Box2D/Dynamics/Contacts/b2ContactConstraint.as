package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2ContactConstraint
   {
      public var points:Array;
      
      public var normal:b2Vec2;
      
      public var manifold:b2Manifold;
      
      public var body1:b2Body;
      
      public var body2:b2Body;
      
      public var friction:Number;
      
      public var restitution:Number;
      
      public var pointCount:int;
      
      public function b2ContactConstraint()
      {
         var _loc1_:int = 0;
         normal = new b2Vec2();
         super();
         points = new Array(2);
         _loc1_ = 0;
         while(_loc1_ < 2)
         {
            points[_loc1_] = new b2ContactConstraintPoint();
            _loc1_++;
         }
      }
   }
}

