package avatar
{
   import collection.AccItemCollection;
   import collection.IntItemCollection;
   import com.sbi.graphics.LayerAnim;
   import item.Item;
   
   public class AvatarEditorView extends AvatarView
   {
      public function AvatarEditorView()
      {
         super();
      }
      
      override public function init(param1:Avatar, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:Boolean = false) : void
      {
         _avatar = new Avatar();
         _avatar.init(param1.perUserAvId,param1.avInvId,"editorAvatar",param1.avTypeId,param1.colors,param1.customAvId,null,"",-1,param1.roomType,param1.rangedAttack,param1.meleeAttack,param1.fierceAttack,param1.healingPower,param1.defense);
         avTypeChangedCallback = param2;
         onAvatarChangedCallback = param3;
         _skipAnimEnviroCheck = param5;
         if(param1.inventoryClothing.itemCollection)
         {
            _avatar.inventoryClothing.itemCollection = new AccItemCollection(param1.inventoryClothing.itemCollection.concatCollection(null));
         }
         if(param1.inventoryBodyMod.itemCollection)
         {
            _avatar.inventoryBodyMod.itemCollection = new AccItemCollection(param1.inventoryBodyMod.itemCollection.concatCollection(null));
         }
         _avatar.matchShownAcc(param1.accState);
         _avatar.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         _layerAnim = LayerAnim.getNew(param4);
         _layerAnim.avDefId = _avatar.avTypeId;
         _layerAnim.layers = AvatarUtility.layerArrayForItemsAndColors(new AccItemCollection(param1.inventoryClothing.itemCollection.concatCollection(param1.inventoryBodyMod.itemCollection)),param1.colors,param1.avInvId,param1.roomType);
         this.addChild(_layerAnim.bitmap);
      }
      
      override public function destroy(param1:Boolean = true) : void
      {
         if(param1 && _avatar)
         {
            _avatar.removeEventListener("OnAvatarChanged",avatarChanged);
            _avatar.destroy();
            _avatar = null;
         }
         avTypeChangedCallback = null;
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
      
      public function get numClothingItemsShown() : int
      {
         return _avatar.numClothingItemsShown;
      }
      
      public function showAccessory(param1:Item, param2:Function = null) : void
      {
         _avatar.accStateShowAccessory(param1,param2);
      }
      
      public function hideAccessory(param1:Item) : void
      {
         _avatar.accStateHideAccessory(param1);
      }
      
      public function hideAllClothingItems(param1:IntItemCollection) : void
      {
         _avatar.accStateHideAllClothingItems(param1);
      }
      
      public function replaceAccItem(param1:Item, param2:Item) : void
      {
         _avatar.replaceAccItem(param1,param2);
      }
      
      public function get viewAvatar() : Avatar
      {
         return _avatar;
      }
   }
}

