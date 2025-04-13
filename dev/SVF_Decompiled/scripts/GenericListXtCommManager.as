package
{
   import Enums.StreamDef;
   import WorldItems.WorldItemsManager;
   import collection.BaseTypedCollection;
   import collection.IitemCollection;
   import collection.StreamDefCollection;
   import collection.WorldItemCollection;
   import com.sbi.client.SFEvent;
   import inventory.Iitem;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   
   public class GenericListXtCommManager
   {
      public static const AVAIL_TYPE_CLOTHING:int = 0;
      
      public static const AVAIL_TYPE_DEN_ACC:int = 1;
      
      public static const AVAIL_TYPE_PARTY:int = 2;
      
      public static const AVAIL_TYPE_DEN_ROOM:int = 3;
      
      public static const AVAIL_TYPE_ROOM:int = 4;
      
      public static const AVAIL_TYPE_STREAM:int = 5;
      
      public static const AVAIL_TYPE_DIAMOND:int = 6;
      
      public static const AVAIL_TYPE_AVATAR:int = 7;
      
      public static const AVAIL_TYPE_PET:int = 8;
      
      public static const AVAIL_TYPE_WORLD_ITEMS:int = 9;
      
      public static const AVAIL_TYPE_NEWSPAPER:int = 10;
      
      public static const ACC_JAMAA_SHOP_ID:int = 11;
      
      public static const ACC_BAHARIBAY_SHOP_ID:int = 50;
      
      public static const ACC_CHARM_SHOP_ID:int = 669;
      
      public static const DEN_ITEM_MAIN_SHOP_ID:int = 12;
      
      public static const DEN_ITEM_CRYSTALREEF_SHOP_ID:int = 51;
      
      public static const DEN_ITEM_AUDIO_SHOP_ID:int = 56;
      
      public static const DEN_ITEM_PET_LAND:int = 85;
      
      public static const DEN_ITEM_PET_OCEAN:int = 89;
      
      public static const DEN_ITEM_FIRST_TIME_SHOP_ID:int = 234;
      
      public static const REDEMPTION_STORE_LIST_ID:int = 172;
      
      public static const DEN_ROOM_SHOP_ID:int = 13;
      
      public static const DEN_ROOM_FULL_SHOP_ID:int = 384;
      
      public static const MEDIA_EBOOK_1_ID:int = 23;
      
      public static const AVATAR_LIST_ID:int = 64;
      
      public static const CURR_SHOP_DIAMOND_AVATAR_LIST:int = 166;
      
      public static const DIAMOND_AVATAR_LIST_ID:int = 293;
      
      public static const MEDIA_JAG_CARD_LIST_ID:int = 10;
      
      public static const MEDIA_JAG_STAMP_LIST_ID:int = 44;
      
      public static const DIAMOND_PET_LIST:int = 214;
      
      public static const AVAILABLE_PET_LIST:int = 312;
      
      public static const PERSONALITY_PET_LIST:int = 432;
      
      public static const EGG_PET_LIST:int = 624;
      
      public static const MASTERPIECE_ICON_LIST_ID:int = 416;
      
      public static const MASTERPIECE_ICON_IN_DEN_ITEM_VERSION_ORDER:int = 424;
      
      public static const PLATFORMER_LIST:int = 566;
      
      private static var _requestCallbackQueue:Object;
      
      private static var _requestPassbackQueue:Object;
      
      private static var _streamQueue:Object;
      
      private static var _cachedResponses:Object;
      
      public function GenericListXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _cachedResponses = {};
         _requestCallbackQueue = {};
         _requestPassbackQueue = {};
         _streamQueue = {};
         XtReplyDemuxer.addModule(GenericListXtCommManager.handleXtReply,"g");
      }
      
      public static function destroy() : void
      {
      }
      
      public static function requestGenericList(param1:int, param2:Function = null, param3:Object = null, param4:Boolean = true) : void
      {
         var _loc5_:Boolean = true;
         if(_requestCallbackQueue[param1])
         {
            _requestCallbackQueue[param1].push(param2);
            _loc5_ = false;
         }
         else
         {
            _requestCallbackQueue[param1] = [param2];
         }
         if(_requestPassbackQueue[param1])
         {
            _requestPassbackQueue[param1].push(param3);
         }
         else
         {
            _requestPassbackQueue[param1] = [param3];
         }
         if(_cachedResponses[param1])
         {
            handleNewData(_cachedResponses[param1].concat());
         }
         else if(_loc5_)
         {
            gMainFrame.server.setXtObject_Str("gl",[param1],param4);
         }
      }
      
      public static function requestStreamList(param1:int, param2:Function, param3:Object = null) : void
      {
         _streamQueue[param1] = {
            "c":param2,
            "h":param3
         };
         if(_cachedResponses[param1])
         {
            handleNewData(_cachedResponses[param1].concat());
         }
         else
         {
            gMainFrame.server.setXtObject_Str("gl",[param1]);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         if(_loc2_[0] == "gl")
         {
            _cachedResponses[int(_loc2_[2])] = _loc2_;
         }
         handleNewData(_loc2_.concat());
      }
      
      public static function filterIitems(param1:IitemCollection, param2:Boolean = false, ... rest) : void
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc5_:Array = null;
         var _loc8_:int = 0;
         if(param1.length == 0 || !param1.getCoreArray()[0].hasOwnProperty("isAvailable"))
         {
            return;
         }
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            if(!param1.getIitem(_loc7_).isAvailable)
            {
               _loc6_ = param1.getCoreArray().splice(_loc7_,1);
               if(rest)
               {
                  _loc8_ = 0;
                  while(_loc8_ < rest.length)
                  {
                     _loc5_ = rest[_loc8_];
                     if(_loc5_)
                     {
                        if(param2)
                        {
                           _loc5_[(_loc6_[0] as Iitem).defId] = undefined;
                        }
                        else
                        {
                           _loc5_.splice(_loc7_,1);
                        }
                     }
                     _loc8_++;
                  }
               }
               _loc7_--;
            }
            else if(param1.getIitem(_loc7_).startTime + 10 * 86400 >= Utility.getCurrEpochTime())
            {
               param1.getIitem(_loc7_).updateValueWithNewStatus(1);
            }
            _loc7_++;
         }
      }
      
      public static function filterTypedItems(param1:BaseTypedCollection) : void
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         if(param1.length == 0 || !param1.getCoreArray()[0].hasOwnProperty("isAvailable"))
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.getCoreArray()[_loc3_];
            if(!_loc4_.isAvailable)
            {
               param1.getCoreArray().splice(_loc3_,1);
               _loc3_--;
            }
            else if(_loc4_.hasOwnProperty("availabilityStartTime") && Boolean(_loc4_.hasOwnProperty("updateValueWithNewStatus")))
            {
               if(_loc4_.availabilityStartTime + 10 * 86400 >= Utility.getCurrEpochTime())
               {
                  _loc4_.updateValueWithNewStatus(1);
               }
            }
            _loc3_++;
         }
      }
      
      private static function handleNewData(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] == "gl")
         {
            _loc2_ = int(param1[3]);
            switch(_loc2_)
            {
               case 1000:
               case 1030:
               case 1040:
               case 1051:
               case 1054:
               case 1060:
                  handleItemResponse(param1,_loc2_);
                  break;
               case 1023:
                  handleLocalizationResponse(param1);
                  break;
               case 1033:
               case 1062:
               case 1063:
                  handleMediaResponse(param1);
                  break;
               case 1035:
                  handleFactResponse(param1);
                  break;
               case 1037:
                  handleStreamResponse(param1);
                  break;
               case 1003:
                  handleAvatarResponse(param1);
                  break;
               case 1049:
                  handleNamebarBadgeResposne(param1);
                  break;
               case 1052:
                  handleScriptResponse(param1);
                  break;
               case 1046:
                  handlePetResponse(param1);
                  break;
               case 1058:
                  handleEBookResponse(param1);
                  break;
               case 1024:
               case 1047:
               case 1065:
                  handleSimpleResponse(param1);
                  break;
               case 1064:
                  handleInWorldItemsResponse(param1);
            }
            return;
         }
         throw new Error("GenericListXtCommManager illegal data cmd:" + param1[0]);
      }
      
      public static function genericListTypeResponse(param1:DefPacksDefHelper) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1038] = null;
         var _loc4_:Object = {};
         for each(var _loc3_ in _loc2_)
         {
            _loc5_ = {
               "defId":int(_loc3_.id),
               "typeId":int(_loc3_.typeId)
            };
            _loc4_[_loc3_.id] = _loc5_;
         }
         gMainFrame.userInfo.genericListDefs = _loc4_;
      }
      
      private static function handleItemResponse(param1:Array, param2:int) : void
      {
         var _loc6_:int = 0;
         var _loc5_:Object = null;
         var _loc7_:Function = null;
         var _loc3_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc3_])
         {
            _loc6_ = 0;
            while(_loc6_ < _requestCallbackQueue[_loc3_].length)
            {
               _loc5_ = !!_requestPassbackQueue[_loc3_] ? _requestPassbackQueue[_loc3_][_loc6_] : null;
               _loc7_ = _requestCallbackQueue[_loc3_][_loc6_];
               if(_loc7_ != null)
               {
                  if(_loc5_)
                  {
                     _loc7_(_loc3_,param1,_loc5_);
                  }
                  else
                  {
                     _loc7_(_loc3_,param1);
                  }
                  if(_loc5_ != null)
                  {
                     for each(var _loc4_ in _requestPassbackQueue)
                     {
                        if(_loc4_ == _loc5_)
                        {
                           delete _requestPassbackQueue[_loc3_];
                           break;
                        }
                     }
                  }
               }
               else
               {
                  ItemXtCommManager.shopListResponse(param1,param2);
               }
               _loc6_++;
            }
            delete _requestCallbackQueue[_loc3_];
            delete _requestPassbackQueue[_loc3_];
         }
         else
         {
            ItemXtCommManager.shopListResponse(param1,param2);
         }
      }
      
      private static function handleLocalizationResponse(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         var _loc6_:Function = null;
         var _loc7_:int = 8;
         var _loc8_:int = int(param1[_loc7_++]);
         var _loc3_:Array = new Array(_loc8_);
         _loc5_ = 0;
         while(_loc5_ < _loc8_)
         {
            _loc3_[_loc5_] = param1[_loc7_++];
            _loc5_++;
         }
         var _loc2_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc2_])
         {
            _loc5_ = 0;
            while(_loc5_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc4_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc5_] : null;
               _loc6_ = _requestCallbackQueue[_loc2_][_loc5_];
               if(_loc6_ != null)
               {
                  if(_loc4_)
                  {
                     _loc6_(_loc2_,_loc3_,_loc4_);
                  }
                  else
                  {
                     _loc6_(_loc2_,_loc3_);
                  }
               }
               _loc5_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleMediaResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc7_:Function = null;
         var _loc8_:int = 8;
         var _loc5_:int = int(param1[_loc8_++]);
         var _loc9_:Array = new Array(_loc5_);
         var _loc3_:Array = new Array(_loc5_);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc9_[_loc6_] = int(param1[_loc8_++]);
            _loc3_[_loc6_] = param1[_loc8_++];
            _loc6_++;
         }
         var _loc2_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc2_])
         {
            _loc6_ = 0;
            while(_loc6_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc4_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc6_] : null;
               _loc7_ = _requestCallbackQueue[_loc2_][_loc6_];
               if(_loc7_ != null)
               {
                  if(_loc7_.length == 3 || _loc4_ == null)
                  {
                     _loc7_(_loc2_,_loc9_,_loc3_);
                  }
                  else if(_loc7_.length == 4)
                  {
                     _loc7_(_loc2_,_loc9_,_loc3_,_loc4_);
                  }
               }
               _loc6_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleFactResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc7_:Function = null;
         var _loc8_:int = 8;
         var _loc3_:int = int(param1[_loc8_++]);
         var _loc9_:Array = [];
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            _loc4_ = {
               "id":int(param1[_loc8_++]),
               "media":int(param1[_loc8_++]),
               "title":int(param1[_loc8_++]),
               "description":int(param1[_loc8_++]),
               "type":int(param1[_loc8_++]),
               "userVarId":int(param1[_loc8_++]),
               "bitIdx":int(param1[_loc8_++])
            };
            _loc9_.push(_loc4_);
            _loc6_++;
         }
         var _loc2_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc2_])
         {
            _loc6_ = 0;
            while(_loc6_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc5_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc6_] : null;
               _loc7_ = _requestCallbackQueue[_loc2_][_loc6_];
               if(_loc7_ != null)
               {
                  _loc7_(_loc9_);
               }
               _loc6_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleStreamResponse(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 8;
         var _loc3_:String = param1[4];
         var _loc8_:int = int(param1[_loc5_++]);
         var _loc6_:StreamDefCollection = new StreamDefCollection();
         _loc4_ = 0;
         while(_loc4_ < _loc8_)
         {
            _loc6_.pushStreamDefItem(new StreamDef(int(param1[_loc5_++]),int(param1[_loc5_++]),param1[_loc5_++],int(param1[_loc5_++]),int(param1[_loc5_++])));
            _loc4_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc9_:Object = _streamQueue[_loc2_];
         if(_loc9_)
         {
            if(_loc9_.h)
            {
               _loc9_.h.titleTxt = _loc3_;
               _loc9_.c(_loc2_,_loc6_,_loc9_.h);
            }
            else
            {
               _loc9_.c(_loc2_,_loc6_);
            }
            for each(var _loc7_ in _streamQueue)
            {
               if(_loc7_ == _streamQueue[_loc2_])
               {
                  delete _streamQueue[_loc2_];
                  break;
               }
            }
         }
      }
      
      private static function handleAvatarResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc7_:Function = null;
         var _loc8_:int = 8;
         var _loc5_:int = int(param1[_loc8_++]);
         var _loc3_:Array = new Array(_loc5_);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_[_loc6_] = int(param1[_loc8_++]);
            _loc6_++;
         }
         var _loc2_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc2_])
         {
            _loc6_ = 0;
            while(_loc6_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc4_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc6_] : null;
               _loc7_ = _requestCallbackQueue[_loc2_][_loc6_];
               if(_loc7_ != null)
               {
                  _loc7_(_loc3_);
               }
               _loc6_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleNamebarBadgeResposne(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc7_:Function = null;
         var _loc8_:int = 8;
         var _loc5_:int = int(param1[_loc8_++]);
         var _loc2_:Array = new Array(_loc5_);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc2_[_loc6_] = int(param1[_loc8_++]);
            _loc6_++;
         }
         var _loc3_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc3_])
         {
            _loc6_ = 0;
            while(_loc6_ < _requestCallbackQueue[_loc3_].length)
            {
               _loc4_ = !!_requestPassbackQueue[_loc3_] ? _requestPassbackQueue[_loc3_][_loc6_] : null;
               _loc7_ = _requestCallbackQueue[_loc3_][_loc6_];
               if(_loc7_ != null)
               {
                  _loc7_(_loc2_);
               }
               _loc6_++;
            }
            delete _requestCallbackQueue[_loc3_];
            delete _requestPassbackQueue[_loc3_];
         }
      }
      
      private static function handleScriptResponse(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc3_:Object = null;
         var _loc6_:Function = null;
         var _loc7_:int = 8;
         var _loc8_:int = int(param1[_loc7_++]);
         var _loc4_:Array = new Array(_loc8_);
         _loc5_ = 0;
         while(_loc5_ < _loc8_)
         {
            _loc4_[_loc5_] = int(param1[_loc7_++]);
            _loc5_++;
         }
         var _loc2_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc2_])
         {
            _loc5_ = 0;
            while(_loc5_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc3_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc5_] : null;
               _loc6_ = _requestCallbackQueue[_loc2_][_loc5_];
               if(_loc6_ != null)
               {
                  _loc6_(_loc2_,_loc4_,_loc3_);
               }
               _loc5_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handlePetResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc5_:Function = null;
         var _loc6_:int = 8;
         var _loc9_:int = int(param1[_loc6_++]);
         var _loc7_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < _loc9_)
         {
            _loc8_ = int(param1[_loc6_++]);
            if(param1[_loc6_++] == "1")
            {
               _loc7_.push(_loc8_);
            }
            _loc4_++;
         }
         var _loc2_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc2_])
         {
            _loc4_ = 0;
            while(_loc4_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc3_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc4_] : null;
               _loc5_ = _requestCallbackQueue[_loc2_][_loc4_];
               if(_loc5_ != null)
               {
                  _loc5_(_loc2_,_loc7_,_loc3_);
               }
               _loc4_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleEBookResponse(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc5_:Object = null;
         var _loc8_:Function = null;
         var _loc2_:int = int(param1[2]);
         var _loc9_:int = 8;
         var _loc6_:int = int(param1[_loc9_++]);
         var _loc10_:Array = new Array(_loc6_);
         var _loc3_:Array = new Array(_loc6_);
         var _loc4_:Array = new Array(_loc6_);
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            _loc10_[_loc7_] = int(param1[_loc9_++]);
            _loc3_[_loc7_] = int(param1[_loc9_++]);
            _loc4_[_loc7_] = int(param1[_loc9_++]);
            _loc7_++;
         }
         if(_requestCallbackQueue[_loc2_])
         {
            _loc7_ = 0;
            while(_loc7_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc5_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc7_] : null;
               _loc8_ = _requestCallbackQueue[_loc2_][_loc7_];
               if(_loc8_ != null)
               {
                  _loc8_(_loc2_,_loc10_,_loc3_,_loc4_,_loc5_);
               }
               _loc7_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleSimpleResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc7_:Function = null;
         var _loc2_:int = int(param1[2]);
         var _loc8_:int = 8;
         var _loc5_:int = int(param1[_loc8_++]);
         var _loc3_:Array = new Array(_loc5_);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_[_loc6_] = int(param1[_loc8_++]);
            _loc6_++;
         }
         if(_requestCallbackQueue[_loc2_])
         {
            _loc6_ = 0;
            while(_loc6_ < _requestCallbackQueue[_loc2_].length)
            {
               _loc4_ = !!_requestPassbackQueue[_loc2_] ? _requestPassbackQueue[_loc2_][_loc6_] : null;
               _loc7_ = _requestCallbackQueue[_loc2_][_loc6_];
               if(_loc7_ != null)
               {
                  _loc7_(_loc2_,_loc3_,_loc4_);
               }
               _loc6_++;
            }
            delete _requestCallbackQueue[_loc2_];
            delete _requestPassbackQueue[_loc2_];
         }
      }
      
      private static function handleInWorldItemsResponse(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc2_:int = int(param1[2]);
         var _loc6_:int = 8;
         var _loc4_:int = int(param1[_loc6_++]);
         var _loc3_:WorldItemCollection = new WorldItemCollection();
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_.pushWorldDefItem(WorldItemsManager.getWorldItemDef(param1[_loc6_++]));
            _loc5_++;
         }
         filterTypedItems(_loc3_);
         WorldItemsManager.handleWorldItemsResponse(_loc3_);
      }
   }
}

