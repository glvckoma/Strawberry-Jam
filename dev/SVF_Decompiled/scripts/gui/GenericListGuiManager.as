package gui
{
   import collection.StreamDefCollection;
   import movie.MovieManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import shop.ShopManager;
   
   public class GenericListGuiManager
   {
      public static var movieSelector:MovieManager;
      
      public function GenericListGuiManager()
      {
         super();
      }
      
      public static function genericListVolumeClicked(param1:int, param2:Object = null) : void
      {
         var _loc3_:int = int(gMainFrame.userInfo.getGenericListDefByDefId(param1).typeId);
         switch(_loc3_)
         {
            case 1000:
            case 1030:
            case 1051:
            case 1054:
            case 1060:
               if(!RoomManagerWorld.instance.inPreviewMode && (param2 == null || !param2.hasOwnProperty("volName") || QuestManager.onShopClick(param2.volName)))
               {
                  ShopManager.launchStore(param1,_loc3_);
               }
               break;
            case 1040:
               GuiManager.openDenRoomSwitcher(false,null,true,-1,param1);
               break;
            case 1037:
               DarkenManager.showLoadingSpiral(true);
               GenericListXtCommManager.requestStreamList(param1,launchMovies,param2);
               break;
            case 1023:
            case 1033:
            case 1035:
         }
      }
      
      public static function launchMovies(param1:int, param2:StreamDefCollection, param3:Object = null) : void
      {
         var _loc5_:Array = null;
         var _loc4_:Boolean = false;
         if(param2.length > 1)
         {
            GenericListXtCommManager.filterTypedItems(param2);
            if(movieSelector && RoomManagerWorld.instance.theaterWindow)
            {
               DarkenManager.showLoadingSpiral(false);
               movieSelector.toggleVisibility();
            }
            else
            {
               if(movieSelector)
               {
                  movieSelector.destroy();
                  movieSelector = null;
               }
               movieSelector = new MovieManager();
               movieSelector.init(GuiManager.guiLayer,RoomManagerWorld.instance.theaterWindow,param2,202,39,onMovieSelectorClose);
               if(param3)
               {
                  movieSelector.setSkinFrame(frameIdForMsg(param3.msg));
                  movieSelector.setVideoFrameId(videoPlayerFrameIdForMsg(param3.msg));
                  if(param3.msg == "bb" || param3.msg == "tt" || param3.msg == "cami" || param3.msg == "gw")
                  {
                     movieSelector.setQuestionBtn();
                  }
                  if(param3.titleTxt)
                  {
                     movieSelector.setTitleTxt(param3.titleTxt);
                  }
                  if(param3.msg.indexOf("autoplay") != -1)
                  {
                     movieSelector.chooseRandom(true,videoPlayerFrameIdForMsg(param3.msg),param3.shouldRepeat != null ? param3.shouldRepeat : false);
                  }
                  if(param3.shouldRepeat != null)
                  {
                     movieSelector.setShouldRepeat(param3.shouldRepeat);
                  }
                  if(param3.width && param3.height)
                  {
                     movieSelector.setDefaultWidthHeight(param3.width,param3.height);
                  }
               }
            }
         }
         else if(param3)
         {
            if(param3.msg)
            {
               _loc5_ = param3.msg.split("%");
               if(_loc5_.length > 1)
               {
                  param3.shouldRepeat = _loc5_[1] == "true";
                  param3.width = int(_loc5_[2]);
                  param3.height = int(_loc5_[3]);
               }
            }
            _loc4_ = true;
            if(param3.shouldRepeat != null)
            {
               _loc4_ = Boolean(param3.shouldRepeat);
            }
            if(param3.width && param3.height)
            {
               GuiManager.initMoviePlayer(39,param2,_loc4_,param3.width,param3.height);
            }
            else
            {
               GuiManager.initMoviePlayer(39,param2,_loc4_);
            }
            if(_loc5_)
            {
               GuiManager.setVideoPlayerSkin(videoPlayerFrameIdForMsg(_loc5_[0]));
            }
         }
         else
         {
            GuiManager.initMoviePlayer(39,param2,false);
         }
      }
      
      public static function onRoomExit() : void
      {
         if(movieSelector)
         {
            movieSelector.destroy();
            movieSelector = null;
         }
      }
      
      public static function togglePlayPauseVideoPlayer(param1:Boolean) : void
      {
         if(movieSelector)
         {
            movieSelector.togglePlayPauseVideoPlayer(param1);
         }
      }
      
      private static function frameIdForMsg(param1:String) : int
      {
         if(param1)
         {
            param1 = param1.toLowerCase();
         }
         else
         {
            param1 = "";
         }
         if(param1 == "bb" || param1 == "bb_experiments")
         {
            return 2;
         }
         if(param1 == "tt" || param1 == "tt_autoplay")
         {
            return 3;
         }
         if(param1 == "cami")
         {
            return 4;
         }
         if(param1 == "gw")
         {
            return 5;
         }
         return 1;
      }
      
      private static function videoPlayerFrameIdForMsg(param1:String) : int
      {
         if(param1)
         {
            param1 = param1.toLowerCase();
         }
         else
         {
            param1 = "";
         }
         if(param1 == "bb" || param1 == "bb_experiments")
         {
            return 2;
         }
         if(param1 == "tt" || param1 == "tt_autoplay")
         {
            return 3;
         }
         if(param1 == "biggerframe")
         {
            return 6;
         }
         if(param1 == "cami")
         {
            return 4;
         }
         if(param1 == "gw")
         {
            return 5;
         }
         return 1;
      }
      
      private static function onMovieSelectorClose() : void
      {
         if(movieSelector)
         {
            movieSelector.toggleVisibility();
         }
      }
      
      public function init() : void
      {
      }
   }
}

