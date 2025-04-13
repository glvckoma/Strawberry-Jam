package gui
{
   import com.sbi.prediction.Predictions;
   import flash.text.TextField;
   import localization.LocalizationManager;
   
   public class PredictiveTextMessageValidation
   {
      private var _useType:int;
      
      private var _predictions:Predictions;
      
      private var _testTextField:TextField;
      
      public function PredictiveTextMessageValidation(param1:int)
      {
         super();
         _useType = param1;
         _testTextField = new TextField();
         _testTextField.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
         if(PredictiveTextManager.dictionaryBlob != null)
         {
            _predictions = new Predictions();
            _predictions.setDictionary(PredictiveTextManager.dictionaryBlob);
         }
         else
         {
            PredictiveTextManager.onDictionaryBlobLoaded = onDictionaryBlobLoaded;
         }
      }
      
      public function isTextValid(param1:String) : Boolean
      {
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc2_:Boolean = false;
         var _loc4_:int = 0;
         var _loc3_:Array = null;
         var _loc5_:int = 0;
         if(_predictions)
         {
            _testTextField.text = param1;
            _loc6_ = _testTextField.text;
            _loc7_ = _loc6_.split(" ");
            _loc2_ = false;
            _loc4_ = 0;
            while(_loc4_ < _loc7_.length)
            {
               _loc3_ = _predictions.predict(_loc7_[_loc4_],3,50,100,_useType);
               if(_loc3_.length > 0)
               {
                  _loc5_ = 0;
                  while(_loc5_ < _loc3_.length)
                  {
                     if(_loc3_[_loc5_][0].toLowerCase() == _loc7_[_loc4_].toLowerCase())
                     {
                        _loc2_ = true;
                        break;
                     }
                     _loc5_++;
                  }
               }
               if(!_loc2_)
               {
                  return false;
               }
               _loc4_++;
            }
            return _loc2_;
         }
         return false;
      }
      
      private function onDictionaryBlobLoaded() : void
      {
         _predictions = new Predictions();
         _predictions.setDictionary(PredictiveTextManager.dictionaryBlob);
      }
   }
}

