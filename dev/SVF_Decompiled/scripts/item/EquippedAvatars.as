package item
{
   import com.sbi.bit.ScalableBitField;
   
   public class EquippedAvatars
   {
      private static const MAX_ARRAY_SIZE:int = Math.ceil(1000 / 32);
      
      private var _avInvIdStates:ScalableBitField;
      
      private var _forceInUse:Boolean;
      
      public function EquippedAvatars(param1:String = "")
      {
         super();
         _avInvIdStates = new ScalableBitField(param1,MAX_ARRAY_SIZE);
      }
      
      public static function forced() : EquippedAvatars
      {
         var _loc1_:EquippedAvatars = new EquippedAvatars();
         _loc1_._forceInUse = true;
         return _loc1_;
      }
      
      public function isEquippedOnAnyAvatars() : Boolean
      {
         return _avInvIdStates.areAnyBitsSet();
      }
      
      public function isEquipped(param1:int) : Boolean
      {
         if(_forceInUse)
         {
            return true;
         }
         return param1 != -1 && _avInvIdStates.isBitSet(param1);
      }
      
      public function setEquipped(param1:int, param2:Boolean) : void
      {
         if(_forceInUse)
         {
            setForceInUse(param2);
         }
         else if(param1 != -1)
         {
            _avInvIdStates.setBit(param1,param2);
         }
      }
      
      public function setForceInUse(param1:Boolean) : void
      {
         _forceInUse = param1;
         if(!param1)
         {
            _avInvIdStates.unsetAll();
         }
      }
      
      public function get isEquippedForAll() : Boolean
      {
         return _forceInUse;
      }
      
      public function set isEquippedForAll(param1:Boolean) : void
      {
         _forceInUse = param1;
      }
      
      public function clone() : EquippedAvatars
      {
         var _loc1_:EquippedAvatars = new EquippedAvatars(_avInvIdStates.toString());
         _loc1_.isEquippedForAll = _forceInUse;
         return _loc1_;
      }
      
      public function equals(param1:EquippedAvatars) : Boolean
      {
         return param1 != null && _forceInUse == param1.isEquippedForAll && _avInvIdStates.equals(param1._avInvIdStates);
      }
   }
}

