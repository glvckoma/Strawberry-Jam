package
{
   import com.sbi.loader.ResourceStack;
   import localization.LocalizationManager;
   
   public function GETDEFINITIONBYNAME(param1:String, param2:Boolean = true) : *
   {
      var _loc3_:* = new (ResourceStack.hudAssetsLoaderInfo.applicationDomain.getDefinition(param1) as Class)();
      if(param2)
      {
         LocalizationManager.findAllTextfields(_loc3_);
      }
      return _loc3_;
   }
}

