package movie
{
   import loader.DefPacksDefHelper;
   
   public class MovieXtCommManager
   {
      private static var _movieNodeDefs:Object;
      
      private static var _movieTrees:Object = {};
      
      public function MovieXtCommManager()
      {
         super();
      }
      
      public static function movieNodeResponse(param1:DefPacksDefHelper) : void
      {
         var _loc3_:Object = null;
         var _loc5_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1053] = null;
         var _loc4_:Object = {};
         for each(var _loc2_ in param1.def)
         {
            _loc3_ = {
               "choice1MovieNodeRefId":int(_loc2_.choice1MovieNodeRefId),
               "choice2MovieNodeRefId":int(_loc2_.choice2MovieNodeRefId),
               "choice3MovieNodeRefId":int(_loc2_.choice3MovieNodeRefId),
               "mediaRefId":int(_loc2_.mediaRefId),
               "iconMediaRefId":int(_loc2_.iconMediaRefId),
               "thumbMediaRefId":int(_loc2_.thumbMediaRefId),
               "denItemRefId":int(_loc2_.denItemRefId),
               "titleStrRef":int(_loc2_.titleStrRef),
               "streamRefId":int(_loc2_.streamRefId),
               "streamTitleStrRef":int(_loc2_.streamTitleStrRef),
               "userVarRefId":int(_loc2_.userVarRefId),
               "userVarBit":int(_loc2_.userVarBit),
               "subtitleId":int(_loc2_.subtitleRefId),
               "defId":int(_loc2_.id),
               "numChoices":0
            };
            _loc3_.numChoices = _loc3_.choice3MovieNodeRefId > 0 ? 3 : (_loc3_.choice2MovieNodeRefId > 0 ? 2 : (_loc3_.choice1MovieNodeRefId > 0 ? 1 : 0));
            _loc4_[_loc3_.defId] = _loc3_;
         }
         _movieNodeDefs = _loc4_;
         getAllContinuingNodes(1);
      }
      
      public static function get movieDefs() : Object
      {
         return _movieNodeDefs;
      }
      
      public static function getMovieDef(param1:int) : MovieNode
      {
         return new MovieNode(_movieNodeDefs[param1]);
      }
      
      public static function getMovieNodeFromTree(param1:int, param2:int) : MovieNode
      {
         if(_movieTrees[param1] != null)
         {
            return _movieTrees[param1][param2];
         }
         return null;
      }
      
      public static function getAllContinuingNodes(param1:int) : Array
      {
         if(_movieTrees[param1] == null)
         {
            _movieTrees[param1] = {};
            _movieTrees[param1][param1] = getTreeMovieDef(param1);
            buildNodeTree(_movieTrees[param1][param1],param1);
         }
         var _loc2_:Array = [];
         for each(var _loc3_ in _movieTrees[param1])
         {
            if(_loc3_.isCorrectChoice)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function getAllChapters(param1:int) : Array
      {
         if(_movieTrees[param1] == null)
         {
            _movieTrees[param1] = {};
            _movieTrees[param1][param1] = getTreeMovieDef(param1);
            buildNodeTree(_movieTrees[param1][param1],param1);
         }
         var _loc2_:Array = [];
         for each(var _loc3_ in _movieTrees[param1])
         {
            if(_loc3_.isChapter)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function resetAllChosenChapters(param1:int) : void
      {
         for each(var _loc2_ in _movieTrees[param1])
         {
            if(_loc2_.hasChosenThisChoice)
            {
               _loc2_.hasChosenThisChoice = false;
            }
         }
      }
      
      private static function getTreeMovieDef(param1:int) : MovieTreeNode
      {
         return new MovieTreeNode(_movieNodeDefs[param1]);
      }
      
      private static function contains(param1:int, param2:int) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_movieTrees[param1] != null)
         {
            _loc4_ = int(_movieTrees[param1].length);
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               if(_movieTrees[param1][_loc3_].defId == param2)
               {
                  return _loc3_;
               }
               _loc3_++;
            }
         }
         return -1;
      }
      
      private static function buildNodeTree(param1:MovieTreeNode, param2:int) : void
      {
         var _loc3_:MovieTreeNode = null;
         if(param1.nodeIndex > 3)
         {
            if(param1.defId != param2)
            {
               _loc3_ = _movieTrees[param2][param1.parentDefId];
               _loc3_.nodeIndex++;
               buildNodeTree(_loc3_,param2);
            }
            return;
         }
         if(param1.getChoiceById(param1.nodeIndex) == 0)
         {
            if(param1.defId == param2)
            {
               param1.nodeIndex++;
               buildNodeTree(param1,param2);
            }
            else
            {
               if(param1.userVarId != 0)
               {
                  param1.isChapter = true;
               }
               if(param1.denRewardId > 0)
               {
                  if(param1.isChapter)
                  {
                     param1.thisChapterHasGift = true;
                  }
                  else if(param1.parentDefId != 0)
                  {
                     _movieTrees[param2][param1.parentDefId].thisChapterHasGift = true;
                  }
               }
               param1.isCorrectChoice = true;
               _loc3_ = _movieTrees[param2][param1.parentDefId];
               _loc3_.nodeIndex++;
               buildNodeTree(_loc3_,param2);
            }
            return;
         }
         var _loc4_:MovieTreeNode = getTreeMovieDef(param1.getChoiceById(param1.nodeIndex));
         if(_loc4_ == null || _loc4_.nodeIndex > 3)
         {
            throw new Error("CurrChoiceNode was null or we are past 3rd index");
         }
         if(_loc4_.defId == param1.parentDefId)
         {
            param1.isChapter = false;
            _loc3_ = _movieTrees[param2][_loc4_.defId];
            if(_loc3_.defId != _loc4_.defId)
            {
               throw new Error("Parent def id did not match current choices def id");
            }
            _loc3_.nodeIndex++;
            buildNodeTree(_loc3_,param2);
         }
         else
         {
            if(param1.userVarId != 0)
            {
               param1.isChapter = true;
            }
            if(param1.denRewardId > 0)
            {
               if(param1.isChapter)
               {
                  param1.thisChapterHasGift = true;
               }
               else
               {
                  _movieTrees[param2][param1.parentDefId].thisChapterHasGift = true;
               }
            }
            param1.isCorrectChoice = true;
            _movieTrees[param2][_loc4_.defId] = _loc4_;
            _loc4_.parentDefId = param1.defId;
            buildNodeTree(_loc4_,param2);
         }
      }
   }
}

