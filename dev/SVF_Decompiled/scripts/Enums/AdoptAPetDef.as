package Enums
{
   import localization.LocalizationManager;
   
   public class AdoptAPetDef
   {
      private var _defId:int;
      
      private var _titleStrId:int;
      
      private var _mediaRefId:int;
      
      private var _type:int;
      
      private var _series:int;
      
      private var _hidden:Boolean;
      
      public function AdoptAPetDef(param1:int, param2:int, param3:int, param4:int, param5:int, param6:Boolean)
      {
         super();
         _defId = param1;
         _titleStrId = param2;
         _mediaRefId = param3;
         _type = param4;
         _series = param5;
         _hidden = param6;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get titleStrId() : int
      {
         return _titleStrId;
      }
      
      public function get mediaRefId() : int
      {
         return _mediaRefId;
      }
      
      public function get name() : String
      {
         return LocalizationManager.translateIdOnly(_titleStrId);
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get series() : int
      {
         return _series;
      }
      
      public function get hidden() : Boolean
      {
         return _hidden;
      }
   }
}

