package imageArray
{
   import com.sbi.graphics.LayerAnim;
   import loader.DefPacksDefHelper;
   
   public class ImageArrayInfoHelper
   {
      private static var _imageArrayInfoDefs:Array;
      
      public function ImageArrayInfoHelper()
      {
         super();
      }
      
      public static function init() : void
      {
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(1029,imageArrayInfoDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1029] = _loc1_;
         LayerAnim.hasSequence = hasSequence;
      }
      
      private static function imageArrayInfoDefResponse(param1:DefPacksDefHelper) : void
      {
         _imageArrayInfoDefs = [];
         for(var _loc2_ in param1.def)
         {
            _imageArrayInfoDefs[_loc2_] = new ImageArrayInfo(param1.def[_loc2_]);
         }
      }
      
      public static function hasSequence(param1:int) : Boolean
      {
         return _imageArrayInfoDefs[param1] != undefined && _imageArrayInfoDefs[param1].hasSequence;
      }
   }
}

