package pet
{
   import flash.display.MovieClip;
   import localization.LocalizationManager;
   
   public class GuiPet extends PetBase
   {
      public var idx:int;
      
      private var _petName:String;
      
      private var _onPetLoadedCallback:Function;
      
      public function GuiPet(param1:Number, param2:int, param3:uint, param4:uint, param5:uint, param6:int, param7:String, param8:int, param9:int, param10:int, param11:Function)
      {
         _onPetLoadedCallback = param11;
         super(param1,param3,param4,param5,param8,param9,param10,onPetLoaded);
         this.idx = param2;
         _petName = param7;
      }
      
      public function set petName(param1:String) : void
      {
         _petName = param1;
      }
      
      public function get petName() : String
      {
         if(_petDef.isEgg && !PetManager.hasHatched(_createdTs))
         {
            return "";
         }
         return LocalizationManager.translatePetName(_petName);
      }
      
      public function get createdTs() : Number
      {
         return _createdTs;
      }
      
      public function clone(param1:Function) : GuiPet
      {
         return new GuiPet(_createdTs,idx,_lBits,_uBits,_eBits,getType(),_petName,_traitDefId,_toyDefId,_foodDefId,param1);
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         if(_onPetLoadedCallback != null)
         {
            _onPetLoadedCallback(param1,this);
         }
      }
   }
}

