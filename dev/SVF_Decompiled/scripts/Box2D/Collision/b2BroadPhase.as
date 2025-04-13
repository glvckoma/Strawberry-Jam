package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2BroadPhase
   {
      public static var s_validate:Boolean = false;
      
      public static const b2_invalid:uint = 65535;
      
      public static const b2_nullEdge:uint = 65535;
      
      public var m_pairManager:b2PairManager;
      
      public var m_proxyPool:Array;
      
      public var m_freeProxy:uint;
      
      public var m_bounds:Array;
      
      public var m_queryResults:Array;
      
      public var m_queryResultCount:int;
      
      public var m_worldAABB:b2AABB;
      
      public var m_quantizationFactor:b2Vec2;
      
      public var m_proxyCount:int;
      
      public var m_timeStamp:uint;
      
      public function b2BroadPhase(param1:b2AABB, param2:b2PairCallback)
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:b2Proxy = null;
         m_pairManager = new b2PairManager();
         m_proxyPool = new Array(4096);
         m_bounds = new Array(2 * 512);
         m_queryResults = new Array(512);
         m_quantizationFactor = new b2Vec2();
         super();
         m_pairManager.Initialize(this,param2);
         m_worldAABB = param1;
         m_proxyCount = 0;
         _loc6_ = 0;
         while(_loc6_ < 512)
         {
            m_queryResults[_loc6_] = 0;
            _loc6_++;
         }
         m_bounds = new Array(2);
         _loc6_ = 0;
         while(_loc6_ < 2)
         {
            m_bounds[_loc6_] = new Array(2 * 512);
            _loc7_ = 0;
            while(_loc7_ < 2 * 512)
            {
               m_bounds[_loc6_][_loc7_] = new b2Bound();
               _loc7_++;
            }
            _loc6_++;
         }
         var _loc3_:Number = param1.upperBound.x - param1.lowerBound.x;
         var _loc4_:Number = param1.upperBound.y - param1.lowerBound.y;
         m_quantizationFactor.x = 65535 / _loc3_;
         m_quantizationFactor.y = 65535 / _loc4_;
         _loc6_ = 0;
         while(_loc6_ < 512 - 1)
         {
            _loc5_ = new b2Proxy();
            m_proxyPool[_loc6_] = _loc5_;
            _loc5_.SetNext(_loc6_ + 1);
            _loc5_.timeStamp = 0;
            _loc5_.overlapCount = 65535;
            _loc5_.userData = null;
            _loc6_++;
         }
         _loc5_ = new b2Proxy();
         m_proxyPool[511] = _loc5_;
         _loc5_.SetNext(b2Pair.b2_nullProxy);
         _loc5_.timeStamp = 0;
         _loc5_.overlapCount = 65535;
         _loc5_.userData = null;
         m_freeProxy = 0;
         m_timeStamp = 1;
         m_queryResultCount = 0;
      }
      
      public static function BinarySearch(param1:Array, param2:int, param3:uint) : uint
      {
         var _loc7_:int = 0;
         var _loc6_:b2Bound = null;
         var _loc5_:int = 0;
         var _loc4_:int = param2 - 1;
         while(_loc5_ <= _loc4_)
         {
            _loc7_ = (_loc5_ + _loc4_) / 2;
            _loc6_ = param1[_loc7_];
            if(_loc6_.value > param3)
            {
               _loc4_ = _loc7_ - 1;
            }
            else
            {
               if(_loc6_.value >= param3)
               {
                  return uint(_loc7_);
               }
               _loc5_ = _loc7_ + 1;
            }
         }
         return uint(_loc5_);
      }
      
      public function InRange(param1:b2AABB) : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         _loc2_ = param1.lowerBound.x;
         _loc3_ = param1.lowerBound.y;
         _loc2_ -= m_worldAABB.upperBound.x;
         _loc3_ -= m_worldAABB.upperBound.y;
         _loc5_ = m_worldAABB.lowerBound.x;
         _loc4_ = m_worldAABB.lowerBound.y;
         _loc5_ -= param1.upperBound.x;
         _loc4_ -= param1.upperBound.y;
         _loc2_ = b2Math.b2Max(_loc2_,_loc5_);
         _loc3_ = b2Math.b2Max(_loc3_,_loc4_);
         return b2Math.b2Max(_loc2_,_loc3_) < 0;
      }
      
      public function GetProxy(param1:int) : b2Proxy
      {
         var _loc2_:b2Proxy = m_proxyPool[param1];
         if(param1 == b2Pair.b2_nullProxy || _loc2_.IsValid() == false)
         {
            return null;
         }
         return _loc2_;
      }
      
      public function CreateProxy(param1:b2AABB, param2:*) : uint
      {
         var _loc5_:* = 0;
         var _loc13_:b2Proxy = null;
         var _loc10_:int = 0;
         var _loc18_:Array = null;
         var _loc19_:* = 0;
         var _loc8_:* = 0;
         var _loc4_:Array = null;
         var _loc15_:Array = null;
         var _loc20_:Array = null;
         var _loc9_:int = 0;
         var _loc14_:int = 0;
         var _loc3_:b2Bound = null;
         var _loc11_:b2Bound = null;
         var _loc12_:b2Bound = null;
         var _loc16_:int = 0;
         var _loc22_:b2Proxy = null;
         var _loc7_:int = 0;
         var _loc23_:uint = m_freeProxy;
         _loc13_ = m_proxyPool[_loc23_];
         m_freeProxy = _loc13_.GetNext();
         _loc13_.overlapCount = 0;
         _loc13_.userData = param2;
         var _loc17_:uint = uint(2 * m_proxyCount);
         var _loc6_:Array = [];
         var _loc21_:Array = [];
         ComputeBounds(_loc6_,_loc21_,param1);
         _loc10_ = 0;
         while(_loc10_ < 2)
         {
            _loc18_ = m_bounds[_loc10_];
            _loc4_ = [_loc19_];
            _loc15_ = [_loc8_];
            Query(_loc4_,_loc15_,_loc6_[_loc10_],_loc21_[_loc10_],_loc18_,_loc17_,_loc10_);
            _loc19_ = uint(_loc4_[0]);
            _loc8_ = uint(_loc15_[0]);
            _loc20_ = [];
            _loc14_ = _loc17_ - _loc8_;
            _loc9_ = 0;
            while(_loc9_ < _loc14_)
            {
               _loc20_[_loc9_] = new b2Bound();
               _loc3_ = _loc20_[_loc9_];
               _loc11_ = _loc18_[_loc8_ + _loc9_];
               _loc3_.value = _loc11_.value;
               _loc3_.proxyId = _loc11_.proxyId;
               _loc3_.stabbingCount = _loc11_.stabbingCount;
               _loc9_++;
            }
            _loc14_ = int(_loc20_.length);
            _loc16_ = _loc8_ + 2;
            _loc9_ = 0;
            while(_loc9_ < _loc14_)
            {
               _loc11_ = _loc20_[_loc9_];
               _loc3_ = _loc18_[_loc16_ + _loc9_];
               _loc3_.value = _loc11_.value;
               _loc3_.proxyId = _loc11_.proxyId;
               _loc3_.stabbingCount = _loc11_.stabbingCount;
               _loc9_++;
            }
            _loc20_ = [];
            _loc14_ = _loc8_ - _loc19_;
            _loc9_ = 0;
            while(_loc9_ < _loc14_)
            {
               _loc20_[_loc9_] = new b2Bound();
               _loc3_ = _loc20_[_loc9_];
               _loc11_ = _loc18_[_loc19_ + _loc9_];
               _loc3_.value = _loc11_.value;
               _loc3_.proxyId = _loc11_.proxyId;
               _loc3_.stabbingCount = _loc11_.stabbingCount;
               _loc9_++;
            }
            _loc14_ = int(_loc20_.length);
            _loc16_ = _loc19_ + 1;
            _loc9_ = 0;
            while(_loc9_ < _loc14_)
            {
               _loc11_ = _loc20_[_loc9_];
               _loc3_ = _loc18_[_loc16_ + _loc9_];
               _loc3_.value = _loc11_.value;
               _loc3_.proxyId = _loc11_.proxyId;
               _loc3_.stabbingCount = _loc11_.stabbingCount;
               _loc9_++;
            }
            _loc8_++;
            _loc3_ = _loc18_[_loc19_];
            _loc11_ = _loc18_[_loc8_];
            _loc3_.value = _loc6_[_loc10_];
            _loc3_.proxyId = _loc23_;
            _loc11_.value = _loc21_[_loc10_];
            _loc11_.proxyId = _loc23_;
            _loc12_ = _loc18_[_loc19_ - 1];
            _loc3_.stabbingCount = _loc19_ == 0 ? 0 : _loc12_.stabbingCount;
            _loc12_ = _loc18_[_loc8_ - 1];
            _loc11_.stabbingCount = _loc12_.stabbingCount;
            _loc5_ = _loc19_;
            while(_loc5_ < _loc8_)
            {
               _loc12_ = _loc18_[_loc5_];
               _loc12_.stabbingCount++;
               _loc5_++;
            }
            _loc5_ = _loc19_;
            while(_loc5_ < _loc17_ + 2)
            {
               _loc3_ = _loc18_[_loc5_];
               _loc22_ = m_proxyPool[_loc3_.proxyId];
               if(_loc3_.IsLower())
               {
                  _loc22_.lowerBounds[_loc10_] = _loc5_;
               }
               else
               {
                  _loc22_.upperBounds[_loc10_] = _loc5_;
               }
               _loc5_++;
            }
            _loc10_++;
         }
         ++m_proxyCount;
         _loc7_ = 0;
         while(_loc7_ < m_queryResultCount)
         {
            m_pairManager.AddBufferedPair(_loc23_,m_queryResults[_loc7_]);
            _loc7_++;
         }
         m_pairManager.Commit();
         m_queryResultCount = 0;
         IncrementTimeStamp();
         return _loc23_;
      }
      
      public function DestroyProxy(param1:uint) : void
      {
         var _loc2_:b2Bound = null;
         var _loc11_:b2Bound = null;
         var _loc10_:int = 0;
         var _loc16_:Array = null;
         var _loc17_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:* = 0;
         var _loc3_:* = 0;
         var _loc18_:Array = null;
         var _loc8_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc4_:* = 0;
         var _loc19_:b2Proxy = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc12_:b2Proxy = m_proxyPool[param1];
         var _loc15_:int = 2 * m_proxyCount;
         _loc10_ = 0;
         while(_loc10_ < 2)
         {
            _loc16_ = m_bounds[_loc10_];
            _loc17_ = uint(_loc12_.lowerBounds[_loc10_]);
            _loc7_ = uint(_loc12_.upperBounds[_loc10_]);
            _loc2_ = _loc16_[_loc17_];
            _loc9_ = _loc2_.value;
            _loc11_ = _loc16_[_loc7_];
            _loc3_ = _loc11_.value;
            _loc18_ = [];
            _loc13_ = _loc7_ - _loc17_ - 1;
            _loc8_ = 0;
            while(_loc8_ < _loc13_)
            {
               _loc18_[_loc8_] = new b2Bound();
               _loc2_ = _loc18_[_loc8_];
               _loc11_ = _loc16_[_loc17_ + 1 + _loc8_];
               _loc2_.value = _loc11_.value;
               _loc2_.proxyId = _loc11_.proxyId;
               _loc2_.stabbingCount = _loc11_.stabbingCount;
               _loc8_++;
            }
            _loc13_ = int(_loc18_.length);
            _loc14_ = int(_loc17_);
            _loc8_ = 0;
            while(_loc8_ < _loc13_)
            {
               _loc11_ = _loc18_[_loc8_];
               _loc2_ = _loc16_[_loc14_ + _loc8_];
               _loc2_.value = _loc11_.value;
               _loc2_.proxyId = _loc11_.proxyId;
               _loc2_.stabbingCount = _loc11_.stabbingCount;
               _loc8_++;
            }
            _loc18_ = [];
            _loc13_ = _loc15_ - _loc7_ - 1;
            _loc8_ = 0;
            while(_loc8_ < _loc13_)
            {
               _loc18_[_loc8_] = new b2Bound();
               _loc2_ = _loc18_[_loc8_];
               _loc11_ = _loc16_[_loc7_ + 1 + _loc8_];
               _loc2_.value = _loc11_.value;
               _loc2_.proxyId = _loc11_.proxyId;
               _loc2_.stabbingCount = _loc11_.stabbingCount;
               _loc8_++;
            }
            _loc13_ = int(_loc18_.length);
            _loc14_ = _loc7_ - 1;
            _loc8_ = 0;
            while(_loc8_ < _loc13_)
            {
               _loc11_ = _loc18_[_loc8_];
               _loc2_ = _loc16_[_loc14_ + _loc8_];
               _loc2_.value = _loc11_.value;
               _loc2_.proxyId = _loc11_.proxyId;
               _loc2_.stabbingCount = _loc11_.stabbingCount;
               _loc8_++;
            }
            _loc13_ = _loc15_ - 2;
            _loc4_ = _loc17_;
            while(_loc4_ < _loc13_)
            {
               _loc2_ = _loc16_[_loc4_];
               _loc19_ = m_proxyPool[_loc2_.proxyId];
               if(_loc2_.IsLower())
               {
                  _loc19_.lowerBounds[_loc10_] = _loc4_;
               }
               else
               {
                  _loc19_.upperBounds[_loc10_] = _loc4_;
               }
               _loc4_++;
            }
            _loc13_ = _loc7_ - 1;
            _loc5_ = int(_loc17_);
            while(_loc5_ < _loc13_)
            {
               _loc2_ = _loc16_[_loc5_];
               _loc2_.stabbingCount--;
               _loc5_++;
            }
            Query([0],[0],_loc9_,_loc3_,_loc16_,_loc15_ - 2,_loc10_);
            _loc10_++;
         }
         _loc6_ = 0;
         while(_loc6_ < m_queryResultCount)
         {
            m_pairManager.RemoveBufferedPair(param1,m_queryResults[_loc6_]);
            _loc6_++;
         }
         m_pairManager.Commit();
         m_queryResultCount = 0;
         IncrementTimeStamp();
         _loc12_.userData = null;
         _loc12_.overlapCount = 65535;
         _loc12_.lowerBounds[0] = 65535;
         _loc12_.lowerBounds[1] = 65535;
         _loc12_.upperBounds[0] = 65535;
         _loc12_.upperBounds[1] = 65535;
         _loc12_.SetNext(m_freeProxy);
         m_freeProxy = param1;
         --m_proxyCount;
      }
      
      public function MoveProxy(param1:uint, param2:b2AABB) : void
      {
         var _loc16_:Array = null;
         var _loc23_:int = 0;
         var _loc12_:* = 0;
         var _loc8_:* = 0;
         var _loc7_:b2Bound = null;
         var _loc17_:b2Bound = null;
         var _loc21_:b2Bound = null;
         var _loc22_:* = 0;
         var _loc4_:b2Proxy = null;
         var _loc19_:Array = null;
         var _loc20_:* = 0;
         var _loc9_:* = 0;
         var _loc11_:* = 0;
         var _loc6_:* = 0;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc10_:* = 0;
         var _loc24_:b2Proxy = null;
         if(param1 == b2Pair.b2_nullProxy || 512 <= param1)
         {
            return;
         }
         if(param2.IsValid() == false)
         {
            return;
         }
         var _loc18_:uint = uint(2 * m_proxyCount);
         var _loc15_:b2Proxy = m_proxyPool[param1];
         var _loc13_:b2BoundValues = new b2BoundValues();
         ComputeBounds(_loc13_.lowerValues,_loc13_.upperValues,param2);
         var _loc14_:b2BoundValues = new b2BoundValues();
         _loc12_ = 0;
         while(_loc12_ < 2)
         {
            _loc7_ = m_bounds[_loc12_][_loc15_.lowerBounds[_loc12_]];
            _loc14_.lowerValues[_loc12_] = _loc7_.value;
            _loc7_ = m_bounds[_loc12_][_loc15_.upperBounds[_loc12_]];
            _loc14_.upperValues[_loc12_] = _loc7_.value;
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < 2)
         {
            _loc19_ = m_bounds[_loc12_];
            _loc20_ = uint(_loc15_.lowerBounds[_loc12_]);
            _loc9_ = uint(_loc15_.upperBounds[_loc12_]);
            _loc11_ = uint(_loc13_.lowerValues[_loc12_]);
            _loc6_ = uint(_loc13_.upperValues[_loc12_]);
            _loc7_ = _loc19_[_loc20_];
            _loc5_ = _loc11_ - _loc7_.value;
            _loc7_.value = _loc11_;
            _loc7_ = _loc19_[_loc9_];
            _loc3_ = _loc6_ - _loc7_.value;
            _loc7_.value = _loc6_;
            if(_loc5_ < 0)
            {
               _loc8_ = _loc20_;
               while(_loc8_ > 0 && _loc11_ < (_loc19_[_loc8_ - 1] as b2Bound).value)
               {
                  _loc7_ = _loc19_[_loc8_];
                  _loc17_ = _loc19_[_loc8_ - 1];
                  _loc10_ = _loc17_.proxyId;
                  _loc24_ = m_proxyPool[_loc17_.proxyId];
                  _loc17_.stabbingCount++;
                  if(_loc17_.IsUpper() == true)
                  {
                     if(TestOverlap(_loc13_,_loc24_))
                     {
                        m_pairManager.AddBufferedPair(param1,_loc10_);
                     }
                     _loc16_ = _loc24_.upperBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_++;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount++;
                  }
                  else
                  {
                     _loc16_ = _loc24_.lowerBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_++;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount--;
                  }
                  _loc16_ = _loc15_.lowerBounds;
                  _loc23_ = int(_loc16_[_loc12_]);
                  _loc23_--;
                  _loc16_[_loc12_] = _loc23_;
                  _loc7_.Swap(_loc17_);
                  _loc8_--;
               }
            }
            if(_loc3_ > 0)
            {
               _loc8_ = _loc9_;
               while(_loc8_ < _loc18_ - 1 && (_loc19_[_loc8_ + 1] as b2Bound).value <= _loc6_)
               {
                  _loc7_ = _loc19_[_loc8_];
                  _loc21_ = _loc19_[_loc8_ + 1];
                  _loc22_ = _loc21_.proxyId;
                  _loc4_ = m_proxyPool[_loc22_];
                  _loc21_.stabbingCount++;
                  if(_loc21_.IsLower() == true)
                  {
                     if(TestOverlap(_loc13_,_loc4_))
                     {
                        m_pairManager.AddBufferedPair(param1,_loc22_);
                     }
                     _loc16_ = _loc4_.lowerBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_--;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount++;
                  }
                  else
                  {
                     _loc16_ = _loc4_.upperBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_--;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount--;
                  }
                  _loc16_ = _loc15_.upperBounds;
                  _loc23_ = int(_loc16_[_loc12_]);
                  _loc23_++;
                  _loc16_[_loc12_] = _loc23_;
                  _loc7_.Swap(_loc21_);
                  _loc8_++;
               }
            }
            if(_loc5_ > 0)
            {
               _loc8_ = _loc20_;
               while(_loc8_ < _loc18_ - 1 && (_loc19_[_loc8_ + 1] as b2Bound).value <= _loc11_)
               {
                  _loc7_ = _loc19_[_loc8_];
                  _loc21_ = _loc19_[_loc8_ + 1];
                  _loc22_ = _loc21_.proxyId;
                  _loc4_ = m_proxyPool[_loc22_];
                  _loc21_.stabbingCount--;
                  if(_loc21_.IsUpper())
                  {
                     if(TestOverlap(_loc14_,_loc4_))
                     {
                        m_pairManager.RemoveBufferedPair(param1,_loc22_);
                     }
                     _loc16_ = _loc4_.upperBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_--;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount--;
                  }
                  else
                  {
                     _loc16_ = _loc4_.lowerBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_--;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount++;
                  }
                  _loc16_ = _loc15_.lowerBounds;
                  _loc23_ = int(_loc16_[_loc12_]);
                  _loc23_++;
                  _loc16_[_loc12_] = _loc23_;
                  _loc7_.Swap(_loc21_);
                  _loc8_++;
               }
            }
            if(_loc3_ < 0)
            {
               _loc8_ = _loc9_;
               while(_loc8_ > 0 && _loc6_ < (_loc19_[_loc8_ - 1] as b2Bound).value)
               {
                  _loc7_ = _loc19_[_loc8_];
                  _loc17_ = _loc19_[_loc8_ - 1];
                  _loc10_ = _loc17_.proxyId;
                  _loc24_ = m_proxyPool[_loc10_];
                  _loc17_.stabbingCount--;
                  if(_loc17_.IsLower() == true)
                  {
                     if(TestOverlap(_loc14_,_loc24_))
                     {
                        m_pairManager.RemoveBufferedPair(param1,_loc10_);
                     }
                     _loc16_ = _loc24_.lowerBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_++;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount--;
                  }
                  else
                  {
                     _loc16_ = _loc24_.upperBounds;
                     _loc23_ = int(_loc16_[_loc12_]);
                     _loc23_++;
                     _loc16_[_loc12_] = _loc23_;
                     _loc7_.stabbingCount++;
                  }
                  _loc16_ = _loc15_.upperBounds;
                  _loc23_ = int(_loc16_[_loc12_]);
                  _loc23_--;
                  _loc16_[_loc12_] = _loc23_;
                  _loc7_.Swap(_loc17_);
                  _loc8_--;
               }
            }
            _loc12_++;
         }
      }
      
      public function Commit() : void
      {
         m_pairManager.Commit();
      }
      
      public function QueryAABB(param1:b2AABB, param2:*, param3:int) : int
      {
         var _loc10_:int = 0;
         var _loc4_:b2Proxy = null;
         var _loc9_:Array = [];
         var _loc12_:Array = [];
         ComputeBounds(_loc9_,_loc12_,param1);
         var _loc5_:Array = [0];
         var _loc6_:Array = [0];
         Query(_loc5_,_loc6_,_loc9_[0],_loc12_[0],m_bounds[0],2 * m_proxyCount,0);
         Query(_loc5_,_loc6_,_loc9_[1],_loc12_[1],m_bounds[1],2 * m_proxyCount,1);
         var _loc8_:int = 0;
         _loc10_ = 0;
         while(_loc10_ < m_queryResultCount && _loc8_ < param3)
         {
            _loc4_ = m_proxyPool[m_queryResults[_loc10_]];
            param2[_loc10_] = _loc4_.userData;
            _loc10_++;
            _loc8_++;
            _loc8_;
         }
         m_queryResultCount = 0;
         IncrementTimeStamp();
         return _loc8_;
      }
      
      public function Validate() : void
      {
         var _loc7_:int = 0;
         var _loc3_:b2Bound = null;
         var _loc4_:* = 0;
         var _loc10_:* = 0;
         var _loc5_:* = 0;
         var _loc2_:b2Bound = null;
         _loc7_ = 0;
         while(_loc7_ < 2)
         {
            _loc3_ = m_bounds[_loc7_];
            _loc4_ = uint(2 * m_proxyCount);
            _loc10_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc2_ = _loc3_[_loc5_];
               if(_loc2_.IsLower() == true)
               {
                  _loc10_++;
               }
               else
               {
                  _loc10_--;
               }
               _loc5_++;
            }
            _loc7_++;
         }
      }
      
      private function ComputeBounds(param1:Array, param2:Array, param3:b2AABB) : void
      {
         var _loc4_:Number = param3.lowerBound.x;
         var _loc5_:Number = param3.lowerBound.y;
         _loc4_ = b2Math.b2Min(_loc4_,m_worldAABB.upperBound.x);
         _loc5_ = b2Math.b2Min(_loc5_,m_worldAABB.upperBound.y);
         _loc4_ = b2Math.b2Max(_loc4_,m_worldAABB.lowerBound.x);
         _loc5_ = b2Math.b2Max(_loc5_,m_worldAABB.lowerBound.y);
         var _loc6_:Number = param3.upperBound.x;
         var _loc7_:Number = param3.upperBound.y;
         _loc6_ = b2Math.b2Min(_loc6_,m_worldAABB.upperBound.x);
         _loc7_ = b2Math.b2Min(_loc7_,m_worldAABB.upperBound.y);
         _loc6_ = b2Math.b2Max(_loc6_,m_worldAABB.lowerBound.x);
         _loc7_ = b2Math.b2Max(_loc7_,m_worldAABB.lowerBound.y);
         param1[0] = uint(m_quantizationFactor.x * (_loc4_ - m_worldAABB.lowerBound.x)) & 65535 - 1;
         param2[0] = uint(m_quantizationFactor.x * (_loc6_ - m_worldAABB.lowerBound.x)) & 0xFFFF | 1;
         param1[1] = uint(m_quantizationFactor.y * (_loc5_ - m_worldAABB.lowerBound.y)) & 65535 - 1;
         param2[1] = uint(m_quantizationFactor.y * (_loc7_ - m_worldAABB.lowerBound.y)) & 0xFFFF | 1;
      }
      
      private function TestOverlapValidate(param1:b2Proxy, param2:b2Proxy) : Boolean
      {
         var _loc5_:int = 0;
         var _loc3_:Array = null;
         var _loc6_:b2Bound = null;
         var _loc4_:b2Bound = null;
         _loc5_ = 0;
         while(_loc5_ < 2)
         {
            _loc3_ = m_bounds[_loc5_];
            _loc6_ = _loc3_[param1.lowerBounds[_loc5_]];
            _loc4_ = _loc3_[param2.upperBounds[_loc5_]];
            if(_loc6_.value > _loc4_.value)
            {
               return false;
            }
            _loc6_ = _loc3_[param1.upperBounds[_loc5_]];
            _loc4_ = _loc3_[param2.lowerBounds[_loc5_]];
            if(_loc6_.value < _loc4_.value)
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      public function TestOverlap(param1:b2BoundValues, param2:b2Proxy) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:Array = null;
         var _loc3_:b2Bound = null;
         _loc5_ = 0;
         while(_loc5_ < 2)
         {
            _loc4_ = m_bounds[_loc5_];
            _loc3_ = _loc4_[param2.upperBounds[_loc5_]];
            if(param1.lowerValues[_loc5_] > _loc3_.value)
            {
               return false;
            }
            _loc3_ = _loc4_[param2.lowerBounds[_loc5_]];
            if(param1.upperValues[_loc5_] < _loc3_.value)
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      private function Query(param1:Array, param2:Array, param3:uint, param4:uint, param5:Array, param6:uint, param7:int) : void
      {
         var _loc8_:b2Bound = null;
         var _loc11_:* = 0;
         var _loc10_:int = 0;
         var _loc13_:int = 0;
         var _loc12_:b2Proxy = null;
         var _loc14_:uint = BinarySearch(param5,param6,param3);
         var _loc9_:uint = BinarySearch(param5,param6,param4);
         _loc11_ = _loc14_;
         while(_loc11_ < _loc9_)
         {
            _loc8_ = param5[_loc11_];
            if(_loc8_.IsLower())
            {
               IncrementOverlapCount(_loc8_.proxyId);
            }
            _loc11_++;
         }
         if(_loc14_ > 0)
         {
            _loc10_ = _loc14_ - 1;
            _loc8_ = param5[_loc10_];
            _loc13_ = int(_loc8_.stabbingCount);
            while(_loc13_)
            {
               _loc8_ = param5[_loc10_];
               if(_loc8_.IsLower())
               {
                  _loc12_ = m_proxyPool[_loc8_.proxyId];
                  if(_loc14_ <= _loc12_.upperBounds[param7])
                  {
                     IncrementOverlapCount(_loc8_.proxyId);
                     _loc13_--;
                  }
               }
               _loc10_--;
            }
         }
         param1[0] = _loc14_;
         param2[0] = _loc9_;
      }
      
      private function IncrementOverlapCount(param1:uint) : void
      {
         var _loc2_:b2Proxy = m_proxyPool[param1];
         if(_loc2_.timeStamp < m_timeStamp)
         {
            _loc2_.timeStamp = m_timeStamp;
            _loc2_.overlapCount = 1;
         }
         else
         {
            _loc2_.overlapCount = 2;
            m_queryResults[m_queryResultCount] = param1;
            ++m_queryResultCount;
         }
      }
      
      private function IncrementTimeStamp() : void
      {
         var _loc1_:* = 0;
         if(m_timeStamp == 65535)
         {
            _loc1_ = 0;
            while(_loc1_ < 512)
            {
               (m_proxyPool[_loc1_] as b2Proxy).timeStamp = 0;
               _loc1_++;
            }
            m_timeStamp = 1;
         }
         else
         {
            ++m_timeStamp;
         }
      }
   }
}

