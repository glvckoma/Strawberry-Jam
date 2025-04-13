package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Collision
   {
      public static const b2_nullFeature:uint = 255;
      
      private static var b2CollidePolyTempVec:b2Vec2 = new b2Vec2();
      
      public function b2Collision()
      {
         super();
      }
      
      public static function ClipSegmentToLine(param1:Array, param2:Array, param3:b2Vec2, param4:Number) : int
      {
         var _loc11_:ClipVertex = null;
         var _loc9_:Number = NaN;
         var _loc12_:b2Vec2 = null;
         var _loc13_:ClipVertex = null;
         var _loc10_:int = 0;
         _loc11_ = param2[0];
         var _loc6_:b2Vec2 = _loc11_.v;
         _loc11_ = param2[1];
         var _loc5_:b2Vec2 = _loc11_.v;
         var _loc8_:Number = b2Math.b2Dot(param3,_loc6_) - param4;
         var _loc7_:Number = b2Math.b2Dot(param3,_loc5_) - param4;
         if(_loc8_ <= 0)
         {
            param1[_loc10_++] = param2[0];
         }
         if(_loc7_ <= 0)
         {
            param1[_loc10_++] = param2[1];
         }
         if(_loc8_ * _loc7_ < 0)
         {
            _loc9_ = _loc8_ / (_loc8_ - _loc7_);
            _loc11_ = param1[_loc10_];
            _loc12_ = _loc11_.v;
            _loc12_.x = _loc6_.x + _loc9_ * (_loc5_.x - _loc6_.x);
            _loc12_.y = _loc6_.y + _loc9_ * (_loc5_.y - _loc6_.y);
            _loc11_ = param1[_loc10_];
            if(_loc8_ > 0)
            {
               _loc13_ = param2[0];
               _loc11_.id = _loc13_.id;
            }
            else
            {
               _loc13_ = param2[1];
               _loc11_.id = _loc13_.id;
            }
            _loc10_++;
         }
         return _loc10_;
      }
      
      public static function EdgeSeparation(param1:b2PolygonShape, param2:b2XForm, param3:int, param4:b2PolygonShape, param5:b2XForm) : Number
      {
         var _loc23_:b2Mat22 = null;
         var _loc22_:b2Vec2 = null;
         var _loc20_:int = 0;
         var _loc9_:Number = NaN;
         var _loc6_:int = param1.m_vertexCount;
         var _loc8_:Array = param1.m_vertices;
         var _loc11_:Array = param1.m_normals;
         var _loc7_:int = param4.m_vertexCount;
         var _loc10_:Array = param4.m_vertices;
         _loc23_ = param2.R;
         _loc22_ = _loc11_[param3];
         var _loc17_:Number = _loc23_.col1.x * _loc22_.x + _loc23_.col2.x * _loc22_.y;
         var _loc15_:Number = _loc23_.col1.y * _loc22_.x + _loc23_.col2.y * _loc22_.y;
         _loc23_ = param5.R;
         var _loc18_:Number = _loc23_.col1.x * _loc17_ + _loc23_.col1.y * _loc15_;
         var _loc16_:Number = _loc23_.col2.x * _loc17_ + _loc23_.col2.y * _loc15_;
         var _loc19_:* = 0;
         var _loc21_:* = 1.7976931348623157e+308;
         _loc20_ = 0;
         while(_loc20_ < _loc7_)
         {
            _loc22_ = _loc10_[_loc20_];
            _loc9_ = _loc22_.x * _loc18_ + _loc22_.y * _loc16_;
            if(_loc9_ < _loc21_)
            {
               _loc21_ = _loc9_;
               _loc19_ = _loc20_;
            }
            _loc20_++;
         }
         _loc22_ = _loc8_[param3];
         _loc23_ = param2.R;
         var _loc24_:Number = param2.position.x + (_loc23_.col1.x * _loc22_.x + _loc23_.col2.x * _loc22_.y);
         var _loc25_:Number = param2.position.y + (_loc23_.col1.y * _loc22_.x + _loc23_.col2.y * _loc22_.y);
         _loc22_ = _loc10_[_loc19_];
         _loc23_ = param5.R;
         var _loc14_:Number = param5.position.x + (_loc23_.col1.x * _loc22_.x + _loc23_.col2.x * _loc22_.y);
         var _loc13_:Number = param5.position.y + (_loc23_.col1.y * _loc22_.x + _loc23_.col2.y * _loc22_.y);
         _loc14_ -= _loc24_;
         _loc13_ -= _loc25_;
         return _loc14_ * _loc17_ + _loc13_ * _loc15_;
      }
      
      public static function FindMaxSeparation(param1:Array, param2:b2PolygonShape, param3:b2XForm, param4:b2PolygonShape, param5:b2XForm) : Number
      {
         var _loc20_:b2Vec2 = null;
         var _loc23_:b2Mat22 = null;
         var _loc16_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:* = 0;
         var _loc15_:* = NaN;
         var _loc9_:int = 0;
         var _loc6_:int = param2.m_vertexCount;
         var _loc11_:Array = param2.m_normals;
         _loc23_ = param5.R;
         _loc20_ = param4.m_centroid;
         var _loc18_:Number = param5.position.x + (_loc23_.col1.x * _loc20_.x + _loc23_.col2.x * _loc20_.y);
         var _loc19_:Number = param5.position.y + (_loc23_.col1.y * _loc20_.x + _loc23_.col2.y * _loc20_.y);
         _loc23_ = param3.R;
         _loc20_ = param2.m_centroid;
         _loc18_ -= param3.position.x + (_loc23_.col1.x * _loc20_.x + _loc23_.col2.x * _loc20_.y);
         _loc19_ -= param3.position.y + (_loc23_.col1.y * _loc20_.x + _loc23_.col2.y * _loc20_.y);
         var _loc22_:Number = _loc18_ * param3.R.col1.x + _loc19_ * param3.R.col1.y;
         var _loc21_:Number = _loc18_ * param3.R.col2.x + _loc19_ * param3.R.col2.y;
         var _loc13_:* = 0;
         var _loc10_:* = -1.7976931348623157e+308;
         _loc16_ = 0;
         while(_loc16_ < _loc6_)
         {
            _loc20_ = _loc11_[_loc16_];
            _loc7_ = _loc20_.x * _loc22_ + _loc20_.y * _loc21_;
            if(_loc7_ > _loc10_)
            {
               _loc10_ = _loc7_;
               _loc13_ = _loc16_;
            }
            _loc16_++;
         }
         var _loc17_:Number = EdgeSeparation(param2,param3,_loc13_,param4,param5);
         if(_loc17_ > 0)
         {
            return _loc17_;
         }
         var _loc14_:int = _loc13_ - 1 >= 0 ? _loc13_ - 1 : _loc6_ - 1;
         var _loc24_:Number = EdgeSeparation(param2,param3,_loc14_,param4,param5);
         if(_loc24_ > 0)
         {
            return _loc24_;
         }
         var _loc12_:int = _loc13_ + 1 < _loc6_ ? _loc13_ + 1 : 0;
         var _loc25_:Number = EdgeSeparation(param2,param3,_loc12_,param4,param5);
         if(_loc25_ > 0)
         {
            return _loc25_;
         }
         if(_loc24_ > _loc17_ && _loc24_ > _loc25_)
         {
            _loc9_ = -1;
            _loc8_ = _loc14_;
            _loc15_ = _loc24_;
         }
         else
         {
            if(_loc25_ <= _loc17_)
            {
               param1[0] = _loc13_;
               return _loc17_;
            }
            _loc9_ = 1;
            _loc8_ = _loc12_;
            _loc15_ = _loc25_;
         }
         while(true)
         {
            if(_loc9_ == -1)
            {
               _loc13_ = _loc8_ - 1 >= 0 ? _loc8_ - 1 : _loc6_ - 1;
            }
            else
            {
               _loc13_ = _loc8_ + 1 < _loc6_ ? _loc8_ + 1 : 0;
            }
            _loc17_ = EdgeSeparation(param2,param3,_loc13_,param4,param5);
            if(_loc17_ > 0)
            {
               break;
            }
            if(_loc17_ <= _loc15_)
            {
               param1[0] = _loc8_;
               return _loc15_;
            }
            _loc8_ = _loc13_;
            _loc15_ = _loc17_;
         }
         return _loc17_;
      }
      
      public static function FindIncidentEdge(param1:Array, param2:b2PolygonShape, param3:b2XForm, param4:int, param5:b2PolygonShape, param6:b2XForm) : void
      {
         var _loc23_:b2Mat22 = null;
         var _loc22_:b2Vec2 = null;
         var _loc17_:int = 0;
         var _loc13_:Number = NaN;
         var _loc12_:ClipVertex = null;
         var _loc7_:int = param2.m_vertexCount;
         var _loc21_:Array = param2.m_normals;
         var _loc8_:int = param5.m_vertexCount;
         var _loc15_:Array = param5.m_vertices;
         var _loc19_:Array = param5.m_normals;
         _loc23_ = param3.R;
         _loc22_ = _loc21_[param4];
         var _loc11_:* = _loc23_.col1.x * _loc22_.x + _loc23_.col2.x * _loc22_.y;
         var _loc9_:Number = _loc23_.col1.y * _loc22_.x + _loc23_.col2.y * _loc22_.y;
         _loc23_ = param6.R;
         var _loc10_:Number = _loc23_.col1.x * _loc11_ + _loc23_.col1.y * _loc9_;
         _loc9_ = _loc23_.col2.x * _loc11_ + _loc23_.col2.y * _loc9_;
         _loc11_ = _loc10_;
         var _loc16_:* = 0;
         var _loc20_:* = 1.7976931348623157e+308;
         _loc17_ = 0;
         while(_loc17_ < _loc8_)
         {
            _loc22_ = _loc19_[_loc17_];
            _loc13_ = _loc11_ * _loc22_.x + _loc9_ * _loc22_.y;
            if(_loc13_ < _loc20_)
            {
               _loc20_ = _loc13_;
               _loc16_ = _loc17_;
            }
            _loc17_++;
         }
         var _loc14_:* = _loc16_;
         var _loc18_:int = _loc14_ + 1 < _loc8_ ? _loc14_ + 1 : 0;
         _loc12_ = param1[0];
         _loc22_ = _loc15_[_loc14_];
         _loc23_ = param6.R;
         _loc12_.v.x = param6.position.x + (_loc23_.col1.x * _loc22_.x + _loc23_.col2.x * _loc22_.y);
         _loc12_.v.y = param6.position.y + (_loc23_.col1.y * _loc22_.x + _loc23_.col2.y * _loc22_.y);
         _loc12_.id.features.referenceEdge = param4;
         _loc12_.id.features.incidentEdge = _loc14_;
         _loc12_.id.features.incidentVertex = 0;
         _loc12_ = param1[1];
         _loc22_ = _loc15_[_loc18_];
         _loc23_ = param6.R;
         _loc12_.v.x = param6.position.x + (_loc23_.col1.x * _loc22_.x + _loc23_.col2.x * _loc22_.y);
         _loc12_.v.y = param6.position.y + (_loc23_.col1.y * _loc22_.x + _loc23_.col2.y * _loc22_.y);
         _loc12_.id.features.referenceEdge = param4;
         _loc12_.id.features.incidentEdge = _loc18_;
         _loc12_.id.features.incidentVertex = 1;
      }
      
      public static function b2CollidePolygons(param1:b2Manifold, param2:b2PolygonShape, param3:b2XForm, param4:b2PolygonShape, param5:b2XForm) : void
      {
         var _loc34_:ClipVertex = null;
         var _loc38_:* = null;
         var _loc37_:* = null;
         var _loc29_:* = 0;
         var _loc21_:* = 0;
         var _loc12_:Number = NaN;
         _loc12_ = 0.98;
         var _loc27_:Number = NaN;
         _loc27_ = 0.001;
         var _loc16_:b2Vec2 = null;
         var _loc9_:int = 0;
         var _loc28_:int = 0;
         var _loc15_:Number = NaN;
         var _loc31_:b2ManifoldPoint = null;
         param1.pointCount = 0;
         var _loc18_:int = 0;
         var _loc22_:Array = [_loc18_];
         var _loc23_:Number = FindMaxSeparation(_loc22_,param2,param3,param4,param5);
         _loc18_ = int(_loc22_[0]);
         if(_loc23_ > 0)
         {
            return;
         }
         var _loc19_:int = 0;
         var _loc6_:Array = [_loc19_];
         var _loc24_:Number = FindMaxSeparation(_loc6_,param4,param5,param2,param3);
         _loc19_ = int(_loc6_[0]);
         if(_loc24_ > 0)
         {
            return;
         }
         var _loc8_:b2XForm = new b2XForm();
         var _loc10_:b2XForm = new b2XForm();
         if(_loc24_ > 0.98 * _loc23_ + 0.001)
         {
            _loc38_ = param4;
            _loc37_ = param2;
            _loc8_.Set(param5);
            _loc10_.Set(param3);
            _loc29_ = _loc19_;
            _loc21_ = 1;
         }
         else
         {
            _loc38_ = param2;
            _loc37_ = param4;
            _loc8_.Set(param3);
            _loc10_.Set(param5);
            _loc29_ = _loc18_;
            _loc21_ = 0;
         }
         var _loc32_:Array = [new ClipVertex(),new ClipVertex()];
         FindIncidentEdge(_loc32_,_loc38_,_loc8_,_loc29_,_loc37_,_loc10_);
         var _loc7_:int = _loc38_.m_vertexCount;
         var _loc11_:Array = _loc38_.m_vertices;
         var _loc36_:b2Vec2 = _loc11_[_loc29_];
         var _loc17_:b2Vec2 = _loc36_.Copy();
         if(_loc29_ + 1 < _loc7_)
         {
            _loc36_ = _loc11_[_loc29_ + 1];
            _loc16_ = _loc36_.Copy();
         }
         else
         {
            _loc36_ = _loc11_[0];
            _loc16_ = _loc36_.Copy();
         }
         var _loc14_:b2Vec2 = b2Math.SubtractVV(_loc16_,_loc17_);
         var _loc20_:b2Vec2 = b2Math.b2MulMV(_loc8_.R,b2Math.SubtractVV(_loc16_,_loc17_));
         _loc20_.Normalize();
         var _loc13_:b2Vec2 = b2Math.b2CrossVF(_loc20_,1);
         _loc17_ = b2Math.b2MulX(_loc8_,_loc17_);
         _loc16_ = b2Math.b2MulX(_loc8_,_loc16_);
         var _loc30_:Number = b2Math.b2Dot(_loc13_,_loc17_);
         var _loc39_:Number = -b2Math.b2Dot(_loc20_,_loc17_);
         var _loc35_:Number = b2Math.b2Dot(_loc20_,_loc16_);
         var _loc26_:Array = [new ClipVertex(),new ClipVertex()];
         var _loc25_:Array = [new ClipVertex(),new ClipVertex()];
         _loc9_ = ClipSegmentToLine(_loc26_,_loc32_,_loc20_.Negative(),_loc39_);
         if(_loc9_ < 2)
         {
            return;
         }
         _loc9_ = ClipSegmentToLine(_loc25_,_loc26_,_loc20_,_loc35_);
         if(_loc9_ < 2)
         {
            return;
         }
         param1.normal = !!_loc21_ ? _loc13_.Negative() : _loc13_.Copy();
         var _loc33_:int = 0;
         _loc28_ = 0;
         while(_loc28_ < 2)
         {
            _loc34_ = _loc25_[_loc28_];
            _loc15_ = b2Math.b2Dot(_loc13_,_loc34_.v) - _loc30_;
            if(_loc15_ <= 0)
            {
               _loc31_ = param1.points[_loc33_];
               _loc31_.separation = _loc15_;
               _loc31_.localPoint1 = b2Math.b2MulXT(param3,_loc34_.v);
               _loc31_.localPoint2 = b2Math.b2MulXT(param5,_loc34_.v);
               _loc31_.id.key = _loc34_.id._key;
               _loc31_.id.features.flip = _loc21_;
               _loc33_++;
            }
            _loc28_++;
         }
         param1.pointCount = _loc33_;
      }
      
      public static function b2CollideCircles(param1:b2Manifold, param2:b2CircleShape, param3:b2XForm, param4:b2CircleShape, param5:b2XForm) : void
      {
         var _loc23_:b2Mat22 = null;
         var _loc21_:b2Vec2 = null;
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc12_:Number = NaN;
         param1.pointCount = 0;
         _loc23_ = param3.R;
         _loc21_ = param2.m_localPosition;
         var _loc22_:Number = param3.position.x + (_loc23_.col1.x * _loc21_.x + _loc23_.col2.x * _loc21_.y);
         var _loc24_:Number = param3.position.y + (_loc23_.col1.y * _loc21_.x + _loc23_.col2.y * _loc21_.y);
         _loc23_ = param5.R;
         _loc21_ = param4.m_localPosition;
         var _loc11_:Number = param5.position.x + (_loc23_.col1.x * _loc21_.x + _loc23_.col2.x * _loc21_.y);
         var _loc10_:Number = param5.position.y + (_loc23_.col1.y * _loc21_.x + _loc23_.col2.y * _loc21_.y);
         var _loc19_:Number = _loc11_ - _loc22_;
         var _loc20_:Number = _loc10_ - _loc24_;
         var _loc15_:Number = _loc19_ * _loc19_ + _loc20_ * _loc20_;
         var _loc25_:Number = param2.m_radius;
         var _loc6_:Number = param4.m_radius;
         var _loc8_:Number = _loc25_ + _loc6_;
         if(_loc15_ > _loc8_ * _loc8_)
         {
            return;
         }
         if(_loc15_ < Number.MIN_VALUE)
         {
            _loc9_ = -_loc8_;
            param1.normal.Set(0,1);
         }
         else
         {
            _loc7_ = Math.sqrt(_loc15_);
            _loc9_ = _loc7_ - _loc8_;
            _loc12_ = 1 / _loc7_;
            param1.normal.x = _loc12_ * _loc19_;
            param1.normal.y = _loc12_ * _loc20_;
         }
         param1.pointCount = 1;
         var _loc18_:b2ManifoldPoint = param1.points[0];
         _loc18_.id.key = 0;
         _loc18_.separation = _loc9_;
         _loc22_ += _loc25_ * param1.normal.x;
         _loc24_ += _loc25_ * param1.normal.y;
         _loc11_ -= _loc6_ * param1.normal.x;
         _loc10_ -= _loc6_ * param1.normal.y;
         var _loc16_:Number = 0.5 * (_loc22_ + _loc11_);
         var _loc17_:Number = 0.5 * (_loc24_ + _loc10_);
         var _loc13_:Number = _loc16_ - param3.position.x;
         var _loc14_:Number = _loc17_ - param3.position.y;
         _loc18_.localPoint1.x = _loc13_ * param3.R.col1.x + _loc14_ * param3.R.col1.y;
         _loc18_.localPoint1.y = _loc13_ * param3.R.col2.x + _loc14_ * param3.R.col2.y;
         _loc13_ = _loc16_ - param5.position.x;
         _loc14_ = _loc17_ - param5.position.y;
         _loc18_.localPoint2.x = _loc13_ * param5.R.col1.x + _loc14_ * param5.R.col1.y;
         _loc18_.localPoint2.y = _loc13_ * param5.R.col2.x + _loc14_ * param5.R.col2.y;
      }
      
      public static function b2CollidePolygonAndCircle(param1:b2Manifold, param2:b2PolygonShape, param3:b2XForm, param4:b2CircleShape, param5:b2XForm) : void
      {
         var _loc25_:b2ManifoldPoint = null;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc31_:b2Vec2 = null;
         var _loc32_:b2Mat22 = null;
         var _loc7_:Number = NaN;
         var _loc21_:int = 0;
         var _loc27_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc20_:Number = NaN;
         param1.pointCount = 0;
         _loc32_ = param5.R;
         _loc31_ = param4.m_localPosition;
         var _loc14_:Number = param5.position.x + (_loc32_.col1.x * _loc31_.x + _loc32_.col2.x * _loc31_.y);
         var _loc16_:Number = param5.position.y + (_loc32_.col1.y * _loc31_.x + _loc32_.col2.y * _loc31_.y);
         _loc28_ = _loc14_ - param3.position.x;
         _loc29_ = _loc16_ - param3.position.y;
         _loc32_ = param3.R;
         var _loc11_:Number = _loc28_ * _loc32_.col1.x + _loc29_ * _loc32_.col1.y;
         var _loc10_:Number = _loc28_ * _loc32_.col2.x + _loc29_ * _loc32_.col2.y;
         var _loc18_:* = 0;
         var _loc15_:* = -1.7976931348623157e+308;
         var _loc17_:Number = param4.m_radius;
         var _loc23_:int = param2.m_vertexCount;
         var _loc6_:Array = param2.m_vertices;
         var _loc34_:Array = param2.m_normals;
         _loc21_ = 0;
         while(_loc21_ < _loc23_)
         {
            _loc31_ = _loc6_[_loc21_];
            _loc28_ = _loc11_ - _loc31_.x;
            _loc29_ = _loc10_ - _loc31_.y;
            _loc31_ = _loc34_[_loc21_];
            _loc27_ = _loc31_.x * _loc28_ + _loc31_.y * _loc29_;
            if(_loc27_ > _loc17_)
            {
               return;
            }
            if(_loc27_ > _loc15_)
            {
               _loc15_ = _loc27_;
               _loc18_ = _loc21_;
            }
            _loc21_++;
         }
         if(_loc15_ < Number.MIN_VALUE)
         {
            param1.pointCount = 1;
            _loc31_ = _loc34_[_loc18_];
            _loc32_ = param3.R;
            param1.normal.x = _loc32_.col1.x * _loc31_.x + _loc32_.col2.x * _loc31_.y;
            param1.normal.y = _loc32_.col1.y * _loc31_.x + _loc32_.col2.y * _loc31_.y;
            _loc25_ = param1.points[0];
            _loc25_.id.features.incidentEdge = _loc18_;
            _loc25_.id.features.incidentVertex = 255;
            _loc25_.id.features.referenceEdge = 0;
            _loc25_.id.features.flip = 0;
            _loc8_ = _loc14_ - _loc17_ * param1.normal.x;
            _loc9_ = _loc16_ - _loc17_ * param1.normal.y;
            _loc28_ = _loc8_ - param3.position.x;
            _loc29_ = _loc9_ - param3.position.y;
            _loc32_ = param3.R;
            _loc25_.localPoint1.x = _loc28_ * _loc32_.col1.x + _loc29_ * _loc32_.col1.y;
            _loc25_.localPoint1.y = _loc28_ * _loc32_.col2.x + _loc29_ * _loc32_.col2.y;
            _loc28_ = _loc8_ - param5.position.x;
            _loc29_ = _loc9_ - param5.position.y;
            _loc32_ = param5.R;
            _loc25_.localPoint2.x = _loc28_ * _loc32_.col1.x + _loc29_ * _loc32_.col1.y;
            _loc25_.localPoint2.y = _loc28_ * _loc32_.col2.x + _loc29_ * _loc32_.col2.y;
            _loc25_.separation = _loc15_ - _loc17_;
            return;
         }
         var _loc26_:* = _loc18_;
         var _loc24_:int = _loc26_ + 1 < _loc23_ ? _loc26_ + 1 : 0;
         _loc31_ = _loc6_[_loc26_];
         var _loc33_:b2Vec2 = _loc6_[_loc24_];
         var _loc12_:Number = _loc33_.x - _loc31_.x;
         var _loc13_:Number = _loc33_.y - _loc31_.y;
         var _loc19_:Number = Math.sqrt(_loc12_ * _loc12_ + _loc13_ * _loc13_);
         _loc12_ /= _loc19_;
         _loc13_ /= _loc19_;
         _loc28_ = _loc11_ - _loc31_.x;
         _loc29_ = _loc10_ - _loc31_.y;
         var _loc30_:Number = _loc28_ * _loc12_ + _loc29_ * _loc13_;
         _loc25_ = param1.points[0];
         if(_loc30_ <= 0)
         {
            _loc20_ = _loc31_.x;
            _loc22_ = _loc31_.y;
            _loc25_.id.features.incidentEdge = 255;
            _loc25_.id.features.incidentVertex = _loc26_;
         }
         else if(_loc30_ >= _loc19_)
         {
            _loc20_ = _loc33_.x;
            _loc22_ = _loc33_.y;
            _loc25_.id.features.incidentEdge = 255;
            _loc25_.id.features.incidentVertex = _loc24_;
         }
         else
         {
            _loc20_ = _loc12_ * _loc30_ + _loc31_.x;
            _loc22_ = _loc13_ * _loc30_ + _loc31_.y;
            _loc25_.id.features.incidentEdge = _loc18_;
            _loc25_.id.features.incidentVertex = 255;
         }
         _loc28_ = _loc11_ - _loc20_;
         _loc29_ = _loc10_ - _loc22_;
         _loc7_ = Math.sqrt(_loc28_ * _loc28_ + _loc29_ * _loc29_);
         _loc28_ /= _loc7_;
         _loc29_ /= _loc7_;
         if(_loc7_ > _loc17_)
         {
            return;
         }
         param1.pointCount = 1;
         _loc32_ = param3.R;
         param1.normal.x = _loc32_.col1.x * _loc28_ + _loc32_.col2.x * _loc29_;
         param1.normal.y = _loc32_.col1.y * _loc28_ + _loc32_.col2.y * _loc29_;
         _loc8_ = _loc14_ - _loc17_ * param1.normal.x;
         _loc9_ = _loc16_ - _loc17_ * param1.normal.y;
         _loc28_ = _loc8_ - param3.position.x;
         _loc29_ = _loc9_ - param3.position.y;
         _loc32_ = param3.R;
         _loc25_.localPoint1.x = _loc28_ * _loc32_.col1.x + _loc29_ * _loc32_.col1.y;
         _loc25_.localPoint1.y = _loc28_ * _loc32_.col2.x + _loc29_ * _loc32_.col2.y;
         _loc28_ = _loc8_ - param5.position.x;
         _loc29_ = _loc9_ - param5.position.y;
         _loc32_ = param5.R;
         _loc25_.localPoint2.x = _loc28_ * _loc32_.col1.x + _loc29_ * _loc32_.col1.y;
         _loc25_.localPoint2.y = _loc28_ * _loc32_.col2.x + _loc29_ * _loc32_.col2.y;
         _loc25_.separation = _loc7_ - _loc17_;
         _loc25_.id.features.referenceEdge = 0;
         _loc25_.id.features.flip = 0;
      }
      
      public static function b2TestOverlap(param1:b2AABB, param2:b2AABB) : Boolean
      {
         var _loc6_:b2Vec2 = param2.lowerBound;
         var _loc8_:b2Vec2 = param1.upperBound;
         var _loc3_:Number = _loc6_.x - _loc8_.x;
         var _loc7_:Number = _loc6_.y - _loc8_.y;
         _loc6_ = param1.lowerBound;
         _loc8_ = param2.upperBound;
         var _loc5_:Number = _loc6_.x - _loc8_.x;
         var _loc4_:Number = _loc6_.y - _loc8_.y;
         if(_loc3_ > 0 || _loc7_ > 0)
         {
            return false;
         }
         if(_loc5_ > 0 || _loc4_ > 0)
         {
            return false;
         }
         return true;
      }
   }
}

