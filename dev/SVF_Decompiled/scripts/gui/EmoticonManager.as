package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class EmoticonManager
   {
      private const EMOTEWINDOW_DIM_ALPHA:Number = 0.5;
      
      private const EMOTEWINDOW_BRIGHT_ALPHA:Number = 1;
      
      private var emoteType:int;
      
      private var emoteBtn:MovieClip;
      
      private var emoteWindow:MovieClip;
      
      private var emoteBtnsBg:Sprite;
      
      private var actionBtn:MovieClip;
      
      private var actionWindow:Sprite;
      
      private var safeChatBtn:MovieClip;
      
      private var safeChatTree:MovieClip;
      
      private var setEmoteCallback:Function;
      
      private var _useMemberOnlyEmotes:Boolean;
      
      private var _emotes:MovieClip;
      
      public function EmoticonManager(param1:int, param2:Function, param3:MovieClip, param4:MovieClip, param5:MovieClip, param6:Sprite, param7:MovieClip, param8:MovieClip, param9:Boolean = true)
      {
         super();
         _useMemberOnlyEmotes = param9;
         emoteType = param1;
         setEmoteCallback = param2;
         emoteBtn = param3;
         emoteBtn.addEventListener("mouseDown",emoteBtnDownHandler,false,0,true);
         emoteWindow = param4;
         addAllEmotes();
         emoteWindow.visible = false;
         actionBtn = param5;
         actionWindow = param6;
         safeChatBtn = param7;
         safeChatTree = param8;
         emoteBtnsBg = GETDEFINITIONBYNAME("emo_mouse");
         emoteWindow.addChild(emoteBtnsBg);
         emoteBtnsBg.visible = false;
         if(param4.titleTxt)
         {
            LocalizationManager.translateId(param4.titleTxt,6308);
         }
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:Sprite, param5:MovieClip, param6:MovieClip, param7:Function, param8:Boolean) : void
      {
         _useMemberOnlyEmotes = param8;
         if(emoteBtn)
         {
            emoteBtn.removeEventListener("mouseDown",emoteBtnDownHandler);
         }
         emoteBtn = param1;
         emoteBtn.addEventListener("mouseDown",emoteBtnDownHandler,false,0,true);
         emoteWindow = param2;
         emoteWindow.addChild(_emotes);
         emoteWindow.addChild(emoteBtnsBg);
         emoteWindow.visible = false;
         actionBtn = param3;
         actionWindow = param4;
         safeChatBtn = param5;
         safeChatTree = param6;
         emoteBtnsBg.visible = false;
         LocalizationManager.translateId(param2.titleTxt,6308);
         emoteBtn.downToUpState();
         addAllEmotes();
         setEmoteCallback = param7;
      }
      
      public function resetEmotePrivs() : void
      {
         if(gMainFrame.userInfo.isMember)
         {
            emoteWindow.locked.visible = false;
         }
         else
         {
            emoteWindow.locked.visible = true;
         }
      }
      
      private function addAllEmotes() : void
      {
         if(_emotes && _emotes.parent == emoteWindow)
         {
            emoteWindow.removeChild(_emotes);
         }
         _emotes = EmoticonUtility.setupEmotes(emoteType,emoteWindow,_useMemberOnlyEmotes,smileyClickHandler,smileyRollOverHandler,smileyRollOutHandler);
         emoteWindow.addChild(_emotes);
         if(emoteWindow.hasOwnProperty("locked"))
         {
            if(_useMemberOnlyEmotes)
            {
               emoteWindow.setChildIndex(emoteWindow.locked,emoteWindow.numChildren - 1);
               emoteWindow.locked.mouseChildren = false;
               emoteWindow.locked.mouseEnabled = false;
               emoteWindow.titleTxt.visible = true;
               if(emoteWindow.memEmoteTop)
               {
                  emoteWindow.memEmoteTop.visible = true;
               }
               if(gMainFrame.userInfo.isMember)
               {
                  emoteWindow.locked.visible = false;
               }
               else
               {
                  emoteWindow.locked.visible = true;
               }
            }
            else
            {
               emoteWindow.titleTxt.visible = false;
               if(emoteWindow.memEmoteTop)
               {
                  emoteWindow.memEmoteTop.visible = false;
               }
               emoteWindow.locked.visible = false;
            }
         }
      }
      
      public function destroy() : void
      {
         setEmoteCallback = null;
         emoteBtn.removeEventListener("mouseDown",emoteBtnDownHandler);
         emoteBtn = null;
         emoteWindow.visible = false;
         emoteWindow = null;
         actionBtn = null;
         actionWindow = null;
         safeChatBtn = null;
         safeChatTree = null;
      }
      
      public function openEmotes() : void
      {
         if(!emoteWindow.visible)
         {
            emoteWindow.visible = true;
            emoteWindow.gotoAndPlay(1);
            brightenEmotes();
         }
      }
      
      public function dimEmotes() : void
      {
         if(emoteWindow.visible && emoteWindow.alpha != 0.5)
         {
            emoteWindow.alpha = 0.5;
         }
      }
      
      public function brightenEmotes() : void
      {
         if(emoteWindow.alpha != 1)
         {
            emoteWindow.alpha = 1;
         }
      }
      
      public function closeEmotes(param1:Boolean = false) : void
      {
         if(emoteWindow.visible)
         {
            if(GuiManager.isInFFM && !param1)
            {
               emoteWindow.parent.setChildIndex(emoteWindow,emoteWindow.parent.numChildren - 1);
            }
            else
            {
               emoteWindow.visible = false;
               brightenEmotes();
               emoteBtn.downToUpState();
            }
         }
      }
      
      private function emoteBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(emoteWindow.visible)
            {
               closeEmotes(true);
            }
            else
            {
               if(safeChatTree && safeChatTree.visible)
               {
                  safeChatBtn.dispatchEvent(param1);
               }
               if(actionWindow && actionWindow.visible)
               {
                  actionBtn.dispatchEvent(param1);
               }
               openEmotes();
               if(GuiManager.isInFFM)
               {
                  emoteBtn.mouseEnabled = false;
                  emoteBtn.mouseChildren = false;
                  emoteBtn.removeEventListener("mouseDown",emoteBtnDownHandler);
               }
            }
         }
      }
      
      private function smileyClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!emoteBtn.isGray)
         {
            if(GuiManager.isInFFM)
            {
               emoteBtn.mouseEnabled = true;
               emoteBtn.mouseChildren = true;
               emoteBtn.addEventListener("mouseDown",emoteBtnDownHandler,false,0,true);
            }
            emoteBtn.dispatchEvent(new MouseEvent("mouseDown"));
            EmoticonUtility.handleSmileyClick(param1.target,setEmoteCallback);
            AJAudio.playSubMenuBtnClick();
         }
      }
      
      private function smileyRollOverHandler(param1:MouseEvent) : void
      {
         if(param1.target is MovieClip)
         {
            MovieClip(param1.target).gotoAndPlay(1);
         }
         AJAudio.playSubMenuBtnRollover();
         emoteWindow.setChildIndex(emoteBtnsBg,1);
         emoteBtnsBg.x = param1.currentTarget.x;
         emoteBtnsBg.y = param1.currentTarget.y;
         emoteBtnsBg.visible = true;
      }
      
      private function smileyRollOutHandler(param1:MouseEvent) : void
      {
         emoteBtnsBg.visible = false;
      }
   }
}

