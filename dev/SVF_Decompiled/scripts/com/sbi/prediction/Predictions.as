package com.sbi.prediction
{
   import flash.utils.ByteArray;
   
   public class Predictions
   {
      private const CACHE_SIZE:int = 255;
      
      private const VARIANT_FORM_MULTIPLIER:Number = 0.99;
      
      private const PUNCTUATION_INSERTION_MULTIPLIER:Number = 0.95;
      
      private const NEARBY_KEY_REPLACEMENT_MULTIPLIER:Number = 1;
      
      private const TRANSPOSITION_MULTIPLIER:Number = 0.3;
      
      private const INSERTION_MULTIPLIER:Number = 0.3;
      
      private const SUBSTITUTION_MULTIPLIER:Number = 0.3;
      
      private const DELETION_MULTIPLIER:Number = 0.3;
      
      private const ZERO_CORRECTION_PREFIX_MULTIPLIER:Number = 10;
      
      private const NO_FREQUENCY_INPUT_MATCH_WEIGHT:Number = 30;
      
      private const EXACT_WORD_MATCH_WEIGHT:Number = 15;
      
      private const WORD_EXTENSION_MULTIPLIER:Number = 0.9;
      
      private const CANDIDATES_PER_BATCH:Number = 100;
      
      private const _rootToAccentedForm:Object = {
         "a":"ÁáĂăǍǎÂâÄäȦȧẠạȀȁÀàẢảȂȃĀāĄąÅåḀḁȺⱥÃãǼǽǢǣÆæ",
         "b":"ḂḃḄḅƁɓḆḇɃƀƂƃ",
         "c":"ĆćČčÇçĈĉĊċƇƈȻȼ",
         "d":"ĎďḐḑḒḓḊḋḌḍƊɗḎḏĐđƋƌð",
         "e":"ÉéĔĕĚěȨȩÊêḘḙËëĖėẸẹȄȅÈèẺẻȆȇĒēĘę",
         "f":"ḞḟƑƒ",
         "g":"ǴǵĞğǦǧĢģĜĝĠġƓɠḠḡǤǥ",
         "h":"ḪḫȞȟḨḩĤĥⱧⱨḦḧḢḣḤḥĦħ",
         "i":"ÍíĬĭǏǐÎîÏïỊịȈȉÌìỈỉȊȋĪīĮįƗɨĨĩḬḭı",
         "j":"ĴĵɈɉ",
         "k":"ḰḱǨǩĶķⱩⱪꝂꝃḲḳƘƙḴḵꝀꝁ",
         "l":"ĹĺȽƚĽľĻļḼḽḶḷⱠⱡꝈꝉḺḻĿŀⱢɫŁł",
         "m":"ḾḿṀṁṂṃⱮɱ",
         "n":"ŃńŇňŅņṊṋṄṅṆṇǸǹƝɲṈṉȠƞÑñ",
         "o":"ÓóŎŏǑǒÔôÖöȮȯỌọŐőȌȍÒòỎỏƠơȎȏꝊꝋꝌꝍŌōǪǫØøÕõŒœ",
         "p":"ṔṕṖṗꝒꝓƤƥⱣᵽꝐꝑ",
         "q":"Ꝗꝗ",
         "r":"ŔŕŘřŖŗṘṙṚṛȐȑȒȓṞṟɌɍⱤɽ",
         "s":"ŚśŠšŞşŜŝȘșṠṡṢṣß",
         "t":"ŤťŢţṰṱȚțȾⱦṪṫṬṭƬƭṮṯƮʈŦŧ",
         "u":"ÚúŬŭǓǔÛûṶṷÜüṲṳỤụŰűȔȕÙùỦủƯưȖȗŪūŲųŮůŨũṴṵ",
         "v":"ṾṿƲʋṼṽ",
         "w":"ẂẃŴŵẄẅẆẇẈẉẀẁⱲⱳ",
         "x":"ẌẍẊẋ",
         "y":"ÝýŶŷŸÿẎẏỴỵỲỳƳƴỶỷỾỿȲȳɎɏỸỹ",
         "z":"ŹźŽžẐẑⱫⱬŻżẒẓȤȥẔẕƵƶ",
         "α":"άΆ",
         "ε":"έΈ",
         "η":"ήΉ",
         "ι":"ίϊΐΊΪ",
         "ο":"όΌ",
         "υ":"ύϋΰΎΫ",
         "ω":"ώΏ",
         "$":"$"
      };
      
      private const SMALLEST_WEIGHT:Number = 0.5;
      
      private var _tree:Array;
      
      private var _maxWordLength:int;
      
      private var _characterTable:Array = [];
      
      private var _variants:Array = [];
      
      private var _rootform:Array = [];
      
      private var _nearbyKeys:Array;
      
      private var _cache:LRUCache;
      
      private var _validChars:SetDictionary = null;
      
      private var _useType:int;
      
      private var _isFromAutoCorrect:Boolean;
      
      private var _candidates:BoundedPriorityQueue;
      
      private var _suggestions:BoundedPriorityQueue;
      
      private var _capitalize:Boolean;
      
      private var _status:Object;
      
      private var _cacheKey:String;
      
      private var _input:String;
      
      private var _maxSuggestions:Number;
      
      private var _maxCorrections:Number;
      
      private var _autoCorrections:SetDictionary;
      
      private var _badWords:SetDictionary;
      
      public function Predictions()
      {
         super();
      }
      
      public function setDictionary(param1:ByteArray) : void
      {
         var _loc7_:* = 0;
         var _loc2_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc18_:String = null;
         var _loc10_:int = 0;
         var _loc13_:int = 0;
         var _loc16_:String = null;
         var _loc12_:int = 0;
         var _loc9_:int = 0;
         var _loc15_:Array = null;
         var _loc6_:int = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc20_:String = null;
         _cache = new LRUCache(255);
         var _loc14_:* = param1;
         if(uint32(_loc14_,0) !== 1182289747 || uint32(_loc14_,4) !== 1145652052)
         {
            throw new Error("Invalid dictionary file");
         }
         if(uint32(_loc14_,8) !== 1)
         {
            throw new Error("Unknown dictionary version");
         }
         _maxWordLength = _loc14_[12] + 1;
         var _loc21_:int = uint16(_loc14_,13);
         _loc7_ = 0;
         while(_loc7_ < _loc21_)
         {
            _loc2_ = 15 + _loc7_ * 6;
            _characterTable[uint16(_loc14_,_loc2_)] = uint32(_loc14_,_loc2_ + 2);
            _loc7_++;
         }
         _autoCorrections = new SetDictionary();
         var _loc23_:int = uint16(_loc14_,15 + _loc21_ * 6);
         _loc2_ = 15 + _loc21_ * 6 + 2;
         _loc7_ = 0;
         while(_loc7_ < _loc23_)
         {
            _loc11_ = int(_loc14_[_loc2_++]);
            _loc18_ = "";
            _loc8_ = 0;
            while(_loc8_ < _loc11_)
            {
               _loc10_ = uint16(_loc14_,_loc2_);
               _loc18_ += String.fromCharCode(_loc10_);
               _loc2_ += 2;
               _loc8_++;
            }
            _loc13_ = int(_loc14_[_loc2_++]);
            _loc8_ = 0;
            while(_loc8_ < _loc13_)
            {
               _loc16_ = "";
               _loc12_ = int(_loc14_[_loc2_++]);
               _loc9_ = 0;
               while(_loc9_ < _loc12_)
               {
                  _loc10_ = uint16(_loc14_,_loc2_);
                  _loc16_ += String.fromCharCode(_loc10_);
                  _loc2_ += 2;
                  _loc9_++;
               }
               _autoCorrections.insertKey(_loc16_,_loc18_);
               _loc8_++;
            }
            _loc7_++;
         }
         _tree = [];
         _loc7_ = _loc2_;
         while(_loc7_ < param1.length)
         {
            _tree.push(param1[_loc7_]);
            _loc7_++;
         }
         var _loc22_:Object = {};
         for(var _loc19_ in _rootToAccentedForm)
         {
            _loc15_ = _rootToAccentedForm[_loc19_].split("");
            _loc6_ = int(_loc15_.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc22_[_loc15_[_loc7_]] = _loc19_;
               _loc7_++;
            }
         }
         for(var _loc17_ in _characterTable)
         {
            _variants[_loc17_] = "";
            _loc3_ = String.fromCharCode(_loc17_);
            _loc4_ = _loc3_.toUpperCase();
            _loc5_ = _loc3_.toLowerCase();
            if(_loc4_ !== _loc3_)
            {
               var _loc25_:* = _loc17_;
               var _loc24_:* = _variants[_loc25_] + _loc4_;
               _variants[_loc25_] = _loc24_;
               _rootform[_loc17_] = _loc17_;
            }
            if(_loc5_ !== _loc3_)
            {
               _loc24_ = _loc17_;
               _loc25_ = _variants[_loc24_] + _loc5_;
               _variants[_loc24_] = _loc25_;
               _rootform[_loc17_] = _loc5_.charCodeAt(0);
            }
            if(_loc22_[_loc3_])
            {
               _loc20_ = _loc22_[_loc3_];
               _rootform[_loc17_] = _loc20_.charCodeAt(0);
               _variants[_loc17_] += _loc20_ + _loc20_.toUpperCase();
            }
            _badWords = new SetDictionary();
            _badWords.insertArray(["anal","ass","asses","asshole","assholes","aswhole","beastiality","bitch","blowjob","blowjobs","boner","boners","brewski","brewskis","chaturbate","clit","clits","clitoris","cock","cocked","cocking","cocks","cumshot","cunnilingus","douche","ejaculate","ejaculated","ejaculates","ejaculating","erection","erections","faggot","faggots","fecken","fellatio","fellation","fuck","fucked","fucker","fuckers","fucking","fucks","masturbate","masturbates","masturbating","masturbation","masturbator","masturbators","nigga","niggas","nigger","niggers","orgasm","orgasms","penis","porn","porno","pornographic","pornography","pussy","pussies","rape","raped","rapes","raping","sex","vagina","virgin","virginity","virgins","password","dick","dicks","passwords","bitches","accounts","douches","vaginas","cum","cums","cumming","fuk","fuks","fuking","fuked","sexy","douchebag","douchebags","drug","drugs","beer","beers","shit","shits","shitting","address","email","emails","emailing","emailed","addresses"
            ,"cell","motherfucker","motherfucking","motherfuck","motherfucks","motherfucked"]);
         }
         generateValidChars();
      }
      
      public function getRootFormOfChar(param1:int) : int
      {
         return _rootform[param1];
      }
      
      private function setNearbyKeys(param1:*) : void
      {
         _cache = new LRUCache(255);
         _nearbyKeys = param1;
      }
      
      private function generateValidChars() : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         _validChars = new SetDictionary();
         for(var _loc6_ in _variants)
         {
            _validChars.insertKeyValue(String.fromCharCode(_loc6_));
            _loc4_ = _variants[_loc6_].split("");
            for each(var _loc1_ in _loc4_)
            {
               _validChars.insertKeyValue(_loc1_);
            }
            _loc5_ = int(_rootform[_loc6_]);
            if(_loc5_ && _nearbyKeys && _nearbyKeys[_loc5_])
            {
               for each(var _loc2_ in _nearbyKeys)
               {
                  _validChars.insertKeyValue(String.fromCharCode(_loc2_));
                  if(_variants[_loc2_])
                  {
                     for each(var _loc3_ in _variants[_loc2_])
                     {
                        _validChars.insertKeyValue(_loc3_);
                     }
                  }
               }
            }
         }
      }
      
      public function predict(param1:String, param2:Number, param3:Number, param4:Number, param5:int) : Array
      {
         var input:String = param1;
         var maxSuggestions:Number = param2;
         var maxCandidates:Number = param3;
         var maxCorrections:Number = param4;
         var useType:int = param5;
         if(!_tree)
         {
            throw Error("not initialized");
         }
         _input = input;
         _maxSuggestions = maxSuggestions;
         _maxCorrections = maxCorrections;
         _useType = useType;
         _candidates = new BoundedPriorityQueue(maxCandidates);
         _suggestions = new BoundedPriorityQueue(maxSuggestions);
         _capitalize = input.charAt(0) === input.charAt(0).toUpperCase();
         _status = {
            "state":"predicting",
            "abort":function():void
            {
               if(this.state !== "done" && this.state !== "aborted")
               {
                  this.state = "aborting";
               }
            }
         };
         _cacheKey = input + "," + maxSuggestions + "," + maxCandidates + "," + maxCorrections;
         _isFromAutoCorrect = false;
         if(input.length > 0 && !_badWords.containsKey(input))
         {
            if(_autoCorrections.containsKey(input))
            {
               _input = String(_autoCorrections.getValue(input));
               _isFromAutoCorrect = true;
            }
            return getSuggestions();
         }
         _status.state = "done";
         _status.suggestions = [];
         return _status.suggestions;
      }
      
      private function getSuggestions() : Array
      {
         var _loc3_:Array = null;
         var _loc2_:int = 0;
         var _loc1_:Object = _cache.getData(_cacheKey);
         if(_loc1_)
         {
            _status.state = "done";
            _status.suggestions = _loc1_;
            return _status.suggestions;
         }
         var _loc4_:Boolean = false;
         if(_input.length > _maxWordLength)
         {
            _loc4_ = true;
         }
         else
         {
            _loc3_ = _input.split("");
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               if(!_validChars.containsKey(_loc3_[_loc2_]))
               {
                  _loc4_ = true;
                  break;
               }
               _loc2_++;
            }
         }
         if(_loc4_)
         {
            _status.state = "done";
            _status.suggestions = [];
            return _status.suggestions;
         }
         addCandidate(0,_input,"",1,1,0);
         return processCandidates();
      }
      
      private function addCandidate(param1:*, param2:*, param3:*, param4:*, param5:*, param6:*) : void
      {
         var _loc7_:Number = param5 * param4;
         if(param6 === 0 && param4 > 0.9 * 0.9)
         {
            _loc7_ += 100;
         }
         else if(param6 === 0)
         {
            _loc7_ += param5 / 32 * 10;
         }
         if(_loc7_ < 0.5)
         {
            return;
         }
         if(_loc7_ <= _suggestions.threshold)
         {
            return;
         }
         _candidates.add({
            "pointer":param1,
            "input":param2,
            "output":param3,
            "multiplier":param4,
            "weight":_loc7_,
            "corrections":param6
         },_loc7_);
      }
      
      private function addSuggestion(param1:String, param2:Number, param3:int) : void
      {
         var _loc5_:int = 0;
         if(_capitalize)
         {
            param1 = param1.charAt(0).toUpperCase() + param1.substring(1);
         }
         var _loc4_:int = int(_suggestions.items.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(_suggestions.items[_loc5_][0] === param1)
            {
               if(_suggestions.priorities[_loc5_] >= param2)
               {
                  return;
               }
               _suggestions.removeItemAt(_loc5_);
               break;
            }
            _loc5_++;
         }
         _suggestions.add([param1,param2,param3,_isFromAutoCorrect],param2);
      }
      
      private function processCandidates() : Array
      {
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         if(aborted())
         {
            return _status.suggestions;
         }
         _loc2_ = 0;
         while(_loc2_ < 100)
         {
            _loc1_ = _candidates.remove();
            if(!_loc1_ || _loc1_.weight <= _suggestions.threshold)
            {
               _status.state = "done";
               _status.suggestions = _suggestions.items;
               _cache.insertKeyInCache(_cacheKey,_status.suggestions);
               return _status.suggestions;
            }
            process(_loc1_);
            _loc2_++;
         }
         return processCandidates();
      }
      
      private function process(param1:Object) : void
      {
         var _loc16_:String = null;
         var _loc2_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc14_:String = null;
         var _loc17_:Boolean = false;
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc6_:int = 0;
         var _loc15_:Number = NaN;
         var _loc7_:String = param1.input;
         var _loc10_:String = param1.output;
         var _loc3_:Number = Number(param1.multiplier);
         var _loc13_:Number = Number(param1.corrections);
         var _loc11_:Object = {};
         if(_loc7_.length > 0)
         {
            _loc16_ = _loc7_.charAt(0);
            _loc2_ = Number(_loc7_.charCodeAt(0));
         }
         _loc18_ = Number(param1.pointer);
         while(_loc18_ !== -1)
         {
            readNode(_loc18_,_loc11_);
            _loc8_ = Number(_loc11_.freq);
            _loc4_ = _loc8_ * _loc3_;
            if(_loc13_ > 0 && (_loc4_ <= _candidates.threshold || _loc4_ < 0.5))
            {
               break;
            }
            _loc14_ = _loc10_ + String.fromCharCode(_loc11_.ch);
            if(_loc7_.length === 0)
            {
               if(_loc11_.ch === 0 && canUseWithType(_loc11_.useType,_loc11_.specificType))
               {
                  if(_input.length == _loc10_.length)
                  {
                     if(_input.toUpperCase() === _loc10_.toUpperCase())
                     {
                        _loc17_ = true;
                     }
                     else
                     {
                        _loc5_ = 0;
                        while(_loc5_ < _loc10_.length)
                        {
                           if(_rootform[_loc10_.charCodeAt(_loc5_)] != _input.charCodeAt(_loc5_))
                           {
                              _loc17_ = false;
                              break;
                           }
                           _loc17_ = true;
                           _loc5_++;
                        }
                     }
                  }
                  if(_loc17_)
                  {
                     addSuggestion(_loc10_,_loc11_.freq === 1 ? 30 : _loc4_ + 15,_loc11_.useType);
                  }
                  else
                  {
                     addSuggestion(_loc10_,_loc4_,_loc11_.useType);
                  }
               }
               else
               {
                  addCandidate(_loc11_.center,_loc7_,_loc14_,_loc3_ * 0.9,_loc8_,_loc13_);
               }
            }
            else if(_loc11_.ch === 0)
            {
               if(_loc7_.length === 1)
               {
                  addCandidate(_loc18_,"",_loc10_,_loc3_ * 0.3,_loc8_,_loc13_ + 1);
               }
            }
            else
            {
               if(_loc11_.ch === _loc2_)
               {
                  addCandidate(_loc11_.center,_loc7_.substring(1),_loc14_,_loc3_,_loc8_,_loc13_);
               }
               else if(_variants[_loc11_.ch].indexOf(_loc16_) !== -1)
               {
                  addCandidate(_loc11_.center,_loc7_.substring(1),_loc14_,_loc3_ * 0.99,_loc8_,_loc13_);
               }
               else if(_loc13_ < _maxCorrections)
               {
                  _loc9_ = int(_rootform[_loc11_.ch]);
                  _loc12_ = int(_rootform[_loc2_]);
                  _loc6_ = 0;
                  if(_loc6_)
                  {
                     _loc15_ = Math.max(_loc6_ * 1,0.3);
                     addCandidate(_loc11_.center,_loc7_.substring(1),_loc14_,_loc3_ * _loc15_,_loc8_,_loc13_ + 1);
                  }
                  else if(_loc10_.length > 0)
                  {
                     addCandidate(_loc11_.center,_loc7_.substring(1),_loc14_,_loc3_ * 0.3,_loc8_,_loc13_ + 1);
                  }
               }
               if(!_variants[_loc11_.ch])
               {
                  addCandidate(_loc11_.center,_loc7_,_loc14_,_loc3_ * 0.95,_loc8_,_loc13_);
               }
               else if(_loc13_ < _maxCorrections && _loc10_.length > 0)
               {
                  addCandidate(_loc11_.center,_loc7_,_loc14_,_loc3_ * 0.3,_loc8_,_loc13_ + 1);
               }
               if(_loc13_ < _maxCorrections && _loc7_.length > 1 && _loc10_.length > 0 && (_loc11_.ch === _loc7_.charCodeAt(1) || _variants[_loc11_.ch].indexOf(_loc7_.charAt(1)) !== -1))
               {
                  addCandidate(_loc11_.center,_loc7_.charAt(0) + _loc7_.substring(2),_loc14_,_loc3_ * 0.3,_loc8_,_loc13_ + 1);
                  addCandidate(_loc11_.center,_loc7_.substring(2),_loc14_,_loc3_ * 0.3,_loc8_,_loc13_ + 1);
               }
            }
            _loc18_ = Number(_loc11_.next);
         }
      }
      
      private function canUseWithType(param1:int, param2:Boolean) : Boolean
      {
         if(_useType == 0)
         {
            return true;
         }
         if(param2)
         {
            return (param1 & _useType) > 0;
         }
         if(param1 == 0)
         {
            return true;
         }
         if((param1 & _useType) == 0)
         {
            return true;
         }
         return false;
      }
      
      private function readNode(param1:Number, param2:Object) : void
      {
         var _loc4_:* = false;
         if(param1 === -1)
         {
            throw Error("Assertion error: followed invalid pointer");
         }
         var _loc6_:Number = Number(_tree[param1++]);
         var _loc3_:Number = _loc6_ & 0x80;
         var _loc8_:Number = _loc6_ & 0x40;
         var _loc5_:Number = _loc6_ & 0x20;
         param2.freq = (_loc6_ & 0x1F) + 1;
         var _loc7_:Number = 0;
         param2.specificType = false;
         if(_loc3_)
         {
            param2.ch = _tree[param1++];
            if(_loc8_)
            {
               param2.ch = (param2.ch << 8) + _tree[param1++];
            }
         }
         else
         {
            param2.ch = 0;
            _loc7_ = Number(_tree[param1++]);
            _loc4_ = _loc7_ >> 7 > 0;
            if(_loc4_)
            {
               param2.specificType = true;
               _loc7_ = _loc7_ * -1 & 0xFF;
            }
         }
         param2.useType = _loc7_;
         if(_loc5_)
         {
            param2.next = (_tree[param1++] << 16) + (_tree[param1++] << 8) + _tree[param1++];
         }
         else
         {
            param2.next = -1;
         }
         if(_loc3_)
         {
            param2.center = param1;
         }
         else
         {
            param2.center = -1;
         }
      }
      
      private function aborted() : Boolean
      {
         if(_status.state === "aborting")
         {
            _status.state = "aborted";
            return true;
         }
         return false;
      }
      
      private function uint32(param1:ByteArray, param2:Number) : int
      {
         return (param1[param2] << 24) + (param1[param2 + 1] << 16) + (param1[param2 + 2] << 8) + param1[param2 + 3];
      }
      
      private function uint16(param1:ByteArray, param2:Number) : int
      {
         return (param1[param2] << 8) + param1[param2 + 1];
      }
   }
}

