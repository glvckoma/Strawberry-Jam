package game.towerDefense
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import localization.LocalizationManager;
   
   public class TowerDefenseTower
   {
      public var _type:int;
      
      public var _upgradeLevel:int;
      
      public var _tileRow:int;
      
      public var _tileColumn:int;
      
      public var _clone:Object;
      
      public var _theGame:TowerDefense;
      
      public var _currentAttackTarget:TowerDefenseEnemy;
      
      public var _attackLine:MovieClip;
      
      public var _attackLineActive:Boolean;
      
      public var _attackTime:Number;
      
      public var _waitTime:Number;
      
      public function TowerDefenseTower(param1:TowerDefense, param2:int)
      {
         super();
         _theGame = param1;
         _clone = {};
         _upgradeLevel = 0;
         _type = param2;
         _attackLine = new MovieClip();
         _attackLineActive = false;
         _attackTime = 0;
         _waitTime = 0;
      }
      
      public function heartbeat(param1:Number) : void
      {
         update(param1);
      }
      
      public function update(param1:Number) : void
      {
         if(_attackTime > 0)
         {
            _attackTime -= param1;
            if(_attackTime <= 0)
            {
               if(_attackLineActive)
               {
                  _clone.loader.content.removeChild(_attackLine);
                  _attackLineActive = false;
               }
            }
            else
            {
               findEnemy();
               attack();
            }
         }
         else if(_waitTime > 0)
         {
            _waitTime -= param1;
         }
         else
         {
            findEnemy();
            attack();
         }
      }
      
      public function attack() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Point = null;
         if(_currentAttackTarget && _currentAttackTarget._clone.loader.content && _currentAttackTarget._healthBar.loader.content)
         {
            if(_attackTime <= 0)
            {
               _clone.loader.content.addChild(_attackLine);
               _attackLineActive = true;
               _attackTime += 0.05;
               _waitTime += _theGame._attackRate[_type][_upgradeLevel];
               if(_upgradeLevel == 0)
               {
                  _loc1_ = int(_theGame._attackDamageModifier[_type][_currentAttackTarget._type]);
               }
               else if(_upgradeLevel == 1)
               {
                  _loc1_ = int(_theGame._attackDamageModifier2[_type][_currentAttackTarget._type]);
               }
               else
               {
                  _loc1_ = int(_theGame._attackDamageModifier3[_type][_currentAttackTarget._type]);
               }
               _currentAttackTarget.applyDamage(_theGame._attackDamage[_type][_upgradeLevel] + _loc1_,_theGame._attackPriority[_type].indexOf(_currentAttackTarget._type) != -1);
            }
            _attackTime -= 0.05;
            _attackLineActive = false;
            _loc2_ = getAttackSquare();
            if(_loc2_.x != 0 || _loc2_.y != 0)
            {
               _clone.loader.content.attack(_loc2_.x,_loc2_.y);
               _theGame.attack(_type);
            }
         }
      }
      
      private function getAttackSquare() : Point
      {
         var _loc1_:Point = new Point();
         var _loc3_:Object = _currentAttackTarget._clone.loader;
         var _loc2_:Object = _clone.loader;
         if(_loc3_.x < _loc2_.x - _loc2_.width / 2 - _loc2_.width)
         {
            _loc1_.x = -2;
         }
         else if(_loc3_.x < _loc2_.x - _loc2_.width / 2)
         {
            _loc1_.x = -1;
         }
         else if(_loc3_.x > _loc2_.x + _loc2_.width / 2 + _loc2_.width)
         {
            _loc1_.x = 2;
         }
         else if(_loc3_.x > _loc2_.x + _loc2_.width / 2)
         {
            _loc1_.x = 1;
         }
         else
         {
            _loc1_.x = 0;
         }
         if(_loc3_.y < _loc2_.y - _loc2_.height / 2 - _loc2_.height)
         {
            _loc1_.y = -2;
         }
         else if(_loc3_.y < _loc2_.y - _loc2_.height / 2)
         {
            _loc1_.y = -1;
         }
         else if(_loc3_.y > _loc2_.y + _loc2_.height / 2 + _loc2_.height)
         {
            _loc1_.y = 2;
         }
         else if(_loc3_.y > _loc2_.y + _loc2_.height / 2)
         {
            _loc1_.y = 1;
         }
         else
         {
            _loc1_.y = 0;
         }
         return _loc1_;
      }
      
      public function findEnemy() : void
      {
         var _loc5_:int = 0;
         var _loc2_:Array = null;
         var _loc1_:int = 0;
         var _loc3_:Boolean = false;
         var _loc6_:Array = _theGame._enemies;
         var _loc9_:* = null;
         var _loc8_:Array = [];
         var _loc4_:Number = _theGame._attackRange[_type] * 50 + 24;
         for each(var _loc7_ in _loc6_)
         {
            if(_loc7_.isValidTarget() && Math.abs(_loc7_._clone.loader.x - _clone.loader.x) <= _loc4_ && Math.abs(_loc7_._clone.loader.y - _clone.loader.y) <= _loc4_)
            {
               _loc8_.push(_loc7_);
            }
         }
         if(_loc8_.length > 0)
         {
            _loc8_.sortOn("_distanceTraveled",2 | 0x10);
            _loc9_ = _loc8_[0];
            _loc2_ = _theGame._attackPriority[_type];
            _loc1_ = -1;
            _loc3_ = false;
            for each(_loc7_ in _loc8_)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc2_.length)
               {
                  if(_loc7_._type == _loc2_[_loc5_])
                  {
                     _loc9_ = _loc7_;
                     _loc3_ = true;
                     break;
                  }
                  _loc5_++;
               }
               if(_loc3_)
               {
                  break;
               }
            }
         }
         _currentAttackTarget = _loc9_;
         if(_currentAttackTarget == null && _attackLineActive == true)
         {
            _clone.loader.content.removeChild(_attackLine);
            _attackLineActive = false;
         }
      }
      
      public function enableMouse() : void
      {
         _clone.loader.content.addEventListener("mouseUp",showTowerOptions);
      }
      
      public function showTowerOptions(param1:MouseEvent) : void
      {
         var _loc2_:Object = _theGame.getScene().getLayer("towerOptions").loader;
         _theGame._layerTowers.addChild(_loc2_ as DisplayObject);
         if(_theGame._mode == 0 || _theGame._mode == 1 || _upgradeLevel == 1 && _theGame._endless == false)
         {
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.gotoAndStop("locked");
         }
         else if(_upgradeLevel + 1 >= _theGame._towerCost[_type].length)
         {
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.gotoAndStop("max");
         }
         else if(_theGame._tokens < _theGame.getUpgradeCost(_type,_upgradeLevel))
         {
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.gotoAndStop("short");
         }
         else
         {
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.gotoAndStop("off");
         }
         if(_upgradeLevel == 0)
         {
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.level1.visible = true;
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.level2.visible = false;
         }
         else if(_upgradeLevel == 1)
         {
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.level1.visible = false;
            _theGame.getScene().getLayer("towerOptions").loader.content.upgradeButton.level2.visible = true;
         }
         if(_theGame._activeDialogTower)
         {
            _theGame._activeDialogTower.towerOptionsClose(null);
         }
         _loc2_.x = _clone.loader.x;
         _loc2_.y = _clone.loader.y;
         _clone.loader.content.removeEventListener("mouseUp",showTowerOptions);
         _theGame.stage.addEventListener("mouseDown",towerOptionsClose);
         _loc2_.content.addEventListener("mouseOut",towerOptionsDetectOutsideClick);
         _loc2_.content.addEventListener("mouseOver",towerOptionsDetectInsideClick);
         LocalizationManager.translateIdAndInsert(_loc2_.content.upgradeButton.upgradeText,11990,_theGame.getUpgradeCost(_type,_upgradeLevel));
         LocalizationManager.translateIdAndInsert(_loc2_.content.sellButton.sellText,11991,_theGame.getSellPrice(_type,_upgradeLevel));
         _theGame._activeDialogTower = this;
         _theGame.play(_theGame._soundNameTowerSelect);
      }
      
      public function towerOptionsDetectInsideClick(param1:MouseEvent) : void
      {
         _theGame.stage.removeEventListener("mouseDown",towerOptionsClose);
         _theGame.getScene().getLayer("towerOptions").loader.content.addEventListener("mouseOut",towerOptionsDetectOutsideClick);
      }
      
      public function towerOptionsDetectOutsideClick(param1:MouseEvent) : void
      {
         _theGame.stage.addEventListener("mouseDown",towerOptionsClose);
         _theGame.getScene().getLayer("towerOptions").loader.content.removeEventListener("mouseOut",towerOptionsDetectOutsideClick);
      }
      
      public function towerOptionsClose(param1:MouseEvent) : void
      {
         var _loc2_:Object = _theGame.getScene().getLayer("towerOptions").loader;
         if(_loc2_.parent)
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         _loc2_.content.removeEventListener("mouseOut",towerOptionsDetectOutsideClick);
         _loc2_.content.removeEventListener("mouseOver",towerOptionsDetectInsideClick);
         _theGame.stage.removeEventListener("mouseDown",towerOptionsClose);
         _theGame._activeDialogTower = null;
         _theGame.play(_theGame._soundNameTowerDeselect);
         enableMouse();
      }
      
      public function upgrade() : void
      {
         towerOptionsClose(null);
         if(_upgradeLevel + 1 < _theGame._towerCost[0].length)
         {
            _theGame._tokens -= _theGame.getUpgradeCost(_type,_upgradeLevel);
            _theGame.getScene().getLayer("background").loader.content.gemsText.text = _theGame._tokens;
            _upgradeLevel++;
            _clone.loader.content.upgrade();
            _theGame.play(_theGame._soundNameTowerUpgrade);
         }
      }
      
      public function sell() : void
      {
         towerOptionsClose(null);
         _clone.loader.parent.removeChild(_clone.loader);
         _theGame._tokens += _theGame.getSellPrice(_type,_upgradeLevel);
         _theGame.getScene().getLayer("background").loader.content.gemsText.text = _theGame._tokens;
         _theGame._placedTowers.splice(_theGame._placedTowers.indexOf(this),1);
         var _loc1_:int = _clone.loader.y / 50 * 14 + _clone.loader.x / 50;
         _theGame._towerLocations.splice(_theGame._towerLocations.indexOf(_loc1_),1);
         _theGame.play(_theGame._soundNameTowerSell);
      }
   }
}

