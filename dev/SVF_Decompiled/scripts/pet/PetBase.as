package pet
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PetBase extends Sprite
   {
      public static const DEF_ID_CAT:int = 1;
      
      public static const DEF_ID_FROG:int = 2;
      
      public static const DEF_ID_DUCK:int = 3;
      
      public static const DEF_ID_DOG:int = 4;
      
      public static const DEF_ID_BFLY:int = 5;
      
      public static const DEF_ID_HAMS:int = 6;
      
      public static const DEF_ID_BAT:int = 7;
      
      public static const DEF_ID_SEAHORSE:int = 8;
      
      public static const DEF_ID_ANGLER:int = 9;
      
      public static const DEF_ID_REINDEER:int = 10;
      
      public static const DEF_ID_SNAKE:int = 11;
      
      public static const DEF_ID_JELLYFISH:int = 12;
      
      public static const DEF_ID_BUNNY:int = 13;
      
      public static const DEF_ID_HUMMINGBIRD:int = 14;
      
      public static const DEF_ID_TURTLE:int = 15;
      
      public static const DEF_ID_MONKEY:int = 16;
      
      public static const DEF_ID_TARANTUAL:int = 17;
      
      public static const DEF_ID_FOX:int = 18;
      
      public static const DEF_ID_OWL:int = 19;
      
      public static const DEF_ID_TIGER:int = 20;
      
      public static const DEF_ID_ARCTIC_WOLF:int = 21;
      
      public static const DEF_ID_RACCOON:int = 22;
      
      public static const DEF_ID_JOEY:int = 23;
      
      public static const DEF_ID_EAGLET:int = 24;
      
      public static const DEF_ID_CHEETAH:int = 25;
      
      public static const DEF_ID_RHINO:int = 26;
      
      public static const DEF_ID_GIRAFFE:int = 27;
      
      public static const DEF_ID_SUGAR_GLIDER:int = 28;
      
      public static const DEF_ID_LION_CUB:int = 29;
      
      public static const DEF_ID_PANDA:int = 30;
      
      public static const DEF_ID_POLAR_BEAR_CUB:int = 31;
      
      public static const DEF_ID_GECKO:int = 32;
      
      public static const DEF_ID_PONY:int = 34;
      
      public static const DEF_ID_PIGLET:int = 35;
      
      public static const DEF_ID_FERRET:int = 36;
      
      public static const DEF_ID_ELEPHANT:int = 37;
      
      public static const DEF_ID_ARMADILLO:int = 38;
      
      public static const DEF_ID_PEACOCK:int = 39;
      
      public static const DEF_ID_BEE:int = 40;
      
      public static const DEF_ID_ROOSTER:int = 41;
      
      public static const DEF_ID_SKUNK:int = 42;
      
      public static const DEF_ID_TURKEY:int = 43;
      
      public static const DEF_ID_PENGUIN:int = 44;
      
      public static const DEF_ID_SNOW_LEOPARD:int = 45;
      
      public static const DEF_ID_MANITS:int = 46;
      
      public static const DEF_ID_LADYBUG:int = 47;
      
      public static const DEF_ID_CRICKET:int = 48;
      
      public static const DEF_ID_SQUIRREL:int = 49;
      
      public static const DEF_ID_MOUSE:int = 50;
      
      public static const DEF_ID_FIREFLY:int = 51;
      
      public static const DEF_ID_LEMUR:int = 52;
      
      public static const DEF_ID_HIPPO:int = 53;
      
      public static const DEF_ID_GOAT:int = 54;
      
      public static const DEF_ID_MEERKAT:int = 55;
      
      public static const DEF_ID_GOLDEN_BUNNY:int = 56;
      
      public static const DEF_ID_PHANTOM:int = 57;
      
      public static const DEF_ID_SEAL:int = 58;
      
      public static const DEF_ID_OTTER:int = 59;
      
      public static const DEF_ID_PHANTOM_RARE:int = 60;
      
      public static const DEF_ID_GROUND_HOG:int = 61;
      
      public static const DEF_ID_LLAMA:int = 62;
      
      public static const DEF_ID_ARCTIC_FOX:int = 63;
      
      public static const DEF_ID_HYENA:int = 64;
      
      public static const DEF_ID_SLOTH:int = 65;
      
      public static const DEF_ID_DOVE:int = 66;
      
      public static const DEF_ID_CHICK:int = 67;
      
      public static const DEF_ID_GOLDEN_ARMADILLO:int = 68;
      
      public static const DEF_ID_FALCON:int = 69;
      
      public static const DEF_ID_CROCODILE:int = 70;
      
      public static const DEF_ID_PLATYPUS:int = 71;
      
      public static const DEF_ID_PHANTOM_JW:int = 72;
      
      public static const DEF_ID_GOLDEN_PONY:int = 73;
      
      public static const DEF_ID_SHARK:int = 74;
      
      public static const DEF_ID_DOLPHIN:int = 75;
      
      public static const DEF_ID_ECHIDNA:int = 76;
      
      public static const DEF_ID_KOALA:int = 77;
      
      public static const DEF_ID_LYNX:int = 80;
      
      public static const DEF_ID_OCTOPUS:int = 81;
      
      public static const DEF_ID_FENNEC_FOX_JW:int = 82;
      
      public static const DEF_ID_HEDGEHOG:int = 83;
      
      public static const DEF_ID_SCORPION:int = 84;
      
      public static const DEF_ID_CROW:int = 85;
      
      public static const DEF_ID_MOOSE:int = 86;
      
      public static const DEF_ID_POODLE:int = 87;
      
      public static const DEF_ID_LOVEBUNNY:int = 88;
      
      public static const DEF_ID_SABERTOOTH:int = 89;
      
      public static const DEF_ID_DIREWOLF:int = 90;
      
      public static const DEF_ID_DODO:int = 91;
      
      public static const DEF_ID_FANTASY_PEACOCK:int = 92;
      
      public static const DEF_ID_MILLIPEDE:int = 93;
      
      public static const DEF_ID_MOTH:int = 94;
      
      public static const DEF_ID_VULTURE:int = 95;
      
      public static const DEF_ID_COYOTE:int = 96;
      
      public static const DEF_ID_MEAGYNS:int = 97;
      
      public static const DEF_ID_FALCON2:int = 98;
      
      public static const DEF_ID_LOVE_BUG:int = 99;
      
      public static const DEF_ID_FLYING_PIG:int = 100;
      
      public static const DEF_ID_SPARROW:int = 101;
      
      public static const DEF_ID_FENNEC_FOX:int = 102;
      
      public static const DEF_ID_CARDINAL:int = 103;
      
      public static const DEF_ID_FRILLED_LIZARD:int = 104;
      
      public static const DEF_ID_DRAGONFLY:int = 105;
      
      public static const DEF_ID_MAGENTA_SEAL:int = 106;
      
      public static const DEF_ID_PANGOLIN:int = 107;
      
      public static const DEF_ID_CAMEL:int = 108;
      
      public static const DEF_ID_SNAIL:int = 109;
      
      public static const DEF_ID_GALACTIC_FIREFLY:int = 110;
      
      public static const DEF_ID_CATERPILLAR:int = 111;
      
      public static const DEF_ID_LAMB:int = 112;
      
      public static const TYPE_LAND_GROUND:int = 0;
      
      public static const TYPE_LAND_AIR:int = 1;
      
      public static const TYPE_OCEAN_GROUND:int = 2;
      
      public static const TYPE_OCEAN_AIR:int = 3;
      
      public static const TYPE_AMPHIB_GROUND:int = 4;
      
      public static const TYPE_AMPHIB_AIR:int = 5;
      
      protected var _petDef:PetDef;
      
      protected var _lBits:uint;
      
      protected var _uBits:uint;
      
      protected var _eBits:uint;
      
      protected var _traitDefId:uint;
      
      protected var _toyDefId:uint;
      
      protected var _foodDefId:uint;
      
      protected var _content:MovieClip;
      
      protected var _createdTs:Number;
      
      private var _mediaHelper:MediaHelper;
      
      private var _onPetLoadedCallback:Function;
      
      public function PetBase(param1:Number, param2:uint, param3:uint, param4:uint, param5:uint, param6:uint, param7:uint, param8:Function)
      {
         super();
         _createdTs = param1;
         _lBits = param2;
         _uBits = param3;
         _eBits = param4;
         _traitDefId = param5;
         _toyDefId = param6;
         _foodDefId = param7;
         _onPetLoadedCallback = param8;
         _petDef = PetManager.getPetDef(param2 & 0xFF);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(mediaIdForDefId(_petDef.defId),onMediaLoaded,true);
      }
      
      public function destroy() : void
      {
      }
      
      public function getPetTitleName() : String
      {
         return LocalizationManager.translateIdOnly(_petDef.titleStrId);
      }
      
      public function isGround() : Boolean
      {
         if(_petDef.isEgg && !PetManager.hasHatched(_createdTs))
         {
            return true;
         }
         return PetManager.isGround(_petDef.type);
      }
      
      public function isEggAndHasNotHatched() : Boolean
      {
         if(_petDef.isEgg)
         {
            return PetManager.hasHatched(_createdTs) == false;
         }
         return false;
      }
      
      public function isEgg() : Boolean
      {
         return _petDef.isEgg;
      }
      
      public function getType() : int
      {
         return _petDef.type;
      }
      
      public function getDefID() : int
      {
         return _petDef.defId;
      }
      
      public function canGoInOcean() : Boolean
      {
         if(_petDef.type == 2 || _petDef.type == 3 || _petDef.type == 4 || _petDef.type == 5)
         {
            return true;
         }
         return false;
      }
      
      public function canGoOnLand() : Boolean
      {
         if(_petDef.type == 0 || _petDef.type == 1 || _petDef.type == 4 || _petDef.type == 5)
         {
            return true;
         }
         return false;
      }
      
      public function getLBits() : uint
      {
         return _lBits;
      }
      
      public function getUBits() : uint
      {
         return _uBits;
      }
      
      public function getEBits() : uint
      {
         return _eBits;
      }
      
      public function getContent() : MovieClip
      {
         return _content;
      }
      
      public function getCreatedTs() : Number
      {
         return _createdTs;
      }
      
      public function colorMyItem(param1:int, param2:MovieClip, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int) : void
      {
         if(_content)
         {
            _content.colorMe(param1,param2,param3,param4,param5,param6,param7,param8);
         }
      }
      
      public function updateAllBits(param1:uint, param2:uint, param3:uint) : void
      {
         if(_content)
         {
            _lBits = param1;
            _uBits = param2;
            _eBits = param3;
            PetManager.setPetState(_content,_lBits,_uBits,_eBits);
         }
      }
      
      public function updateUBits(param1:uint) : void
      {
         _uBits = param1;
         PetManager.setPetState(_content,_lBits,_uBits,_eBits);
      }
      
      public function animatePet(param1:Boolean) : void
      {
         if(_content && "willItAnimate" in _content.pet)
         {
            _content.pet.willItAnimate(param1);
         }
      }
      
      protected function setSparkle(param1:int) : void
      {
         if(_content)
         {
            _content.pet.setSparkle(param1);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _content = param1;
            this.addChild(_content);
            _mediaHelper.destroy();
            delete _content.mediaHelper;
            delete _content.passback;
            PetManager.setPetState(_content,_lBits,_uBits,_eBits);
            if(_onPetLoadedCallback != null)
            {
               _onPetLoadedCallback(_content);
            }
            _content.pet.setAnim(0);
            if(_petDef.isEgg)
            {
               if(_content.pet.hasOwnProperty("setEggDayInt"))
               {
                  _loc2_ = _createdTs > 0 ? Math.floor((Utility.getInitialEpochTime() - _createdTs) / 86400) : 0;
                  _content.pet.setEggDayInt(_loc2_);
               }
            }
         }
      }
      
      private function mediaIdForDefId(param1:int) : int
      {
         var _loc2_:PetDef = PetManager.getPetDef(param1);
         if(_loc2_)
         {
            return _loc2_.mediaRefId;
         }
         return -1;
      }
      
      public function get personalityDefId() : uint
      {
         return _traitDefId;
      }
      
      public function set personalityDefId(param1:uint) : void
      {
         _traitDefId = param1;
      }
      
      public function get favoriteToyDefId() : uint
      {
         return _toyDefId;
      }
      
      public function set favoriteToyDefId(param1:uint) : void
      {
         _toyDefId = param1;
      }
      
      public function get favoriteFoodDefId() : uint
      {
         return _foodDefId;
      }
      
      public function set favoriteFoodDefId(param1:uint) : void
      {
         _foodDefId = param1;
      }
   }
}

