package gui.itemWindows
{
   import avatar.AvatarManager;
   import avatar.NameBar;
   import localization.LocalizationManager;
   
   public class ItemWindowNameBar extends ItemWindowBase
   {
      private var _isMember:Boolean;
      
      private var _nameBarData:Object;
      
      private var _userName:String;
      
      private var _avName:String;
      
      private var _isBuddy:Boolean;
      
      private var _isBlocked:Boolean;
      
      private var _specificWidth:Number;
      
      private var _moderatedUserName:String;
      
      public function ItemWindowNameBar(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _isMember = param2.isMember;
         _nameBarData = param2.nameBarData;
         _userName = param2.userName;
         _avName = param2.avName;
         _isBuddy = param2.isBuddy;
         _isBlocked = param2.isBlocked;
         _specificWidth = !!param9 ? param9.specificWidth : -1;
         _moderatedUserName = param2.moderatedUserName;
         super(_isMember ? "memberNameBar" : "FreeNameBar",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function updateToBeCentered(param1:int) : void
      {
         _window.x += (param1 - _window.width) * 0.5;
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_isMember)
         {
            _window.setNubType(_isBuddy ? NameBar.BUDDY : NameBar.NON_BUDDY);
            _window.setColorAndBadge(_nameBarData);
         }
         else
         {
            _window.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
         }
         _window.isBlocked = _isBlocked;
         (_window as NameBar).setAvName(LocalizationManager.translateAvatarName(_moderatedUserName),true,null,true,_specificWidth);
         _window.x += (_window as NameBar)["sizeCont"].width * 0.25;
         _window.y += (_window as NameBar)["sizeCont"].height * 0.25;
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null)
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
         }
      }
   }
}

