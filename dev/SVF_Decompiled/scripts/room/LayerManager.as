package room
{
   import com.sbi.graphics.SortLayer;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   
   public class LayerManager
   {
      private var _layer_bkg:DisplayLayer;
      
      private var _layer_room_bkg:DisplayLayer;
      
      private var _layer_room_bkg_group:DisplayLayer;
      
      private var _layer_room_bkg_main:DisplayLayer;
      
      private var _layer_room_avatars:SortLayer;
      
      private var _layer_room_preview_avatar:SortLayer;
      
      private var _layer_room_preview_flying_avatar:SortLayer;
      
      private var _layer_room_fg:DisplayLayer;
      
      private var _layer_flying_avatars:SortLayer;
      
      private var _layer_room_super_fg:DisplayLayer;
      
      private var _layer_room_chat:DisplayLayer;
      
      private var _layer_room_orbs:DisplayLayer;
      
      private var _layer_worldGame:DisplayLayer;
      
      private var _layer_gui:DisplayLayer;
      
      private var _layer_fps:DisplayLayer;
      
      private var _layer_debug:DisplayLayer;
      
      private var _debugShape:Shape;
      
      public function LayerManager(param1:DisplayObjectContainer, param2:DisplayLayer)
      {
         super();
         _layer_bkg = new DisplayLayer();
         _layer_room_bkg = new DisplayLayer();
         _layer_room_bkg_group = new DisplayLayer();
         _layer_room_bkg_main = new DisplayLayer();
         _layer_room_avatars = new SortLayer();
         _layer_room_preview_avatar = new SortLayer();
         _layer_room_preview_flying_avatar = new SortLayer();
         _layer_room_fg = new DisplayLayer();
         _layer_room_super_fg = new DisplayLayer();
         _layer_flying_avatars = new SortLayer();
         _layer_room_chat = new DisplayLayer();
         _layer_room_orbs = new DisplayLayer();
         _layer_room_orbs.mouseEnabled = false;
         _layer_worldGame = new DisplayLayer();
         _layer_gui = new DisplayLayer();
         _layer_fps = new DisplayLayer();
         param1.addChildAt(_layer_bkg,param1.getChildIndex(param2));
         _layer_bkg.addChild(_layer_room_bkg);
         _layer_bkg.addChild(_layer_room_bkg_group);
         _layer_room_bkg_group.addChild(_layer_room_bkg_main);
         _layer_room_bkg_group.addChild(_layer_room_avatars);
         _layer_room_bkg_group.addChild(_layer_room_preview_avatar);
         _layer_bkg.addChild(_layer_room_fg);
         _layer_bkg.addChild(_layer_flying_avatars);
         _layer_bkg.addChild(_layer_room_preview_flying_avatar);
         _layer_bkg.addChild(_layer_room_super_fg);
         _layer_bkg.addChild(_layer_room_chat);
         _layer_bkg.addChild(_layer_room_orbs);
         _layer_room_fg.mouseChildren = false;
         _layer_room_fg.mouseEnabled = false;
         _layer_room_super_fg.mouseChildren = false;
         _layer_room_super_fg.mouseEnabled = false;
         param1.addChildAt(_layer_worldGame,param1.getChildIndex(param2));
         param1.addChildAt(_layer_gui,param1.getChildIndex(param2));
         _layer_debug = new DisplayLayer();
         _layer_fps.addChild(_layer_debug);
         param1.stage.addChild(_layer_fps);
         _debugShape = new Shape();
      }
      
      public function showAvatarsAndRelatedItems(param1:Boolean) : void
      {
         _layer_flying_avatars.visible = param1;
         _layer_room_chat.visible = param1;
         _layer_room_orbs.visible = param1;
         _layer_room_avatars.visible = param1;
         _layer_room_bkg_main.visible = param1;
         _layer_room_preview_avatar.visible = !param1;
         _layer_room_preview_flying_avatar.visible = !param1;
      }
      
      public function get gui() : DisplayLayer
      {
         return _layer_gui;
      }
      
      public function get bkg() : DisplayLayer
      {
         return _layer_bkg;
      }
      
      public function get fps() : DisplayLayer
      {
         return _layer_fps;
      }
      
      public function get room_bkg_group() : DisplayLayer
      {
         return _layer_room_bkg_group;
      }
      
      public function get room_bkg_main() : DisplayLayer
      {
         return _layer_room_bkg_main;
      }
      
      public function get room_bkg() : DisplayLayer
      {
         return _layer_room_bkg;
      }
      
      public function get room_fg() : DisplayLayer
      {
         return _layer_room_fg;
      }
      
      public function get room_super_fg() : DisplayLayer
      {
         return _layer_room_super_fg;
      }
      
      public function get room_avatars() : SortLayer
      {
         return _layer_room_avatars;
      }
      
      public function get room_chat() : DisplayLayer
      {
         return _layer_room_chat;
      }
      
      public function get flying_avatars() : SortLayer
      {
         return _layer_flying_avatars;
      }
      
      public function get room_orbs() : DisplayLayer
      {
         return _layer_room_orbs;
      }
      
      public function get layer_debug() : DisplayLayer
      {
         return _layer_debug;
      }
      
      public function get layer_worldGame() : DisplayLayer
      {
         return _layer_worldGame;
      }
      
      public function get preview_room_avatar() : SortLayer
      {
         return _layer_room_preview_avatar;
      }
      
      public function get preview_room_flying_avatar() : SortLayer
      {
         return _layer_room_preview_flying_avatar;
      }
      
      public function get debugShape() : Shape
      {
         return _debugShape;
      }
   }
}

