package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2PairManager
   {
      public var m_broadPhase:b2BroadPhase;
      
      public var m_callback:b2PairCallback;
      
      public var m_pairs:Array;
      
      public var m_freePair:uint;
      
      public var m_pairCount:int;
      
      public var m_pairBuffer:Array;
      
      public var m_pairBufferCount:int;
      
      public var m_hashTable:Array;
      
      public function b2PairManager()
      {
         var _loc1_:* = 0;
         super();
         m_hashTable = new Array(b2Pair.b2_tableCapacity);
         _loc1_ = 0;
         while(_loc1_ < b2Pair.b2_tableCapacity)
         {
            m_hashTable[_loc1_] = b2Pair.b2_nullPair;
            _loc1_++;
         }
         m_pairs = new Array(4096);
         _loc1_ = 0;
         while(_loc1_ < 4096)
         {
            m_pairs[_loc1_] = new b2Pair();
            _loc1_++;
         }
         m_pairBuffer = new Array(4096);
         _loc1_ = 0;
         while(_loc1_ < 4096)
         {
            m_pairBuffer[_loc1_] = new b2BufferedPair();
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < 4096)
         {
            m_pairs[_loc1_].proxyId1 = b2Pair.b2_nullProxy;
            m_pairs[_loc1_].proxyId2 = b2Pair.b2_nullProxy;
            m_pairs[_loc1_].userData = null;
            m_pairs[_loc1_].status = 0;
            m_pairs[_loc1_].next = _loc1_ + 1;
            _loc1_++;
         }
         m_pairs[4095].next = b2Pair.b2_nullPair;
         m_pairCount = 0;
         m_pairBufferCount = 0;
      }
      
      public static function Hash(param1:uint, param2:uint) : uint
      {
         var _loc3_:uint = uint(param2 << 16 & 4294901760 | param1);
         _loc3_ = uint(~_loc3_ + (_loc3_ << 15 & 4294934528));
         _loc3_ ^= _loc3_ >> 12 & 0x0FFFFF;
         _loc3_ += _loc3_ << 2 & 4294967292;
         _loc3_ ^= _loc3_ >> 4 & 0x0FFFFFFF;
         _loc3_ *= 2057;
         return uint(_loc3_ ^ _loc3_ >> 16 & 0xFFFF);
      }
      
      public static function Equals(param1:b2Pair, param2:uint, param3:uint) : Boolean
      {
         return param1.proxyId1 == param2 && param1.proxyId2 == param3;
      }
      
      public static function EqualsPair(param1:b2BufferedPair, param2:b2BufferedPair) : Boolean
      {
         return param1.proxyId1 == param2.proxyId1 && param1.proxyId2 == param2.proxyId2;
      }
      
      public function Initialize(param1:b2BroadPhase, param2:b2PairCallback) : void
      {
         m_broadPhase = param1;
         m_callback = param2;
      }
      
      public function AddBufferedPair(param1:int, param2:int) : void
      {
         var _loc3_:b2BufferedPair = null;
         var _loc4_:b2Pair = AddPair(param1,param2);
         if(_loc4_.IsBuffered() == false)
         {
            _loc4_.SetBuffered();
            _loc3_ = m_pairBuffer[m_pairBufferCount];
            _loc3_.proxyId1 = _loc4_.proxyId1;
            _loc3_.proxyId2 = _loc4_.proxyId2;
            ++m_pairBufferCount;
         }
         _loc4_.ClearRemoved();
         if(b2BroadPhase.s_validate)
         {
            ValidateBuffer();
         }
      }
      
      public function RemoveBufferedPair(param1:int, param2:int) : void
      {
         var _loc3_:b2BufferedPair = null;
         var _loc4_:b2Pair = Find(param1,param2);
         if(_loc4_ == null)
         {
            return;
         }
         if(_loc4_.IsBuffered() == false)
         {
            _loc4_.SetBuffered();
            _loc3_ = m_pairBuffer[m_pairBufferCount];
            _loc3_.proxyId1 = _loc4_.proxyId1;
            _loc3_.proxyId2 = _loc4_.proxyId2;
            ++m_pairBufferCount;
         }
         _loc4_.SetRemoved();
         if(b2BroadPhase.s_validate)
         {
            ValidateBuffer();
         }
      }
      
      public function Commit() : void
      {
         var _loc1_:b2BufferedPair = null;
         var _loc2_:int = 0;
         var _loc6_:b2Pair = null;
         var _loc4_:b2Proxy = null;
         var _loc5_:b2Proxy = null;
         var _loc7_:int = 0;
         var _loc3_:Array = m_broadPhase.m_proxyPool;
         _loc2_ = 0;
         while(_loc2_ < m_pairBufferCount)
         {
            _loc1_ = m_pairBuffer[_loc2_];
            _loc6_ = Find(_loc1_.proxyId1,_loc1_.proxyId2);
            _loc6_.ClearBuffered();
            _loc4_ = _loc3_[_loc6_.proxyId1];
            _loc5_ = _loc3_[_loc6_.proxyId2];
            if(_loc6_.IsRemoved())
            {
               if(_loc6_.IsFinal() == true)
               {
                  m_callback.PairRemoved(_loc4_.userData,_loc5_.userData,_loc6_.userData);
               }
               _loc1_ = m_pairBuffer[_loc7_];
               _loc1_.proxyId1 = _loc6_.proxyId1;
               _loc1_.proxyId2 = _loc6_.proxyId2;
               _loc7_++;
            }
            else if(_loc6_.IsFinal() == false)
            {
               _loc6_.userData = m_callback.PairAdded(_loc4_.userData,_loc5_.userData);
               _loc6_.SetFinal();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc7_)
         {
            _loc1_ = m_pairBuffer[_loc2_];
            RemovePair(_loc1_.proxyId1,_loc1_.proxyId2);
            _loc2_++;
         }
         m_pairBufferCount = 0;
         if(b2BroadPhase.s_validate)
         {
            ValidateTable();
         }
      }
      
      private function AddPair(param1:uint, param2:uint) : b2Pair
      {
         var _loc3_:* = 0;
         var _loc6_:b2Pair = null;
         if(param1 > param2)
         {
            _loc3_ = param1;
            param1 = param2;
            param2 = _loc3_;
         }
         var _loc5_:uint = uint(Hash(param1,param2) & b2Pair.b2_tableMask);
         _loc6_ = _loc6_ = FindHash(param1,param2,_loc5_);
         if(_loc6_ != null)
         {
            return _loc6_;
         }
         var _loc4_:uint = m_freePair;
         _loc6_ = m_pairs[_loc4_];
         m_freePair = _loc6_.next;
         _loc6_.proxyId1 = param1;
         _loc6_.proxyId2 = param2;
         _loc6_.status = 0;
         _loc6_.userData = null;
         _loc6_.next = m_hashTable[_loc5_];
         m_hashTable[_loc5_] = _loc4_;
         ++m_pairCount;
         return _loc6_;
      }
      
      private function RemovePair(param1:uint, param2:uint) : *
      {
         var _loc8_:b2Pair = null;
         var _loc4_:* = 0;
         var _loc6_:* = 0;
         var _loc5_:* = undefined;
         if(param1 > param2)
         {
            _loc4_ = param1;
            param1 = param2;
            param2 = _loc4_;
         }
         var _loc9_:uint = uint(Hash(param1,param2) & b2Pair.b2_tableMask);
         var _loc3_:uint = uint(m_hashTable[_loc9_]);
         var _loc7_:b2Pair = null;
         while(_loc3_ != b2Pair.b2_nullPair)
         {
            if(Equals(m_pairs[_loc3_],param1,param2))
            {
               _loc6_ = _loc3_;
               _loc8_ = m_pairs[_loc3_];
               if(_loc7_)
               {
                  _loc7_.next = _loc8_.next;
               }
               else
               {
                  m_hashTable[_loc9_] = _loc8_.next;
               }
               _loc8_ = m_pairs[_loc6_];
               _loc5_ = _loc8_.userData;
               _loc8_.next = m_freePair;
               _loc8_.proxyId1 = b2Pair.b2_nullProxy;
               _loc8_.proxyId2 = b2Pair.b2_nullProxy;
               _loc8_.userData = null;
               _loc8_.status = 0;
               m_freePair = _loc6_;
               --m_pairCount;
               return _loc5_;
            }
            _loc7_ = m_pairs[_loc3_];
            _loc3_ = _loc7_.next;
         }
         return null;
      }
      
      private function Find(param1:uint, param2:uint) : b2Pair
      {
         var _loc3_:* = 0;
         if(param1 > param2)
         {
            _loc3_ = param1;
            param1 = param2;
            param2 = _loc3_;
         }
         var _loc4_:uint = uint(Hash(param1,param2) & b2Pair.b2_tableMask);
         return FindHash(param1,param2,_loc4_);
      }
      
      private function FindHash(param1:uint, param2:uint, param3:uint) : b2Pair
      {
         var _loc5_:b2Pair = null;
         var _loc4_:uint = uint(m_hashTable[param3]);
         _loc5_ = m_pairs[_loc4_];
         while(_loc4_ != b2Pair.b2_nullPair && Equals(_loc5_,param1,param2) == false)
         {
            _loc4_ = _loc5_.next;
            _loc5_ = m_pairs[_loc4_];
         }
         if(_loc4_ == b2Pair.b2_nullPair)
         {
            return null;
         }
         return _loc5_;
      }
      
      private function ValidateBuffer() : void
      {
      }
      
      private function ValidateTable() : void
      {
      }
   }
}

