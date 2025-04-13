package gui
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.JPEGAsyncCompleteEvent;
   import com.sbi.graphics.JpegAsynchEncoder;
   import com.sbi.popup.SBOkPopup;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import localization.LocalizationManager;
   
   public class UserImageUpload
   {
      private static const MAX_FILE_SIZE:Number = 2048000;
      
      private var _myFileReference:FileReference;
      
      private var _byteArrayLoader:Loader;
      
      private var _uploadBtn:MovieClip;
      
      private var _jpgEncoder:JpegAsynchEncoder;
      
      private var _fileName:String;
      
      public function UserImageUpload()
      {
         super();
      }
      
      public function init() : void
      {
         addEventListeners();
      }
      
      public function setUploadBtn(param1:MovieClip) : void
      {
         if(param1)
         {
            _uploadBtn = param1;
            _uploadBtn.addEventListener("mouseDown",onUploadDown,false,0,true);
            return;
         }
         throw new Error("Upload button was not provided");
      }
      
      public function get uploadedImage() : ByteArray
      {
         if(_jpgEncoder)
         {
            return _jpgEncoder.ImageData;
         }
         return null;
      }
      
      public function get fileName() : String
      {
         if(_fileName)
         {
            return _fileName;
         }
         return "";
      }
      
      public function resetUploader() : void
      {
         _jpgEncoder = null;
         _fileName = null;
      }
      
      private function onUploadDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _myFileReference = new FileReference();
         _myFileReference.addEventListener("select",onFileSelected,false,0,true);
         _myFileReference.browse([new FileFilter("Images","*.jpeg;*.jpg;*.png")]);
      }
      
      private function onFileSelected(param1:Event) : void
      {
         if(_myFileReference.size > 2048000)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14806));
            return;
         }
         DarkenManager.showLoadingSpiral(true,true);
         _myFileReference.addEventListener("complete",onFileLoaded,false,0,true);
         _myFileReference.addEventListener("ioError",onFileLoadError,false,0,true);
         _myFileReference.addEventListener("progress",onProgress,false,0,true);
         _myFileReference.load();
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         DebugUtility.debugTrace("UPLOADED: " + (param1.bytesLoaded / param1.bytesTotal * 100).toFixed() + " %");
      }
      
      private function onFileLoaded(param1:Event) : void
      {
         var _loc2_:FileReference = param1.target as FileReference;
         if(_loc2_["data"].bytesAvailable > 0)
         {
            _byteArrayLoader = new Loader();
            _byteArrayLoader.loadBytes(_loc2_["data"]);
            _fileName = _myFileReference.name;
            _byteArrayLoader.contentLoaderInfo.addEventListener("complete",onByteArrayLoaded,false,0,true);
            _myFileReference.removeEventListener("complete",onFileLoaded);
            _myFileReference.removeEventListener("ioError",onFileLoadError);
            _myFileReference.removeEventListener("progress",onProgress);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            onFileLoadError(null);
         }
      }
      
      private function onFileLoadError(param1:Event) : void
      {
         _myFileReference.removeEventListener("complete",onFileLoaded);
         _myFileReference.removeEventListener("ioError",onFileLoadError);
         _myFileReference.removeEventListener("progress",onProgress);
         new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14807));
      }
      
      private function onByteArrayLoaded(param1:Event) : void
      {
         var _loc2_:Bitmap = param1.target.content;
         _jpgEncoder = new JpegAsynchEncoder();
         _jpgEncoder.addEventListener("JPEGAsyncComplete",asyncEncodingComplete,false,0,true);
         _jpgEncoder.addEventListener("progress",onEncodingProgress,false,0,true);
         _jpgEncoder.PixelsPerIteration = 128;
         _jpgEncoder.JPEGAsyncEncoder(95);
         _jpgEncoder.encode(_loc2_.bitmapData);
      }
      
      private function asyncEncodingComplete(param1:JPEGAsyncCompleteEvent) : void
      {
         _jpgEncoder.removeEventListener("JPEGAsyncComplete",asyncEncodingComplete);
         _jpgEncoder.removeEventListener("progress",onEncodingProgress);
         _uploadBtn.visible = false;
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function onEncodingProgress(param1:ProgressEvent) : void
      {
         DarkenManager.updateLoadingSpiralPercentage(Math.round(param1.bytesLoaded / param1.bytesTotal * 100) + "%");
      }
      
      private function addEventListeners() : void
      {
      }
      
      private function removeEventListeners() : void
      {
         _uploadBtn.removeEventListener("mouseDown",onUploadDown);
      }
   }
}

