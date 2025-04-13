package game.fashionShow
{
   import avatar.AccessoryState;
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import collection.AccItemCollection;
   import com.sbi.graphics.LayerAnim;
   import item.Item;
   
   public class FashionShowAvatarEditorView extends AvatarView
   {
      public function FashionShowAvatarEditorView()
      {
         super();
      }
      
      override public function init(param1:Avatar, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:Boolean = false) : void
      {
         _avatar = param1;
         _avatar.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = _avatar.avTypeId;
         _layerAnim.layers = AvatarUtility.layerArrayForItemsAndColors(param1.inventoryClothing.itemCollection,param1.colors,param1.avInvId,param1.roomType);
         this.addChild(_layerAnim.bitmap);
      }
      
      override public function destroy(param1:Boolean = false) : void
      {
         this.removeChild(_layerAnim.bitmap);
         _avatar.removeEventListener("OnAvatarChanged",avatarChanged);
         LayerAnim.destroy(_layerAnim);
         _layerAnim = null;
      }
      
      public function get colors() : Array
      {
         return _avatar.colors;
      }
      
      public function set colors(param1:Array) : void
      {
         _avatar.colors = param1;
      }
      
      public function get accState() : AccessoryState
      {
         return _avatar.accState;
      }
      
      public function get clothingItemArray() : AccItemCollection
      {
         return _avatar.inventoryClothing.itemCollection;
      }
      
      public function showAccessory(param1:Item, param2:Function = null) : void
      {
         _avatar.accStateShowAccessory(param1,param2);
      }
      
      public function hideAccessory(param1:Item) : void
      {
         _avatar.accStateHideAccessory(param1);
      }
   }
}

