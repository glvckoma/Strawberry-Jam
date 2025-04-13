package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataWatcher;
   import org.osmf.utils.OSMFStrings;
   
   public class LayoutRendererBase extends EventDispatcher
   {
      private static var cleaningRenderers:Boolean;
      
      private static var dispatcher:DisplayObject = new Sprite();
      
      private static var dirtyRenderers:Vector.<LayoutRendererBase> = new Vector.<LayoutRendererBase>();
      
      private var _parent:LayoutRendererBase;
      
      private var _container:ILayoutTarget;
      
      private var layoutMetadata:LayoutMetadata;
      
      private var layoutTargets:Vector.<ILayoutTarget> = new Vector.<ILayoutTarget>();
      
      private var stagedDisplayObjects:Dictionary = new Dictionary(true);
      
      private var _measuredWidth:Number;
      
      private var _measuredHeight:Number;
      
      private var dirty:Boolean;
      
      private var cleaning:Boolean;
      
      private var metaDataWatchers:Dictionary = new Dictionary();
      
      public function LayoutRendererBase()
      {
         super();
      }
      
      private static function flagDirty(param1:LayoutRendererBase) : void
      {
         if(param1 == null || dirtyRenderers.indexOf(param1) != -1)
         {
            return;
         }
         dirtyRenderers.push(param1);
         if(cleaningRenderers == false)
         {
            dispatcher.addEventListener("exitFrame",onExitFrame);
         }
      }
      
      private static function flagClean(param1:LayoutRendererBase) : void
      {
         var _loc2_:Number = Number(dirtyRenderers.indexOf(param1));
         if(_loc2_ != -1)
         {
            dirtyRenderers.splice(_loc2_,1);
         }
      }
      
      private static function onExitFrame(param1:Event) : void
      {
         var _loc2_:LayoutRendererBase = null;
         dispatcher.removeEventListener("exitFrame",onExitFrame);
         cleaningRenderers = true;
         while(dirtyRenderers.length != 0)
         {
            _loc2_ = dirtyRenderers.shift();
            if(_loc2_.parent == null)
            {
               _loc2_.validateNow();
            }
            else
            {
               _loc2_.dirty = false;
            }
         }
         cleaningRenderers = false;
      }
      
      final public function get parent() : LayoutRendererBase
      {
         return _parent;
      }
      
      final internal function setParent(param1:LayoutRendererBase) : void
      {
         _parent = param1;
         processParentChange(_parent);
      }
      
      final public function get container() : ILayoutTarget
      {
         return _container;
      }
      
      final public function set container(param1:ILayoutTarget) : void
      {
         var _loc2_:ILayoutTarget = null;
         if(param1 != _container)
         {
            _loc2_ = _container;
            if(_loc2_ != null)
            {
               reset();
               _loc2_.dispatchEvent(new LayoutTargetEvent("unsetAsLayoutRendererContainer",false,false,this));
               _loc2_.removeEventListener("mediaSizeChange",invalidatingEventHandler);
            }
            _container = param1;
            if(_container)
            {
               layoutMetadata = _container.layoutMetadata;
               _container.addEventListener("mediaSizeChange",invalidatingEventHandler,false,0,true);
               _container.dispatchEvent(new LayoutTargetEvent("setAsLayoutRendererContainer",false,false,this));
               invalidate();
            }
            processContainerChange(_loc2_,param1);
         }
      }
      
      final public function addTarget(param1:ILayoutTarget) : ILayoutTarget
      {
         var _loc2_:MetadataWatcher = null;
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         if(layoutTargets.indexOf(param1) != -1)
         {
            throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
         }
         param1.dispatchEvent(new LayoutTargetEvent("addToLayoutRenderer",false,false,this));
         var _loc3_:int = Math.abs(BinarySearch.search(layoutTargets,compareTargets,param1));
         layoutTargets.splice(_loc3_,0,param1);
         var _loc4_:Array = metaDataWatchers[param1] = [];
         for each(var _loc5_ in usedMetadatas)
         {
            _loc2_ = new MetadataWatcher(param1.layoutMetadata,_loc5_,null,targetMetadataChangeCallback);
            _loc2_.watch();
            _loc4_.push(_loc2_);
         }
         param1.addEventListener("displayObjectChange",invalidatingEventHandler);
         param1.addEventListener("mediaSizeChange",invalidatingEventHandler);
         param1.addEventListener("addToLayoutRenderer",onTargetAddedToRenderer);
         param1.addEventListener("setAsLayoutRendererContainer",onTargetSetAsContainer);
         invalidate();
         processTargetAdded(param1);
         return param1;
      }
      
      final public function removeTarget(param1:ILayoutTarget) : ILayoutTarget
      {
         var _loc4_:ILayoutTarget = null;
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         var _loc3_:Number = Number(layoutTargets.indexOf(param1));
         if(_loc3_ != -1)
         {
            removeFromStage(param1);
            _loc4_ = layoutTargets.splice(_loc3_,1)[0];
            param1.removeEventListener("displayObjectChange",invalidatingEventHandler);
            param1.removeEventListener("mediaSizeChange",invalidatingEventHandler);
            param1.removeEventListener("addToLayoutRenderer",onTargetAddedToRenderer);
            param1.removeEventListener("setAsLayoutRendererContainer",onTargetSetAsContainer);
            for each(var _loc2_ in metaDataWatchers[param1])
            {
               _loc2_.unwatch();
            }
            delete metaDataWatchers[param1];
            processTargetRemoved(param1);
            param1.dispatchEvent(new LayoutTargetEvent("removeFromLayoutRenderer",false,false,this));
            invalidate();
            return _loc4_;
         }
         throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
      }
      
      final public function hasTarget(param1:ILayoutTarget) : Boolean
      {
         return layoutTargets.indexOf(param1) != -1;
      }
      
      final public function get measuredWidth() : Number
      {
         return _measuredWidth;
      }
      
      final public function get measuredHeight() : Number
      {
         return _measuredHeight;
      }
      
      final public function invalidate() : void
      {
         if(cleaning == false && dirty == false)
         {
            dirty = true;
            if(_parent != null)
            {
               _parent.invalidate();
            }
            else
            {
               flagDirty(this);
            }
         }
      }
      
      final public function validateNow() : void
      {
         if(_container == null || cleaning == true)
         {
            return;
         }
         if(_parent)
         {
            _parent.validateNow();
            return;
         }
         cleaning = true;
         measure();
         layout(_measuredWidth,_measuredHeight);
         cleaning = false;
      }
      
      internal function measure() : void
      {
         prepareTargets();
         for each(var _loc2_ in layoutTargets)
         {
            _loc2_.measure(true);
         }
         var _loc1_:Point = calculateContainerSize(layoutTargets);
         _measuredWidth = _loc1_.x;
         _measuredHeight = _loc1_.y;
         _container.measure(false);
      }
      
      internal function layout(param1:Number, param2:Number) : void
      {
         var _loc4_:Rectangle = null;
         var _loc3_:DisplayObject = null;
         processUpdateMediaDisplayBegin(layoutTargets);
         _container.layout(param1,param2,false);
         for each(var _loc5_ in layoutTargets)
         {
            _loc4_ = calculateTargetBounds(_loc5_,param1,param2);
            _loc5_.layout(_loc4_.width,_loc4_.height,true);
            _loc3_ = _loc5_.displayObject;
            if(_loc3_)
            {
               _loc3_.x = _loc4_.x;
               _loc3_.y = _loc4_.y;
            }
         }
         dirty = false;
         processUpdateMediaDisplayEnd();
      }
      
      protected function get usedMetadatas() : Vector.<String>
      {
         return new Vector.<String>();
      }
      
      protected function compareTargets(param1:ILayoutTarget, param2:ILayoutTarget) : Number
      {
         return 0;
      }
      
      protected function processContainerChange(param1:ILayoutTarget, param2:ILayoutTarget) : void
      {
      }
      
      protected function processTargetAdded(param1:ILayoutTarget) : void
      {
      }
      
      protected function processTargetRemoved(param1:ILayoutTarget) : void
      {
      }
      
      protected function processStagedTarget(param1:ILayoutTarget) : void
      {
      }
      
      protected function processUnstagedTarget(param1:ILayoutTarget) : void
      {
      }
      
      protected function processUpdateMediaDisplayBegin(param1:Vector.<ILayoutTarget>) : void
      {
      }
      
      protected function processUpdateMediaDisplayEnd() : void
      {
      }
      
      protected function updateTargetOrder(param1:ILayoutTarget) : void
      {
         var _loc2_:int = int(layoutTargets.indexOf(param1));
         if(_loc2_ != -1)
         {
            layoutTargets.splice(_loc2_,1);
            _loc2_ = Math.abs(BinarySearch.search(layoutTargets,compareTargets,param1));
            layoutTargets.splice(_loc2_,0,param1);
         }
      }
      
      protected function calculateTargetBounds(param1:ILayoutTarget, param2:Number, param3:Number) : Rectangle
      {
         return new Rectangle();
      }
      
      protected function calculateContainerSize(param1:Vector.<ILayoutTarget>) : Point
      {
         return new Point();
      }
      
      protected function processParentChange(param1:LayoutRendererBase) : void
      {
      }
      
      private function reset() : void
      {
         for each(var _loc1_ in layoutTargets)
         {
            removeTarget(_loc1_);
         }
         if(_container)
         {
            _container.removeEventListener("mediaSizeChange",invalidatingEventHandler);
            validateNow();
         }
         _container = null;
         layoutMetadata = null;
      }
      
      private function targetMetadataChangeCallback(param1:Metadata) : void
      {
         invalidate();
      }
      
      private function invalidatingEventHandler(param1:Event) : void
      {
         invalidate();
      }
      
      private function onTargetAddedToRenderer(param1:LayoutTargetEvent) : void
      {
         var _loc2_:ILayoutTarget = null;
         if(param1.layoutRenderer != this)
         {
            _loc2_ = param1.target as ILayoutTarget;
            if(hasTarget(_loc2_))
            {
               removeTarget(_loc2_);
            }
         }
      }
      
      private function onTargetSetAsContainer(param1:LayoutTargetEvent) : void
      {
         var _loc2_:ILayoutTarget = null;
         if(param1.layoutRenderer != this)
         {
            _loc2_ = param1.target as ILayoutTarget;
            if(container == _loc2_)
            {
               container = null;
            }
         }
      }
      
      private function prepareTargets() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:int = 0;
         for each(var _loc3_ in layoutTargets)
         {
            _loc1_ = _loc3_.displayObject;
            if(_loc1_)
            {
               addToStage(_loc3_,_loc3_.displayObject,_loc2_);
               _loc2_++;
            }
            else
            {
               removeFromStage(_loc3_);
            }
         }
      }
      
      private function addToStage(param1:ILayoutTarget, param2:DisplayObject, param3:Number) : void
      {
         var _loc4_:DisplayObject = stagedDisplayObjects[param1];
         if(_loc4_ == param2)
         {
            _container.dispatchEvent(new LayoutTargetEvent("setChildIndex",false,false,this,param1,_loc4_,param3));
         }
         else
         {
            if(_loc4_ != null)
            {
               _container.dispatchEvent(new LayoutTargetEvent("removeChild",false,false,this,param1,_loc4_));
            }
            stagedDisplayObjects[param1] = param2;
            _container.dispatchEvent(new LayoutTargetEvent("addChildAt",false,false,this,param1,param2,param3));
            if(_loc4_ == null)
            {
               processStagedTarget(param1);
            }
         }
      }
      
      private function removeFromStage(param1:ILayoutTarget) : void
      {
         var _loc2_:DisplayObject = stagedDisplayObjects[param1];
         if(_loc2_ != null)
         {
            delete stagedDisplayObjects[param1];
            _container.dispatchEvent(new LayoutTargetEvent("removeChild",false,false,this,param1,_loc2_));
         }
      }
   }
}

