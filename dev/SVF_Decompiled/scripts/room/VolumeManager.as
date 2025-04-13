package room
{
   import com.sbi.loader.SceneLoader;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class VolumeManager
   {
      public static const VOLUMETYPE_NONE:int = 0;
      
      public static const VOLUMETYPE_GAME:int = 1;
      
      public static const VOLUMETYPE_DEN_VOLUME:int = 2;
      
      public static const VOLUMETYPE_SPLASH:int = 3;
      
      public static const VOLUMETYPE_STORE_PET:int = 4;
      
      public static const VOLUMETYPE_SOCIAL_GROUP:int = 5;
      
      public static const VOLUMETYPE_SOCIAL_EMOTICON:int = 6;
      
      public static const VOLUMETYPE_GUI_ACTION:int = 7;
      
      public static const VOLUMETYPE_RECYCLE_ACCESSORY:int = 8;
      
      public static const VOLUMETYPE_RECYCLE_DEN_ITEM:int = 9;
      
      public static const VOLUMETYPE_TRIGGER_WALKIN:int = 11;
      
      public static const VOLUMETYPE_GENERIC_LIST:int = 12;
      
      public static const VOLUMETYPE_CLICK_EMOTICON:int = 13;
      
      public static const VOLUMETYPE_AIR:int = 14;
      
      public static const VOLUMETYPE_DYNAMIC_COLLISION:int = 15;
      
      public static const VOLUMETYPE_DYNAMIC_AIR:int = 16;
      
      public static const VOLUMETYPE_DYNAMIC_PHANTOM_AIR:int = 17;
      
      public static const VOLUMETYPE_PLANT:int = 18;
      
      public static const VOLUMETYPE_STEALTH:int = 19;
      
      public static const VOLUMETYPE_ADVENTURE_INTERACT:int = 20;
      
      public static const VOLUMETYPE_DARKSOFT:int = 21;
      
      public static const VOLUMETYPE_DARKHARD:int = 22;
      
      public static const VOLUMETYPE_FALLINGPHANTOM:int = 23;
      
      private var _scene:SceneLoader;
      
      private var _volumes:Array;
      
      private var _layers:Array;
      
      private var _volumeActors:Array;
      
      private var _roomObjs:Array;
      
      private var _offset:Point;
      
      private var _socialTriggersVolumes:Array;
      
      private var _splashVolumes:Array;
      
      private var _ladderVolumes:Array;
      
      public function VolumeManager()
      {
         super();
      }
      
      public function setScene(param1:SceneLoader, param2:Point) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         release();
         _socialTriggersVolumes = [];
         _splashVolumes = [];
         _ladderVolumes = [];
         _roomObjs = [];
         _volumeActors = [];
         _scene = param1;
         _offset = param2;
         _volumes = param1.getActorList("ActorVolume");
         _layers = _scene.getActorList("ActorLayer");
         if(_volumes)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumes.length)
            {
               _loc4_ = _volumes[_loc3_];
               newVolume(_loc4_);
               _loc3_++;
            }
         }
      }
      
      public function release() : void
      {
         var _loc1_:int = 0;
         var _loc3_:* = null;
         if(_volumeActors)
         {
            _loc1_ = 0;
            while(_loc1_ < _volumeActors.length)
            {
               for each(var _loc2_ in _volumeActors[_loc1_].interactiveObjs)
               {
                  _loc2_.release();
               }
               _loc1_++;
            }
         }
         if(_roomObjs)
         {
            for each(_loc3_ in _roomObjs)
            {
               _loc3_.release();
            }
         }
         _socialTriggersVolumes = null;
         _volumes = null;
         _layers = null;
         _splashVolumes = null;
         _ladderVolumes = null;
      }
      
      public function get hasSplashVolume() : Boolean
      {
         return _splashVolumes && _splashVolumes.length;
      }
      
      public function clearHold(param1:Boolean = true, param2:Boolean = false) : void
      {
         for each(var _loc3_ in _roomObjs)
         {
            if(param2)
            {
               _loc3_.setMouseOver(false);
            }
            else if(!_loc3_.isMouseOver())
            {
               if(param1)
               {
                  _loc3_.mouseDown(false);
               }
               if(!_loc3_.hold)
               {
                  _loc3_.setDir(-1);
               }
               _loc3_.onEnterFrame();
            }
         }
      }
      
      public function testPointInVolume(param1:Point, param2:Object) : Boolean
      {
         return pointInVolume(param1,param2.v);
      }
      
      public function testMouseVolumes(param1:Point, param2:Boolean, param3:Function = null) : Object
      {
         var _loc4_:* = null;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:Object = null;
         var _loc7_:RoomObject = null;
         if(_volumeActors)
         {
            clearHold(param2,true);
            if(param2)
            {
               _loc5_ = 0;
               while(_loc5_ < _volumeActors.length)
               {
                  _loc8_ = _volumeActors[_loc5_];
                  if(isMouseVolume(_loc8_.type) && pointInVolume(param1,_loc8_.v))
                  {
                     if(_loc8_.interactiveObjs)
                     {
                        _loc6_ = 0;
                        while(_loc6_ < _loc8_.interactiveObjs.length)
                        {
                           if(param3 == null || param3 != null && param3(_loc8_.name))
                           {
                              _loc7_ = _loc8_.interactiveObjs[_loc6_];
                              _loc7_.setDir(1);
                              _loc7_.mouseDown(true);
                              _loc7_.setMouseOver(true);
                              _loc7_.onEnterFrame();
                           }
                           _loc6_++;
                        }
                     }
                     _loc4_ = _loc8_;
                  }
                  _loc5_++;
               }
            }
            _loc5_ = 0;
            while(_loc5_ < _volumeActors.length)
            {
               _loc8_ = _volumeActors[_loc5_];
               if(isMouseVolume(_loc8_.type) && _loc8_.interactiveObjs && pointInVolume(param1,_loc8_.v))
               {
                  _loc6_ = 0;
                  while(_loc6_ < _loc8_.interactiveObjs.length)
                  {
                     if(param3 == null || param3 != null && param3(_loc8_.name))
                     {
                        _loc7_ = _loc8_.interactiveObjs[_loc6_];
                        if(!_loc7_.hold)
                        {
                           _loc7_.setDir(1);
                           _loc7_.setMouseOver(true);
                           _loc7_.onEnterFrame();
                        }
                     }
                     _loc6_++;
                  }
               }
               _loc5_++;
            }
            clearHold(param2);
         }
         return _loc4_;
      }
      
      public function testPlantVolumes(param1:Point) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:* = null;
         if(_volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumeActors.length)
            {
               _loc4_ = _volumeActors[_loc3_];
               if(isPlantVolume(_loc4_.type) && pointInVolume(param1,_loc4_.v))
               {
                  _loc2_ = _loc4_;
                  break;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function setVolumesEnabled(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(_volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumeActors.length)
            {
               _loc4_ = _volumeActors[_loc3_];
               if(_loc4_.name == param1)
               {
                  _loc4_.enabled = param2;
               }
               _loc3_++;
            }
         }
      }
      
      public function testStealthVolumes(param1:Point) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:* = null;
         if(_volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumeActors.length)
            {
               _loc4_ = _volumeActors[_loc3_];
               if(_loc4_.enabled && isStealthVolume(_loc4_.type) && pointInVolume(param1,_loc4_.v))
               {
                  _loc2_ = _loc4_;
                  break;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function testAvatarVolumes(param1:Point) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:* = null;
         if(_volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumeActors.length)
            {
               _loc4_ = _volumeActors[_loc3_];
               if(isAvatarVolume(_loc4_.type) && pointInVolume(param1,_loc4_.v))
               {
                  _loc2_ = _loc4_;
                  break;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function testAvatarVolume(param1:String, param2:Point) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(_volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumeActors.length)
            {
               _loc4_ = _volumeActors[_loc3_];
               if(_loc4_.name == param1)
               {
                  if(pointInVolume(param2,_loc4_.v))
                  {
                     return true;
                  }
                  break;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      public function testSplashVolumes(param1:Point) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:* = null;
         _loc3_ = 0;
         while(_loc3_ < _splashVolumes.length)
         {
            _loc4_ = _splashVolumes[_loc3_];
            if(pointInVolume(param1,_loc4_.v))
            {
               _loc2_ = _loc4_;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function testLadderVolumes(param1:Point) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:* = null;
         _loc3_ = 0;
         while(_loc3_ < _ladderVolumes.length)
         {
            _loc4_ = _ladderVolumes[_loc3_];
            if(pointInVolume(param1,_loc4_.v))
            {
               _loc2_ = _loc4_;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function isSceneSet() : Boolean
      {
         return _ladderVolumes != null;
      }
      
      public function updateSocialTriggers(param1:Object) : void
      {
         var _loc2_:* = undefined;
         if(_socialTriggersVolumes && _socialTriggersVolumes.length)
         {
            clearSocialTriggers();
            for(var _loc3_ in param1)
            {
               _loc2_ = param1[_loc3_];
               testSocialTriggers(new Point(_loc2_.x,_loc2_.y),_loc2_.animId);
            }
            updateSocialTriggersStage();
         }
      }
      
      private function clearSocialTriggers() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         for each(_loc2_ in _socialTriggersVolumes)
         {
            for each(_loc1_ in _loc2_.interactiveObjs)
            {
               if(_loc1_ is RoomObject_SocialTrigger)
               {
                  _loc1_.clearCount();
               }
            }
         }
      }
      
      private function testSocialTriggers(param1:Point, param2:int) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         for each(_loc4_ in _socialTriggersVolumes)
         {
            if(pointInVolume(param1,_loc4_.v) && (!_loc4_.animIds || _loc4_.animIds.indexOf(param2) >= 0))
            {
               for each(_loc3_ in _loc4_.interactiveObjs)
               {
                  if(_loc3_ is RoomObject_SocialTrigger)
                  {
                     _loc3_.incCount();
                  }
               }
            }
         }
      }
      
      private function updateSocialTriggersStage() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         for each(_loc2_ in _socialTriggersVolumes)
         {
            for each(_loc1_ in _loc2_.interactiveObjs)
            {
               if(_loc1_ is RoomObject_SocialTrigger)
               {
                  _loc1_.update();
               }
            }
         }
      }
      
      private function isMouseVolume(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 1 || param1 == 4 || param1 == 7 || param1 == 8 || param1 == 9 || param1 == 10 || param1 == 12 || param1 == 13 || param1 == 24;
      }
      
      private function isSocialTriggerVolume(param1:int) : Boolean
      {
         return param1 == 5;
      }
      
      private function isAvatarVolume(param1:int) : Boolean
      {
         return param1 == 6 || param1 == 11;
      }
      
      private function isSplashVolume(param1:int) : Boolean
      {
         return param1 == 3;
      }
      
      private function isLadderVolume(param1:int) : Boolean
      {
         return param1 == 11;
      }
      
      private function isPlantVolume(param1:int) : Boolean
      {
         return param1 == 18;
      }
      
      private function isStealthVolume(param1:int) : Boolean
      {
         return param1 == 19;
      }
      
      private function newVolume(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Point = null;
         var _loc4_:Object = null;
         var _loc5_:Object = {
            "enabled":true,
            "name":param1.name,
            "v":param1.points.slice(),
            "status":0,
            "interactiveObjs":null,
            "message":param1.message,
            "type":param1.type,
            "typeDefId":param1.typeDefId,
            "bWalkTo":param1.walkTo
         };
         _loc3_ = 0;
         while(_loc3_ < _loc5_.v.length)
         {
            _loc2_ = new Point(_loc5_.v[_loc3_].x,_loc5_.v[_loc3_].y);
            convertToWorldSpace(_loc2_);
            _loc5_.v[_loc3_] = _loc2_;
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _layers.length)
         {
            _loc4_ = _layers[_loc3_];
            if(_loc4_.name == param1.name)
            {
               if(!_loc5_.interactiveObjs)
               {
                  _loc5_.interactiveObjs = [];
               }
               _loc5_.interactiveObjs.push(getRoomObject(_loc4_,param1.message));
            }
            _loc3_++;
         }
         _volumeActors.push(_loc5_);
         if(isSplashVolume(_loc5_.type))
         {
            _splashVolumes.push(_loc5_);
         }
         if(_loc5_.name == "ladder")
         {
            _ladderVolumes.push(_loc5_);
         }
         if(isSocialTriggerVolume(_loc5_.type))
         {
            _loc5_.animIds = null;
            if(_loc5_.message.length)
            {
               _loc5_.animIds = _loc5_.message.split(",");
               _loc3_ = 0;
               while(_loc3_ < _loc5_.animIds.length)
               {
                  _loc5_.animIds[_loc3_] = int(_loc5_.animIds[_loc3_]);
                  _loc3_++;
               }
            }
            _socialTriggersVolumes.push(_loc5_);
         }
      }
      
      private function getRoomObject(param1:Object, param2:String) : Object
      {
         var _loc4_:MovieClip = null;
         var _loc3_:Class = null;
         var _loc5_:RoomObject = _roomObjs[param1.name];
         if(!_loc5_)
         {
            _loc4_ = param1.s.content;
            var _loc6_:* = param2;
            if("gem" !== _loc6_)
            {
               if(_loc4_.stages != null)
               {
                  _loc3_ = RoomObject_SocialTrigger;
               }
               else if(_loc4_.currentLabels.length)
               {
                  if(_loc4_.currentLabels[0].name == "idle")
                  {
                     _loc3_ = RoomObject_IdleActive;
                  }
                  else if(_loc4_.currentLabels[0].name == "random")
                  {
                     _loc3_ = RoomObject_RandomClick;
                  }
               }
               if(!_loc3_)
               {
                  _loc3_ = RoomObject_ForwardReverseHold;
               }
            }
            else
            {
               _loc3_ = RoomObject_GemPickup;
            }
            _loc5_ = new _loc3_(_loc4_);
            _roomObjs[param1.name] = _loc5_;
         }
         return _loc5_;
      }
      
      private function pointInVolume(param1:Point, param2:Array) : Boolean
      {
         var _loc3_:int = 0;
         var _loc6_:Number = NaN;
         var _loc4_:Number = 0;
         var _loc5_:Number = param2.length - 1;
         _loc3_ = 0;
         while(_loc3_ < _loc5_)
         {
            if(param2[_loc3_].y <= param1.y && param2[_loc3_ + 1].y > param1.y || param2[_loc3_].y > param1.y && param2[_loc3_ + 1].y <= param1.y)
            {
               _loc6_ = (param1.y - param2[_loc3_].y) / (param2[_loc3_ + 1].y - param2[_loc3_].y);
               if(param1.x < param2[_loc3_].x + _loc6_ * (param2[_loc3_ + 1].x - param2[_loc3_].x))
               {
                  _loc4_++;
               }
            }
            _loc3_++;
         }
         return !!(_loc4_ % 2) ? true : false;
      }
      
      private function convertToWorldSpace(param1:Point) : void
      {
         param1.x -= _offset.x;
         param1.y -= _offset.y;
      }
      
      public function findVolume(param1:String) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(_volumeActors != null)
         {
            while(_loc3_ < _volumeActors.length)
            {
               if(_volumeActors[_loc3_].name == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push(_volumeActors[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function findVolumesByType(param1:int) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(_volumeActors != null)
         {
            while(_loc3_ < _volumeActors.length)
            {
               if(_volumeActors[_loc3_].type == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push(_volumeActors[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
   }
}

