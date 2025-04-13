package Box2D.Collision.Shapes
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2PolygonDef extends b2ShapeDef
   {
      private static var s_mat:b2Mat22 = new b2Mat22();
      
      public var vertices:Array;
      
      public var vertexCount:int;
      
      public function b2PolygonDef()
      {
         var _loc1_:int = 0;
         vertices = new Array(8);
         super();
         type = 1;
         vertexCount = 0;
         _loc1_ = 0;
         while(_loc1_ < 8)
         {
            vertices[_loc1_] = new b2Vec2();
            _loc1_++;
         }
      }
      
      public function SetAsBox(param1:Number, param2:Number) : void
      {
         vertexCount = 4;
         vertices[0].Set(-param1,-param2);
         vertices[1].Set(param1,-param2);
         vertices[2].Set(param1,param2);
         vertices[3].Set(-param1,param2);
      }
      
      public function SetAsOrientedBox(param1:Number, param2:Number, param3:b2Vec2 = null, param4:Number = 0) : void
      {
         var _loc6_:* = null;
         var _loc5_:b2Mat22 = null;
         var _loc7_:int = 0;
         vertexCount = 4;
         vertices[0].Set(-param1,-param2);
         vertices[1].Set(param1,-param2);
         vertices[2].Set(param1,param2);
         vertices[3].Set(-param1,param2);
         if(param3)
         {
            _loc6_ = param3;
            _loc5_ = s_mat;
            _loc5_.Set(param4);
            _loc7_ = 0;
            while(_loc7_ < vertexCount)
            {
               param3 = vertices[_loc7_];
               param1 = _loc6_.x + (_loc5_.col1.x * param3.x + _loc5_.col2.x * param3.y);
               param3.y = _loc6_.y + (_loc5_.col1.y * param3.x + _loc5_.col2.y * param3.y);
               param3.x = param1;
               _loc7_++;
            }
         }
      }
   }
}

