package createAccountGui
{
   import com.greensock.TweenLite;
   import com.sbi.analytics.SBTracker;
   import createAccountFlow.CreateAccount;
   import createAccountFlow.CreateAccountGui;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import gui.DarkenManager;
   import gui.GuiRadioButtonGroup;
   import gui.GuiSoundBtnSubMenu;
   import gui.GuiSoundToggleButton;
   import gui.GuiStatusIcon;
   
   public class GuiPlayerTagScreen
   {
      public static const NUM_SUGGESTED_NAMES:int = 4;
      
      private const REGISTRATION_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const REGISTRATION_PANEL_X_DIRECTION:Number = -565;
      
      private const BACKGROUND_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const BACKGROUND_PANEL_X_DIRECTION:Number = -450;
      
      private var _newGenderRbg:GuiRadioButtonGroup;
      
      private var _nameSuggestionsFrame:MovieClip;
      
      private var _nameSugTxts:Array;
      
      private var _userNameKeyUpDelayTimer:Timer;
      
      private var _newUsernameTxt:TextField;
      
      private var _newUsernameBar:MovieClip;
      
      private var _newPasswordTxt:TextField;
      
      private var _newPasswordBar:MovieClip;
      
      private var _animalFrame:MovieClip;
      
      private var _animalFrameAnimalHolder:MovieClip;
      
      private var _activeSelBar2:MovieClip;
      
      private var _activeSelBar3:MovieClip;
      
      private var _activeSelBar4:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _playBtn:MovieClip;
      
      private var _newAgeSts:MovieClip;
      
      private var _genderSts:MovieClip;
      
      private var _userNameSts:MovieClip;
      
      private var _passWordSts:MovieClip;
      
      private var _tipsNeedTxt:TextField;
      
      private var _privacyPolicyTxt:TextField;
      
      private var _voBtn:MovieClip;
      
      private var _nameTipPopup:MovieClip;
      
      private var _passwordTipPopup:MovieClip;
      
      private var _creation:Object;
      
      private var _playerTagScreen:MovieClip;
      
      private var _validationPending:Boolean;
      
      private var _lastCheckedPlayerTag:String;
      
      private var _continueClicked:Boolean;
      
      private var _numTimesBadUsername:int;
      
      private var _registrationPanel:MovieClip;
      
      private var _selectedGender:int;
      
      private var _selectedBdayAgeIndex:int;
      
      private var _passwordText:String;
      
      private var _newAgeTracking:Object;
      
      private var _genderTracking:Object;
      
      private var _userNameTracking:Object;
      
      private var _passWordTracking:Object;
      
      private var _onLoaded:Function;
      
      private var _backgroundTween:TweenLite;
      
      private var _playerTagTween:TweenLite;
      
      private var _createAccount:CreateAccount;
      
      private var _creationAssets:GuiAvatarCreationAssets;
      
      public function GuiPlayerTagScreen(param1:Object, param2:CreateAccount, param3:GuiAvatarCreationAssets, param4:Function)
      {
         super();
         _creation = param1;
         _createAccount = param2;
         _creationAssets = param3;
         _playerTagScreen = _creation.registrationPanel.userNamePanel.userNameContainer.signup_wizard.act_popup;
         _onLoaded = param4;
         _registrationPanel = MovieClip(_creation.registrationPanel);
         _newGenderRbg = new GuiRadioButtonGroup(_playerTagScreen.gender.radioGenderBtn);
         _genderSts = _playerTagScreen.gender.gender_status;
         _newAgeSts = _playerTagScreen.age.age_status;
         _nameSuggestionsFrame = _playerTagScreen.NamePopup;
         _newUsernameTxt = _playerTagScreen.username.pTag_txt;
         _newUsernameBar = _playerTagScreen.username.textBar1;
         _newPasswordTxt = _playerTagScreen.password.pswd_txt;
         _newPasswordBar = _playerTagScreen.password.textBar2;
         _activeSelBar2 = _playerTagScreen.act_bar_sel2;
         _activeSelBar3 = _playerTagScreen.username.act_bar_sel3;
         _activeSelBar4 = _playerTagScreen.password.act_bar_sel4;
         _tipsNeedTxt = _playerTagScreen.tips_help_txt;
         _privacyPolicyTxt = _playerTagScreen.pp_txt;
         _voBtn = _playerTagScreen.vo_Btn;
         _backBtn = _creation.back_btn;
         _backBtn.gotoAndStop(1);
         _nextBtn = _creation.next_btn;
         _nextBtn.gotoAndStop(1);
         _playBtn = _creation.play_btn;
         _userNameSts = _playerTagScreen.username.username_status;
         _passWordSts = _playerTagScreen.password.pswd_status;
         _nameTipPopup = _playerTagScreen.nameTipPopup;
         _passwordTipPopup = _playerTagScreen.passwordTipPopup;
      }
      
      public function init() : void
      {
         var _loc3_:int = 0;
         var _loc1_:GuiSoundBtnSubMenu = null;
         var _loc2_:int = 0;
         _playerTagScreen.gender.visible = false;
         _playerTagScreen.username.visible = false;
         _playerTagScreen.password.visible = false;
         _newAgeTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _genderTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _userNameTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _passWordTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         GuiStatusIcon.initClip(_newAgeSts,_newAgeTracking);
         GuiStatusIcon.initClip(_genderSts,_genderTracking);
         GuiStatusIcon.initClip(_userNameSts,_userNameTracking);
         GuiStatusIcon.initClip(_passWordSts,_passWordTracking);
         _nameTipPopup.visible = false;
         _passwordTipPopup.visible = false;
         _validationPending = false;
         _continueClicked = false;
         _lastCheckedPlayerTag = "";
         _passwordText = "";
         _selectedBdayAgeIndex = -1;
         _selectedGender = -1;
         _nameSuggestionsFrame.visible = false;
         _nameSuggestionsFrame["bx"].addEventListener("mouseDown",nameSugCloseBtnMouseDownHandler,false,0,true);
         _nameSugTxts = [];
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc1_ = _nameSuggestionsFrame["name" + (_loc3_ + 1)];
            _nameSugTxts[_loc3_] = _loc1_["pTag_txt"];
            TextField(_nameSugTxts[_loc3_]).text = "ysername" + _loc3_;
            _loc1_.addEventListener("click",nameSugClickHandler,false,0,true);
            _loc3_++;
         }
         _userNameKeyUpDelayTimer = new Timer(1222);
         _userNameKeyUpDelayTimer.addEventListener("timer",userNameTxtChangeDelayTimerHandler,false,0,true);
         _newUsernameTxt.restrict = Utility.getUsernameRestrictions();
         _newUsernameTxt.maxChars = 20;
         _newPasswordTxt.restrict = "^ ";
         _newPasswordTxt.maxChars = 32;
         _activeSelBar2.visible = false;
         _activeSelBar3.visible = false;
         _activeSelBar4.visible = false;
         _selectedBdayAgeIndex = -1;
         _loc2_ = 5;
         while(_loc2_ < 17)
         {
            _playerTagScreen.age["age" + _loc2_].addEventListener("mouseDown",onAgeBtnDown,false,0,true);
            _loc2_++;
         }
         _newGenderRbg.currRadioButton.addEventListener("mouseDown",selBar2FocusHandler,false,0,true);
         _newUsernameTxt.addEventListener("change",userNameTxtChangeHandler,false,0,true);
         _newUsernameTxt.addEventListener("mouseDown",selBar3FocusHandler,false,0,true);
         _newUsernameTxt.addEventListener("keyDown",selBar3FocusHandler,false,0,true);
         _newUsernameTxt.addEventListener("focusIn",selBar3FocusHandler,false,0,true);
         _newPasswordTxt.addEventListener("change",passWordTxtChangeHandler,false,0,true);
         _newPasswordTxt.addEventListener("focusIn",selBar4FocusHandler,false,0,true);
         _tipsNeedTxt.htmlText = "<a href=\'event:\'><u>" + _tipsNeedTxt.text + "</u></a>";
         _tipsNeedTxt.addEventListener("link",tipsNeedTxtClickHandler,false,0,true);
         _privacyPolicyTxt.htmlText = "<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>" + _privacyPolicyTxt.text + "</u></a>";
         _voBtn.stop();
         _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
         _playerTagScreen.username.changeBtn.visible = false;
         _newUsernameTxt.text = "";
         _newPasswordTxt.text = "";
         if(_onLoaded != null)
         {
            _onLoaded();
            _onLoaded = null;
         }
      }
      
      public function destroy() : void
      {
         _newGenderRbg.currRadioButton.removeEventListener("mouseDown",selBar2FocusHandler);
         _newUsernameTxt.removeEventListener("change",userNameTxtChangeHandler);
         _newUsernameTxt.removeEventListener("mouseDown",selBar3FocusHandler);
         _newUsernameTxt.removeEventListener("keyDown",selBar3FocusHandler);
         _newUsernameTxt.removeEventListener("focusIn",selBar3FocusHandler);
         _newPasswordTxt.removeEventListener("change",passWordTxtChangeHandler);
         _newPasswordTxt.removeEventListener("focusIn",selBar4FocusHandler);
         _tipsNeedTxt.removeEventListener("link",tipsNeedTxtClickHandler);
         _voBtn.removeEventListener("click",voBtnClickHandler);
         _newGenderRbg.destroy();
         _newGenderRbg = null;
         _nameSuggestionsFrame["bx"].removeEventListener("mouseDown",nameSugCloseBtnMouseDownHandler);
         _userNameKeyUpDelayTimer.stop();
         _userNameKeyUpDelayTimer = null;
      }
      
      private function handlePlayBtn(param1:Boolean = false) : void
      {
         if(!param1)
         {
            _playBtn.upToDownState();
            _backBtn.mouseEnabled = false;
            _backBtn.mouseChildren = false;
            _playBtn.mouseEnabled = false;
            _playBtn.mouseChildren = false;
            setTimeout(handlePlayBtn,1000,true);
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         _backBtn.mouseEnabled = true;
         _backBtn.mouseChildren = true;
         _playBtn.mouseEnabled = true;
         _playBtn.mouseChildren = true;
         CreateAccountGui.vo5Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         if(_createAccount.createNewAccountSetup(onCreateAccountResponse) == false)
         {
            _playBtn.downToUpState();
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onCreateAccountResponse() : void
      {
         _playBtn.downToUpState();
         DarkenManager.showLoadingSpiral(false);
      }
      
      public function switchScreens(param1:Boolean, param2:int) : Boolean
      {
         if(_playerTagTween)
         {
            _playerTagTween.progress(1);
         }
         if(_backgroundTween)
         {
            _backgroundTween.progress(1);
         }
         switch(param2 - -1)
         {
            case 0:
               enterFromPrev();
               break;
            case 1:
               if(param1 && leaveToNext() || !param1 && leaveToPrev())
               {
                  if(param1)
                  {
                     handlePlayBtn();
                     return true;
                  }
                  GuiAvatarCreationAssets.screenPosition += param1 ? 1 : -1;
                  _backgroundTween = new TweenLite(MovieClip(_registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"],0.5,{"x":"+=" + -450 * (param1 ? 1 : -1)});
                  break;
               }
               _playBtn.downToUpState();
               return false;
               break;
            case 2:
               enterFromNext();
         }
         _playerTagTween = new TweenLite(_playerTagScreen,0.5,{"x":"+=" + -565 * (param1 ? 1 : -1)});
         return true;
      }
      
      private function enterFromPrev() : void
      {
         _playerTagScreen.gender.visible = true;
         _playerTagScreen.username.visible = true;
         _playerTagScreen.password.visible = true;
         _numTimesBadUsername = 0;
         CreateAccountGui.vo3Sound.play();
         if(CreateAccountGui.vo3Sound.sc)
         {
            CreateAccountGui.vo3Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
            _voBtn.play();
         }
         CreateAccountGui.trackUserCreateAccountPageChange("CreatePlayerAccount");
         selBar1FocusHandler(null);
         _playBtn.enabled = false;
         CreateAccountGui.hideNotifyPopup();
         checkIfNextShouldBeVisible();
      }
      
      private function enterFromNext() : Boolean
      {
         enterFromPrev();
         return true;
      }
      
      private function leaveToNext() : Boolean
      {
         CreateAccountGui.vo3Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         CreateAccountGui.showTipsPopup(false);
         return nextBtnHandler();
      }
      
      private function leaveToPrev() : Boolean
      {
         CreateAccountGui.vo3Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         _numTimesBadUsername = 0;
         CreateAccountGui.showNewChrPopup();
         CreateAccountGui.showTipsPopup(false);
         _nextBtn.visible = true;
         _playBtn.visible = false;
         return true;
      }
      
      public function stopVOButton(param1:Event) : void
      {
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
      }
      
      public function enableNext() : void
      {
         _playBtn.enabled = true;
      }
      
      public function userNameValidCallback(param1:int, param2:Array, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Array = null;
         _validationPending = false;
         _userNameSts.visible = true;
         if(param1 == 1)
         {
            GuiStatusIcon.showCheck(_userNameSts,_userNameTracking);
            checkIfNextShouldBeVisible();
            _newUsernameBar.visible = true;
            _nameSuggestionsFrame.visible = false;
            if(_continueClicked)
            {
               if(nextBtnHandler())
               {
                  if(_creationAssets != null)
                  {
                     _creationAssets.onNextBtn(null);
                  }
               }
            }
         }
         else
         {
            if(param1 == -3)
            {
               if(param3 != 2)
               {
                  SBTracker.trackPageview("/login/usernameValidation/#usernameUnavailable",0,1);
                  _numTimesBadUsername++;
               }
               _loc4_ = [];
               _loc5_ = 3;
               while(_loc5_ < param2.length)
               {
                  if(param2[_loc5_] != null && param2[_loc5_] != "")
                  {
                     _loc4_.push(param2[_loc5_]);
                  }
                  _loc5_++;
               }
               if(_loc4_.length != 0)
               {
                  _nameSuggestionsFrame.gotoAndStop(_loc4_.length);
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length)
                  {
                     TextField(_nameSugTxts[_loc5_]).text = _loc4_[_loc5_];
                     _loc5_++;
                  }
                  _nameSuggestionsFrame.visible = true;
               }
               else
               {
                  _nameSuggestionsFrame.visible = false;
               }
            }
            GuiStatusIcon.showX(_userNameSts,_userNameTracking);
            _playBtn.visible = false;
            if(_newUsernameTxt.text == "")
            {
               _userNameSts.visible = _userNameTracking.xTracking = _userNameTracking.waitTracking = _userNameTracking.checkTracking = false;
               _newUsernameBar.visible = true;
            }
            else
            {
               _newUsernameBar.visible = false;
            }
         }
         _continueClicked = false;
      }
      
      public function passWordValidCallback(param1:Boolean) : void
      {
         if(param1)
         {
            _passWordSts.visible = true;
            _passwordText = _newPasswordTxt.text;
            GuiStatusIcon.showCheck(_passWordSts,_passWordTracking);
            _newPasswordBar.visible = true;
            checkIfNextShouldBeVisible();
         }
         else
         {
            if(_newPasswordTxt.text.length == 0)
            {
               GuiStatusIcon.showWait(_passWordSts,_passWordTracking);
            }
            else
            {
               GuiStatusIcon.showX(_passWordSts,_passWordTracking);
            }
            _passwordText = "";
            _playBtn.visible = false;
            _createAccount.invalidatePassWord();
         }
      }
      
      private function markEmptyAsError() : void
      {
         if(_newUsernameTxt.text == "")
         {
            GuiStatusIcon.showX(_userNameSts,_userNameTracking);
            _userNameSts.visible = true;
            _newUsernameBar.visible = false;
         }
         checkPassWord();
      }
      
      private function checkUserName() : void
      {
         if(_createAccount.validatedUserName != _newUsernameTxt.text)
         {
            if(_createAccount.validatedUserName)
            {
               _createAccount.invalidateUserName();
            }
            if(_newUsernameTxt.text == "")
            {
               _userNameSts.visible = _userNameTracking.xTracking = _userNameTracking.waitTracking = _userNameTracking.checkTracking = false;
               CreateAccountGui.hideNotifyPopup();
            }
            else if(_newUsernameTxt.text != _lastCheckedPlayerTag)
            {
               if(_validationPending)
               {
                  if(!_userNameKeyUpDelayTimer.running)
                  {
                     _createAccount.invalidatePending();
                  }
                  _userNameKeyUpDelayTimer.reset();
               }
               _lastCheckedPlayerTag = _newUsernameTxt.text;
               if(_newUsernameTxt.text.length > 2)
               {
                  _validationPending = true;
                  _userNameSts.visible = true;
                  GuiStatusIcon.showWait(_userNameSts,_userNameTracking);
                  _userNameKeyUpDelayTimer.start();
               }
               else
               {
                  _validationPending = false;
                  GuiStatusIcon.showX(_userNameSts,_userNameTracking);
               }
            }
         }
      }
      
      private function checkPassWord() : void
      {
         _createAccount.validatePassWord(_newPasswordTxt.text,_newUsernameTxt.text,passWordValidCallback);
      }
      
      private function userNameTxtChangeHandler(param1:Event) : void
      {
         checkUserName();
         checkPassWord();
         CreateAccountGui.hideNotifyPopup();
      }
      
      private function userNameTxtChangeDelayTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = _newUsernameTxt.text;
         _newUsernameTxt.text = _loc2_.substr(0,1) + _loc2_.substr(1).toLowerCase();
         _createAccount.validateUserName(_newUsernameTxt.text,_newPasswordTxt.text,0,0,0,userNameValidCallback);
         _userNameKeyUpDelayTimer.reset();
      }
      
      private function nameSugClickHandler(param1:MouseEvent) : void
      {
         _newUsernameTxt.text = param1.currentTarget["pTag_txt"].text;
         userNameTxtChangeHandler(null);
         _nameSuggestionsFrame.visible = false;
      }
      
      private function nameSugCloseBtnMouseDownHandler(param1:MouseEvent) : void
      {
         _nameSuggestionsFrame.visible = false;
      }
      
      private function passWordTxtChangeHandler(param1:Event) : void
      {
         checkPassWord();
         checkUserName();
      }
      
      private function onAgeBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name.split("age")[1] == _selectedBdayAgeIndex)
         {
            _selectedBdayAgeIndex = -1;
            GuiStatusIcon.showWait(_newAgeSts,_newAgeTracking);
         }
         else
         {
            if(_selectedBdayAgeIndex != -1)
            {
               GuiSoundToggleButton(_playerTagScreen.age["age" + _selectedBdayAgeIndex]).downToUpState();
            }
            _selectedBdayAgeIndex = param1.currentTarget.name.split("age")[1];
            GuiStatusIcon.showCheck(_newAgeSts,_newAgeTracking);
         }
         checkIfNextShouldBeVisible();
      }
      
      private function selBar1FocusHandler(param1:Event) : void
      {
         _activeSelBar2.visible = false;
         _activeSelBar3.visible = false;
         _activeSelBar4.visible = false;
         _nameSuggestionsFrame.visible = false;
         _nameTipPopup.visible = false;
         _passwordTipPopup.visible = false;
         checkIfNextShouldBeVisible();
      }
      
      private function selBar2FocusHandler(param1:Event) : void
      {
         if(!_activeSelBar2.visible)
         {
            _activeSelBar2.visible = true;
            _activeSelBar3.visible = false;
            _activeSelBar4.visible = false;
            _nameSuggestionsFrame.visible = false;
            _nameTipPopup.visible = false;
            _passwordTipPopup.visible = false;
         }
         if(param1)
         {
            _selectedGender = _newGenderRbg.selected;
            if(_selectedGender != -1)
            {
               GuiStatusIcon.showCheck(_genderSts,_genderTracking);
            }
         }
         checkIfNextShouldBeVisible();
      }
      
      private function selBar3FocusHandler(param1:Event) : void
      {
         if(!_activeSelBar3.visible)
         {
            _activeSelBar2.visible = false;
            _activeSelBar3.visible = true;
            _activeSelBar4.visible = false;
            _nameTipPopup.visible = true;
            _passwordTipPopup.visible = false;
            _nameSuggestionsFrame.visible = false;
         }
         CreateAccountGui.hideNotifyPopup();
         checkIfNextShouldBeVisible();
      }
      
      private function selBar4FocusHandler(param1:FocusEvent) : void
      {
         if(!_activeSelBar4.visible)
         {
            _activeSelBar2.visible = false;
            _activeSelBar3.visible = false;
            _activeSelBar4.visible = true;
            _nameSuggestionsFrame.visible = false;
            _nameTipPopup.visible = false;
            _passwordTipPopup.visible = true;
         }
         checkIfNextShouldBeVisible();
      }
      
      private function tipsNeedTxtClickHandler(param1:TextEvent) : void
      {
         param1.preventDefault();
         CreateAccountGui.showTipsPopup(true);
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(CreateAccountGui.vo3Sound.isPlaying)
         {
            CreateAccountGui.vo3Sound.stop();
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo3Sound.play();
            if(CreateAccountGui.vo3Sound.sc)
            {
               CreateAccountGui.vo3Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
               _voBtn.play();
            }
         }
      }
      
      private function nextBtnHandler() : Boolean
      {
         if(_validationPending)
         {
            _continueClicked = true;
            return false;
         }
         if(_createAccount.validatedUserName)
         {
            if(_createAccount.validatedPassWord)
            {
               if(_newGenderRbg.selected < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(-99);
                  return false;
               }
               if(_selectedBdayAgeIndex == -1)
               {
                  CreateAccountGui.showLoginCreateResultMsg(-98);
                  return false;
               }
               _createAccount.setBirthday("","",String(_selectedBdayAgeIndex));
               _createAccount.setGender(_newGenderRbg.selected);
               _numTimesBadUsername = 0;
               return true;
            }
            passWordTxtChangeHandler(null);
            markEmptyAsError();
            return false;
         }
         _continueClicked = true;
         _createAccount.validateUserName(_newUsernameTxt.text,_newPasswordTxt.text,0,0,0,userNameValidCallback);
         markEmptyAsError();
         return false;
      }
      
      private function checkIfNextShouldBeVisible() : void
      {
         _nextBtn.visible = false;
         if(_userNameSts["_check"].visible && _passWordSts["_check"].visible && _genderSts["_check"].visible && (_newAgeSts == null || _newAgeSts["_check"].visible))
         {
            _playBtn.visible = true;
         }
         else
         {
            _playBtn.visible = false;
         }
      }
   }
}

