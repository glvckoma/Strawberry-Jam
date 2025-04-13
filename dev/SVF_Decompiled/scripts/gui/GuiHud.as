package gui
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiHud extends MovieClip
   {
      public var charWindow:MovieClip;
      
      public var charNameTxt:TextField;
      
      public var safeChatTreeWindow:MovieClip;
      
      public var swapBtn:MovieClip;
      
      public var actionsWindow:MovieClip;
      
      public var emotesWindow:MovieClip;
      
      public var chatBar:MovieClip;
      
      public var sendChatBtn:MovieClip;
      
      public var ansChatBtn:MovieClip;
      
      public var emailChatBtn:MovieClip;
      
      public var chatTxt:TextField;
      
      public var chatHist:MovieClip;
      
      public var chatHistUpDownBtn:MovieClip;
      
      public var chatHistTxt:TextField;
      
      public var chatRepeatBtn:MovieClip;
      
      public var chatRepeatWindow:MovieClip;
      
      public var editCharBtn:MovieClip;
      
      public var actionsBtn:MovieClip;
      
      public var safeChatBtn:MovieClip;
      
      public var emotesBtn:MovieClip;
      
      public var denBtn:MovieClip;
      
      public var worldMapBtn:MovieClip;
      
      public var soundBtn:MovieClip;
      
      public var furnBtn:MovieClip;
      
      public var eCardBtn:MovieClip;
      
      public var buddyListBtn:MovieClip;
      
      public var newsBtn:MovieClip;
      
      public var reportBtn:MovieClip;
      
      public var mySettingsBtn:MovieClip;
      
      public var zoneName:MovieClip;
      
      public var zoneNameTxt:TextField;
      
      public var games:MovieClip;
      
      public var eCardCount:MovieClip;
      
      public var eCardCountTxt:TextField;
      
      public var partyBtn:MovieClip;
      
      public var playerWallBtn:MovieClip;
      
      public var money:MovieClip;
      
      public var journeyBook:MovieClip;
      
      public var combatCardDeckBtn:MovieClip;
      
      public var questExitBtn:MovieClip;
      
      public var questPlayersBtn:MovieClip;
      
      public var questObjectiveTxt:TextField;
      
      public var ajEmailBtn:MovieClip;
      
      public var upperHudItems:Array;
      
      private var append:String;
      
      public function GuiHud()
      {
         super();
         init();
      }
      
      public function init(param1:Boolean = false) : void
      {
         append = currentFrameLabel == "quest" ? "Quest" : "";
         charWindow = this["char"];
         charNameTxt = this["text01_charName"];
         safeChatTreeWindow = this["safeChatTree" + append];
         actionsWindow = this["actionWindow" + append];
         emotesWindow = this["emoteWindow" + append];
         chatBar = this["hud01_chat" + append];
         sendChatBtn = chatBar != null ? chatBar.but01_send : null;
         ansChatBtn = chatBar != null ? chatBar.but01_ans : null;
         emailChatBtn = chatBar != null ? chatBar.but01_email : null;
         chatTxt = chatBar != null ? chatBar.text01_chat : null;
         chatHist = this["chat" + append];
         chatHistUpDownBtn = chatHist != null ? chatHist.chatHistoryBG.chatHistBox.hud01_chatHistory.chatUpDown : null;
         chatHistTxt = chatHist != null ? chatHist.chatHistoryBG["chatHistoryTxtCont" + append].text01_chatHistory : null;
         chatRepeatBtn = this["chatRepeat" + append];
         chatRepeatWindow = this["chatRepeatWindow" + append];
         swapBtn = this["swap"];
         actionsBtn = this["anim" + append];
         safeChatBtn = this["speedChat" + append];
         emotesBtn = this["emote" + append];
         denBtn = this["home"];
         worldMapBtn = this["world"];
         soundBtn = this["sound_btn" + append];
         furnBtn = this["furnBtn"];
         games = this["games"];
         money = this["money"];
         eCardBtn = this["mail"];
         buddyListBtn = this["buddyList"];
         newsBtn = this["news"];
         reportBtn = this["report"];
         mySettingsBtn = this["mySettings"];
         zoneName = this["zoneName"];
         zoneNameTxt = zoneName != null ? zoneName.mouse.name_txt : null;
         eCardCount = eCardBtn != null ? eCardBtn.newEcardCount : null;
         eCardCountTxt = eCardCount != null ? eCardCount.eCardCountTxt : null;
         partyBtn = this["party"];
         playerWallBtn = this["playerWall"];
         journeyBook = this["book"];
         combatCardDeckBtn = this["cardDeck_btn"];
         questExitBtn = this["questingExit_btn" + append];
         questPlayersBtn = this["questPlayersBtn"];
         ajEmailBtn = this["ajEmail"];
         if(this["objBar"] != null)
         {
            questObjectiveTxt = this["objBar"].objTxt;
         }
         if(!param1)
         {
            if(!(eCardBtn && buddyListBtn && newsBtn && zoneName && mySettingsBtn && reportBtn && playerWallBtn))
            {
               throw new Error("GuiHud TOP BAR section is missing parts or they are named incorrectly!");
            }
            if(!(swapBtn && actionsBtn && safeChatBtn && emotesBtn && denBtn && worldMapBtn && soundBtn && charNameTxt && eCardCount && eCardCountTxt))
            {
               throw new Error("GuiHud MAIN BUTTONS section is missing parts or they are named incorrectly!");
            }
            if(!(actionsWindow && safeChatTreeWindow && emotesWindow && charWindow))
            {
               throw new Error("GuiHud WINDOWS section is missing parts or they are named incorrectly!");
            }
            if(!(zoneName && zoneName.mouse.mid && zoneName.mouse.left && zoneName.mouse.right))
            {
               throw new Error("GuiHud ZONE NAME section is missing parts or they are named incorrectly!");
            }
            if(!(chatBar && sendChatBtn && ansChatBtn && emailChatBtn && chatTxt))
            {
               throw new Error("GuiHud CHAT BAR section is missing parts or they are named incorrectly!");
            }
            if(!(chatHist && chatHistUpDownBtn && chatHistTxt && chatRepeatBtn && chatRepeatWindow))
            {
               throw new Error("GuiHud CHAT HISTORY section is missing parts or they are named incorrectly!");
            }
         }
      }
   }
}

