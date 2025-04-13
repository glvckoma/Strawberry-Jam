package Box2D.Collision
{
   public class b2ContactID
   {
      public var features:Features = new Features();
      
      public var _key:uint;
      
      public function b2ContactID()
      {
         super();
         features._m_id = this;
      }
      
      public function Set(param1:b2ContactID) : void
      {
         key = param1._key;
      }
      
      public function Copy() : b2ContactID
      {
         var _loc1_:b2ContactID = new b2ContactID();
         _loc1_.key = key;
         return _loc1_;
      }
      
      public function get key() : uint
      {
         return _key;
      }
      
      public function set key(param1:uint) : void
      {
         _key = param1;
         features._referenceEdge = _key & 0xFF;
         features._incidentEdge = (_key & 0xFF00) >> 8 & 0xFF;
         features._incidentVertex = (_key & 0xFF0000) >> 16 & 0xFF;
         features._flip = (_key & 4278190080) >> 24 & 0xFF;
      }
   }
}

