package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import gui.itemWindows.ItemWindowBook;
   import loader.MediaHelper;
   
   public class EBookChooser
   {
      public static const LAND_TYPE:String = "land";
      
      public static const OCEAN_TYPE:String = "ocean";
      
      public static const AIR_TYPE:String = "air";
      
      public static const COMBINED_TYPE:String = "combined";
      
      private static const LAND_LIST_ID:int = 353;
      
      private static const OCEAN_LIST_ID:int = 354;
      
      private static const AIR_LIST_ID:int = 355;
      
      private static const COMBINED_LIST_ID:int = 356;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      private var _currLoaderAppDomain:ApplicationDomain;
      
      private var _type:String;
      
      private var _currEBooks:Array;
      
      public function EBookChooser()
      {
         super();
      }
      
      public function init(param1:String, param2:Function) : void
      {
         _type = param1;
         _closeCallback = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(3836,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         _closeCallback = null;
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_popup)
         {
            DarkenManager.unDarken(_popup);
            if(_popup.parent && GuiManager.guiLayer == _popup.parent)
            {
               GuiManager.guiLayer.removeChild(_popup);
            }
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _currLoaderAppDomain = param1.loaderInfo.applicationDomain;
            _popup = MovieClip(param1.getChildAt(0));
            _popup.logo.gotoAndStop(_type);
            _popup.x = 900 * 0.5;
            _popup.y = 550 * 0.5;
            GuiManager.guiLayer.addChild(_popup);
            DarkenManager.darken(_popup);
            addEventListeners();
            loadBooks();
         }
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.xBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private function loadBooks() : void
      {
         setupBooksObject();
      }
      
      private function setupBooksObject() : void
      {
         var _loc1_:int = 0;
         switch(_type)
         {
            case "land":
               _loc1_ = 353;
               break;
            case "ocean":
               _loc1_ = 354;
               break;
            case "air":
               _loc1_ = 355;
               break;
            case "combined":
               _loc1_ = 356;
         }
         if(_loc1_ != 0)
         {
            GenericListXtCommManager.requestGenericList(_loc1_,onBookListLoaded);
         }
      }
      
      private function onBookListLoaded(param1:int, param2:Array, param3:Array, param4:Array, param5:Object) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         _currEBooks = [];
         _loc7_ = 0;
         while(_loc7_ < param2.length)
         {
            _currEBooks.push({
               "ebookId":param2[_loc7_],
               "mediaId":param3[_loc7_],
               "listId":param4[_loc7_]
            });
            _loc7_++;
         }
         if(_currEBooks.length > 0)
         {
            _loc8_ = 5;
            _loc6_ = 2;
            _itemWindows = new WindowAndScrollbarGenerator();
            if(_currEBooks.length > 10)
            {
               _popup.gotoAndStop("scroll");
            }
            else
            {
               _popup.gotoAndStop("noScroll");
            }
            _itemWindows.init(_popup.itemWindow.width,_popup.itemWindow.height,-2,0,_loc8_,_loc6_,0,12,16,2,2,ItemWindowBook,_currEBooks,"",0,null,{"currLoaderAppDomain":_currLoaderAppDomain},null,true,false,false,false,true);
            _popup.itemWindow.addChild(_itemWindows);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
      }
   }
}

