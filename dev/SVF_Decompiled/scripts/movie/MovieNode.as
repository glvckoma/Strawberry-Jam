package movie
{
   public class MovieNode
   {
      private var _titleId:int;
      
      private var _streamId:int;
      
      private var _streamTitleId:int;
      
      private var _mediaId:int;
      
      private var _iconMediaId:int;
      
      private var _thumbMediaId:int;
      
      private var _choices:Object;
      
      private var _denRewardId:int;
      
      private var _userVarId:int;
      
      private var _bitIndex:int;
      
      private var _defId:int;
      
      private var _numChoices:int;
      
      private var _hasChosenThisChoice:Boolean;
      
      private var _subtitleId:int;
      
      protected var _thisChapterHasGift:Boolean;
      
      protected var _isChapter:Boolean;
      
      public function MovieNode(param1:Object)
      {
         super();
         _defId = param1.defId;
         _titleId = param1.titleStrRef;
         _streamId = param1.streamRefId;
         _streamTitleId = param1.streamTitleStrRef;
         _mediaId = param1.mediaRefId;
         _iconMediaId = param1.iconMediaRefId;
         _thumbMediaId = param1.thumbMediaRefId;
         _choices = {
            "choice1Id":param1.choice1MovieNodeRefId,
            "choice2Id":param1.choice2MovieNodeRefId,
            "choice3Id":param1.choice3MovieNodeRefId
         };
         _denRewardId = param1.denItemRefId;
         _userVarId = param1.userVarRefId;
         _bitIndex = param1.userVarBit;
         _numChoices = param1.numChoices;
         _subtitleId = param1.subtitleId;
         param1 = null;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get titleId() : int
      {
         return _titleId;
      }
      
      public function get streamId() : int
      {
         return _streamId;
      }
      
      public function get streamTitleId() : int
      {
         return _streamTitleId;
      }
      
      public function get mediaId() : int
      {
         return _mediaId;
      }
      
      public function get iconMediaId() : int
      {
         return _iconMediaId;
      }
      
      public function get thumbMediaId() : int
      {
         return _thumbMediaId;
      }
      
      public function getChoiceById(param1:int) : int
      {
         return _choices["choice" + param1 + "Id"];
      }
      
      public function get choice1Id() : int
      {
         return _choices.choice1Id;
      }
      
      public function get choice2Id() : int
      {
         return _choices.choice2Id;
      }
      
      public function get choice3Id() : int
      {
         return _choices.choice3Id;
      }
      
      public function get denRewardId() : int
      {
         return _denRewardId;
      }
      
      public function get userVarId() : int
      {
         return _userVarId;
      }
      
      public function get bitIndex() : int
      {
         return _bitIndex;
      }
      
      public function get numChoices() : int
      {
         return _numChoices;
      }
      
      public function set thisChapterHasGift(param1:Boolean) : void
      {
         _thisChapterHasGift = param1;
      }
      
      public function get thisChapterHasGift() : Boolean
      {
         return _thisChapterHasGift;
      }
      
      public function get isChapter() : Boolean
      {
         return _isChapter;
      }
      
      public function set isChapter(param1:Boolean) : void
      {
         _isChapter = param1;
      }
      
      public function get hasChosenThisChoice() : Boolean
      {
         return _hasChosenThisChoice;
      }
      
      public function set hasChosenThisChoice(param1:Boolean) : void
      {
         _hasChosenThisChoice = param1;
      }
      
      public function get subtitleId() : int
      {
         return _subtitleId;
      }
      
      public function set subtitleId(param1:int) : void
      {
         _subtitleId = param1;
      }
   }
}

