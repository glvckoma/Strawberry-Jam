package gui
{
   import avmplus.getQualifiedClassName;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class EmoticonUtility
   {
      public static const NORMAL_TYPE:int = 0;
      
      public static const PLAYER_WALL_TYPE:int = 1;
      
      private static const MEMBER_EMOTES_WINDOW_OFFSET_Y:Number = -70;
      
      private static const MEMBER_EMOTES_ROWS:int = 2;
      
      private static const EMOTES_MARGIN_TOP:int = 14;
      
      private static const EMOTES_MARGIN_LEFT:int = 11;
      
      private static const EMOTES_STEP_V:int = 23;
      
      private static const EMOTES_STEP_H:int = 33;
      
      private static const EMOTES_ROW_MAX:uint = 7;
      
      private static const EMOTES_WINDOW_OFFSET_X:Number = -109;
      
      private static const NUM_MEMBER_EMOTES:int = 14;
      
      private static var displaySprites:Array = ["emoMO_angry_sml","emoMO_combat_sml","emoMO_confused_sml","emoMO_laugh_sml","emoMO_phantom_sml","emoMO_sad_sml","emoMO_sleep_sml","emoMO_heartbreak_sml","emoMO_lovesick_sml","emoMO_ninja_sml","emoMO_sick_sml","emoMO_smiley_sml","emoMO_sunglasses_sml","emoMO_vampire_sml","emo_peace_sml","emo_angry_sml","emo_blush_sml","emo_confused_sml","emo_cool_sml","emo_cry_sml","emo_evil_sml","emo_grin_sml","emo_happy_sml","emo_laugh_sml","emo_love_sml","emo_rainy_sml","emo_sick_sml","emo_sleep_sml","emo_sneaky_sml","emo_surprise_sml","emo_think_sml","emo_tongue_sml","emo_wink_sml","emo_game_sml","emo_hearts_sml","emo_brokenHeart_sml","emo_burger_sml","emo_icecream_sml","emo_sword_sml","emo_star1_sml","emo_star2_sml","emo_star3_sml"];
      
      private static var displaySpritesNotAllowedInPlayerWall:Array = ["emoMO_angry_sml","emoMO_combat_sml","emoMO_confused_sml","emoMO_laugh_sml","emoMO_phantom_sml","emoMO_sad_sml","emoMO_sleep_sml","emoMO_heartbreak_sml","emoMO_lovesick_sml","emoMO_ninja_sml","emoMO_sick_sml","emoMO_smiley_sml","emoMO_sunglasses_sml","emoMO_vampire_sml","emo_confused_sml","emo_love_sml","emo_rainy_sml","emo_sick_sml","emo_hearts_sml","emo_brokenHeart_sml","emo_sword_sml"];
      
      private static var emoteSprites:Array = ["emoMO_angry","emoMO_combat","emoMO_confused","emoMO_laugh","emoMO_phantom","emoMO_sad","emoMO_sleep","emoMO_heartbreak","emoMO_lovesick","emoMO_ninja","emoMO_sick","emoMO_smiley","emoMO_sunglasses","emoMO_vampire","emo_peace","emo_angry","emo_blush","emo_confused","emo_cool","emo_cry","emo_evil","emo_grin","emo_happy","emo_laugh","emo_love","emo_rainy","emo_sick","emo_sleep","emo_sneaky","emo_surprise","emo_think","emo_tongue","emo_wink","emo_game","emo_hearts","emo_brokenHeart","emo_burger","emo_icecream","emo_sword","emo_star1","emo_star2","emo_star3"];
      
      private static var _emoteStrings:Object = {};
      
      private static var _emoteChatStrings:Object = {};
      
      _emoteStrings["emoMO_angry"] = [":mad:"];
      _emoteStrings["emoMO_combat"] = [":scuffle:"];
      _emoteStrings["emoMO_confused"] = [":puzzle:"];
      _emoteStrings["emoMO_laugh"] = [":joy:"];
      _emoteStrings["emoMO_phantom"] = [":phantom:"];
      _emoteStrings["emoMO_sad"] = [":sad:"];
      _emoteStrings["emoMO_sleep"] = [":sleepy:"];
      _emoteStrings["emoMO_heartbreak"] = [":breakingheart:"];
      _emoteStrings["emoMO_lovesick"] = [":lovesick:"];
      _emoteStrings["emoMO_ninja"] = [":ninja:"];
      _emoteStrings["emoMO_sick"] = [":queasy:"];
      _emoteStrings["emoMO_smiley"] = [":smiley:"];
      _emoteStrings["emoMO_sunglasses"] = [":sunglasses:"];
      _emoteStrings["emoMO_vampire"] = [":vampire:"];
      _emoteStrings["emo_peace"] = [":peace:"];
      _emoteStrings["emo_angry"] = [":angry:","X(","X-("];
      _emoteStrings["emo_blush"] = [":blush:"];
      _emoteStrings["emo_brokenHeart"] = [":brokenheart:"];
      _emoteStrings["emo_burger"] = [":burger:"];
      _emoteStrings["emo_confused"] = [":confused:",":/"];
      _emoteStrings["emo_cool"] = [":cool:"];
      _emoteStrings["emo_cry"] = [":cry:"];
      _emoteStrings["emo_evil"] = [":evil:"];
      _emoteStrings["emo_game"] = [":game:"];
      _emoteStrings["emo_grin"] = [":D",":grin:"];
      _emoteStrings["emo_happy"] = [":)",":happy:"];
      _emoteStrings["emo_hearts"] = [":hearts:","<3<3<3"];
      _emoteStrings["emo_icecream"] = [":icecream:"];
      _emoteStrings["emo_laugh"] = [":laugh:",":))"];
      _emoteStrings["emo_love"] = [":love:","(l)","(L)","(^_^)<3"];
      _emoteStrings["emo_rainy"] = [":rainy:"];
      _emoteStrings["emo_sick"] = [":sick:"];
      _emoteStrings["emo_sleep"] = [":tired:","|)","|-)",":zzz:","-_-","-_-zzz","--_"];
      _emoteStrings["emo_sneaky"] = [":sneaky:"];
      _emoteStrings["emo_surprise"] = [":surprise:",":O",":-O"];
      _emoteStrings["emo_sword"] = [":sword:"];
      _emoteStrings["emo_think"] = [":think:",":?"];
      _emoteStrings["emo_tongue"] = [":P",":p",":tongue:"];
      _emoteStrings["emo_wink"] = [":wink:",";)",";-)"];
      _emoteStrings["emo_star1"] = [":singlestar:"];
      _emoteStrings["emo_star2"] = [":doublestar:"];
      _emoteStrings["emo_star3"] = [":triplestar:"];
      _emoteChatStrings["emoMO_angry"] = [":mad:"];
      _emoteChatStrings["emoMO_combat"] = [":scuffle:"];
      _emoteChatStrings["emoMO_laugh"] = [":joy:"];
      _emoteChatStrings["emoMO_phantom"] = [":phantom:"];
      _emoteChatStrings["emoMO_sad"] = [":sad:"];
      _emoteChatStrings["emoMO_sleep"] = [":sleepy:"];
      _emoteChatStrings["emoMO_heartbreak"] = [":breakingheart:"];
      _emoteChatStrings["emoMO_lovesick"] = [":lovesick:"];
      _emoteChatStrings["emoMO_ninja"] = [":ninja:"];
      _emoteChatStrings["emoMO_sick"] = [":queasy:"];
      _emoteChatStrings["emoMO_smiley"] = [":smiley:"];
      _emoteChatStrings["emoMO_sunglasses"] = [":sunglasses:"];
      _emoteChatStrings["emoMO_vampire"] = [":vampire:"];
      _emoteChatStrings["emo_peace"] = [":peace:"];
      _emoteChatStrings["emo_angry"] = [":angry:"];
      _emoteChatStrings["emo_blush"] = [":blush:"];
      _emoteChatStrings["emo_burger"] = [":burger:"];
      _emoteChatStrings["emo_cool"] = [":cool:"];
      _emoteChatStrings["emo_cry"] = [":cry:"];
      _emoteChatStrings["emo_evil"] = [":evil:"];
      _emoteChatStrings["emo_game"] = [":game:"];
      _emoteChatStrings["emo_grin"] = [":D",":grin:"];
      _emoteChatStrings["emo_happy"] = [":)",":happy:"];
      _emoteChatStrings["emo_icecream"] = [":icecream:"];
      _emoteChatStrings["emo_laugh"] = [":laugh:",":))"];
      _emoteChatStrings["emo_sleep"] = [":tired:","|)","|-)",":zzz:","-_-","-_-zzz","--_"];
      _emoteChatStrings["emo_sneaky"] = [":sneaky:"];
      _emoteChatStrings["emo_surprise"] = [":surprise:",":O",":-O"];
      _emoteChatStrings["emo_think"] = [":think:"];
      _emoteChatStrings["emo_tongue"] = [":P",":tongue:"];
      _emoteChatStrings["emo_wink"] = [":wink:",";)",";-)"];
      _emoteChatStrings["emo_star1"] = [":singlestar:"];
      _emoteChatStrings["emo_star2"] = [":doublestar:"];
      _emoteChatStrings["emo_star3"] = [":triplestar:"];
      
      public function EmoticonUtility()
      {
         super();
      }
      
      public static function setupEmotes(param1:int, param2:MovieClip, param3:Boolean, param4:Function, param5:Function, param6:Function) : MovieClip
      {
         var _loc9_:* = 0;
         var _loc7_:Sprite = null;
         var _loc12_:int = param3 ? 0 : 7 * 2;
         var _loc8_:Number = param1 == 0 ? -55 : 15;
         var _loc11_:MovieClip = new MovieClip();
         var _loc10_:int = 0;
         _loc9_ = 0;
         for(; _loc9_ < displaySprites.length; _loc9_++)
         {
            if(param1 == 0 || displaySpritesNotAllowedInPlayerWall.indexOf(displaySprites[_loc9_]) == -1)
            {
               _loc7_ = GETDEFINITIONBYNAME(displaySprites[_loc9_]);
               if(param1 == 0 && _loc10_ < 7 * 2)
               {
                  if(!param3)
                  {
                     _loc10_++;
                     continue;
                  }
                  _loc7_.x = 11 + _loc10_ % 7 * 33 + -109;
                  _loc7_.y = 14 + Math.floor(_loc10_ / 7) * 23 + -70;
               }
               else
               {
                  _loc7_.x = 11 + _loc10_ % 7 * 33 + -109;
                  _loc7_.y = 14 + Math.floor((_loc10_ - _loc12_) / 7) * 23 + _loc8_;
                  if(!param3)
                  {
                     _loc7_.y += 35;
                  }
               }
               _loc11_.addChild(_loc7_);
               _loc7_.addChild(GETDEFINITIONBYNAME("emo_place_holder"));
               _loc7_.buttonMode = true;
               _loc7_.useHandCursor = true;
               _loc7_.mouseChildren = false;
               _loc7_.tabEnabled = true;
               _loc7_.tabChildren = false;
               _loc7_.addEventListener("click",param4,false,0,true);
               _loc7_.addEventListener("rollOver",param5,false,0,true);
               _loc7_.addEventListener("rollOut",param5,false,0,true);
               _loc10_++;
            }
         }
         return _loc11_;
      }
      
      public static function getEmoteString(param1:Sprite) : String
      {
         if(_emoteStrings[getQualifiedClassName(param1)])
         {
            return _emoteStrings[getQualifiedClassName(param1)][0];
         }
         return null;
      }
      
      public static function matchEmoteString(param1:String, param2:Boolean = false) : Object
      {
         var _loc3_:* = null;
         for each(var _loc4_ in emoteSprites)
         {
            if(_emoteStrings[_loc4_].indexOf(param1) != -1)
            {
               if(param2 == false && _loc4_.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup("emotes","useLockedEmote");
                  return {
                     "sprite":null,
                     "status":false
                  };
               }
               return {
                  "sprite":GETDEFINITIONBYNAME(_loc4_),
                  "status":true
               };
            }
         }
         return {
            "sprite":null,
            "status":true
         };
      }
      
      public static function doesStringMatchAnEmote(param1:String) : Boolean
      {
         for each(var _loc2_ in emoteSprites)
         {
            if(_emoteStrings[_loc2_].indexOf(param1) != -1)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function emoteForId(param1:int) : Sprite
      {
         if(param1 >= 0 && param1 < emoteSprites.length)
         {
            return GETDEFINITIONBYNAME(emoteSprites[param1]);
         }
         return null;
      }
      
      public static function idForEmote(param1:Sprite) : int
      {
         return emoteSprites.indexOf(getQualifiedClassName(param1));
      }
      
      public static function stringForId(param1:int) : String
      {
         if(param1 >= 0 && param1 < emoteSprites.length)
         {
            return _emoteStrings[emoteSprites[param1]][0];
         }
         return null;
      }
      
      public static function handleSmileyClick(param1:Object, param2:Function) : void
      {
         var _loc3_:int = int(displaySprites.indexOf(getQualifiedClassName(param1)));
         if(_loc3_ != -1 && _loc3_ < 14 && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup("emotes","useLockedEmote");
         }
         else
         {
            param2(GETDEFINITIONBYNAME(emoteSprites[_loc3_]));
         }
      }
      
      public static function formatStringForSmiley(param1:String, param2:int, param3:Array, param4:Boolean) : Object
      {
         var _loc24_:* = null;
         var _loc22_:* = null;
         var _loc8_:Boolean = false;
         var _loc10_:String = null;
         var _loc16_:int = 0;
         var _loc9_:RegExp = null;
         var _loc14_:* = null;
         var _loc18_:String = null;
         var _loc25_:MovieClip = null;
         var _loc23_:String = null;
         var _loc12_:* = null;
         var _loc19_:String = null;
         var _loc13_:String = null;
         var _loc11_:int = 0;
         var _loc17_:int = 0;
         var _loc5_:Boolean = false;
         var _loc20_:Array = null;
         var _loc21_:Array = [];
         for each(_loc24_ in _emoteChatStrings)
         {
            for each(_loc22_ in _loc24_)
            {
               _loc9_ = new RegExp(escapeRegExp(_loc22_),"gm");
               _loc21_ = param1.split(_loc9_);
               if(param4)
               {
                  param1 = _loc21_.join("|*|" + _loc22_);
               }
               else if(_loc21_.length > 1)
               {
                  param1 = "";
                  _loc16_ = 0;
                  while(_loc16_ < _loc21_.length)
                  {
                     _loc10_ = _loc21_[_loc16_];
                     if(_loc16_ == 0 && _loc10_ != " ")
                     {
                        param1 += _loc10_;
                     }
                     else if(!_loc8_)
                     {
                        if(_loc10_ != "" && _loc10_ != " ")
                        {
                           param1 += "|*|" + _loc22_ + _loc10_;
                        }
                        else
                        {
                           param1 += "|*|" + _loc22_;
                        }
                        _loc8_ = true;
                     }
                     else if(_loc10_ != "" && _loc10_ != " ")
                     {
                        param1 += _loc10_;
                     }
                     _loc16_++;
                  }
               }
            }
         }
         var _loc15_:Array = param1.split("|*|");
         if(_loc15_[0] == "")
         {
            _loc15_.shift();
         }
         var _loc6_:* = _loc15_.length == 1;
         var _loc26_:String = "false";
         _loc17_ = 0;
         while(_loc17_ < _loc15_.length)
         {
            if(_loc17_ == 0 && _loc15_[_loc17_] == "")
            {
               _loc26_ = "true";
            }
            for(_loc18_ in _emoteChatStrings)
            {
               for each(_loc14_ in _emoteChatStrings[_loc18_])
               {
                  _loc19_ = _loc15_[_loc17_];
                  if(_loc19_ == "" || _loc19_.charAt() == " ")
                  {
                     break;
                  }
                  _loc12_ = _loc14_;
                  _loc11_ = int(_loc19_.indexOf(_loc12_));
                  if(_loc11_ != -1)
                  {
                     _loc13_ = "";
                     _loc16_ = 0;
                     while(_loc16_ < _loc14_.length)
                     {
                        _loc13_ += _loc19_.charAt(_loc11_ + _loc16_);
                        _loc16_++;
                     }
                  }
                  if(_loc13_ == _loc12_)
                  {
                     if(!(_loc18_.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember))
                     {
                        _loc13_ = "";
                        _loc25_ = GETDEFINITIONBYNAME(_loc18_ + "_sml");
                        _loc25_.y = _loc25_.y - 3;
                        if(_loc17_ - 1 > 0 && _loc26_ == "false" && _loc15_[_loc17_ - 1].charAt(_loc15_[_loc17_ - 1].length - 1) != " ")
                        {
                           _loc5_ = true;
                        }
                        if(_loc25_.width <= 20)
                        {
                           _loc23_ = " . ";
                        }
                        else if(_loc25_.width <= 22)
                        {
                           _loc23_ = " .  ";
                        }
                        else if(_loc25_.width <= 25)
                        {
                           _loc23_ = " .   ";
                        }
                        else
                        {
                           _loc23_ = "  .     ";
                        }
                        _loc15_[_loc17_] = _loc23_ + (_loc5_ == true ? " " : "") + _loc15_[_loc17_].substr(_loc14_.length,_loc15_[_loc17_].length);
                        param3.push({
                           "strindex":param2,
                           "emoticon":_loc25_,
                           "added":false,
                           "smileystart":_loc26_
                        });
                     }
                     break;
                  }
               }
            }
            _loc20_ = _loc15_[_loc17_].split("");
            param2 += _loc20_.length;
            _loc17_++;
         }
         return {
            "str":_loc15_.join(""),
            "smileyArray":param3,
            "stringIndex":param2,
            "hasOnlyOne":_loc6_
         };
      }
      
      public static function getSmallSmileyMCForEmoteString(param1:String) : MovieClip
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         for(_loc2_ in _emoteStrings)
         {
            for each(_loc3_ in _emoteStrings[_loc2_])
            {
               if(_loc3_ == param1)
               {
                  if(_loc2_.slice(3,5) == "MO" && !gMainFrame.userInfo.isMember)
                  {
                     return null;
                  }
                  return GETDEFINITIONBYNAME(_loc2_ + "_sml");
               }
            }
         }
         return null;
      }
      
      private static function escapeRegExp(param1:String) : String
      {
         return param1.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g,"\\$&");
      }
   }
}

